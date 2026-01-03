import 'dart:convert';

import 'package:brand_app/ip/ipaddress.dart';
import 'package:brand_app/util/pcolor.dart';
import 'package:brand_app/util/snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// 문의 내역 구성
class Inquiry {
  final String threadKey;
  final int cid;
  final String title;
  final String lastMessage;
  final DateTime lastTime;

  Inquiry({
    required this.threadKey,
    required this.cid,
    required this.title,
    required this.lastMessage,
    required this.lastTime,
  });
}

// 고객 정보
class CustomerBrief {
  final int cid;
  final String name;
  final String email;

  CustomerBrief({
    required this.cid,
    required this.name,
    required this.email,
  });
}

class AskChat extends StatefulWidget {
  const AskChat({super.key});

  @override
  State<AskChat> createState() => _AskChatState();
}

class _AskChatState extends State<AskChat> {
  final TextEditingController chatController = TextEditingController();
  final CustomSnackbar snack = CustomSnackbar();

  String? _selectedThreadKey;
  int? _selectedCid;
  String? _selectedTitle;

  final int _dummyAdminEid = 101; // 임시 관리자 id

  final Map<int, CustomerBrief> _customerCache = {};
  final Set<int> _loadingCids = {};

  late final Stream<QuerySnapshot> _inquiryStream;
  Stream<QuerySnapshot>? _messageStream;

  @override
  void initState() {
    super.initState();
    _inquiryStream = FirebaseFirestore.instance
        .collection('ask')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  void dispose() {
    chatController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomer(int cid) async {
    if (_customerCache.containsKey(cid) || _loadingCids.contains(cid)) return;

    _loadingCids.add(cid);

    final url = Uri.parse("${IpAddress.baseUrl}/customer/select?cid=$cid");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decodeData =
            json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final List results = decodeData['results'] ?? [];

        if (results.isNotEmpty) {
          final row = results.first as Map<String, dynamic>;

          final customer = CustomerBrief(
            cid: cid,
            name: row['name'] ?? '고객',
            email: row['email'] ?? '',
          );

          _customerCache[cid] = customer;
        }
      } else {
        print("statusCode: ${response.statusCode}");
      }
    } catch (e) {
      print("error: $e");
    } finally {
      _loadingCids.remove(cid);
      setState(() {});
    }
  }

  // build --------------------------------------
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: Row(
          children: [
            SizedBox(
              width: screenWidth * 0.5,
              child: Scaffold(
                appBar: AppBar(
                  title: Text('문의 내역'),
                  backgroundColor: Pcolor.appBarBackgroundColor,
                  foregroundColor: Pcolor.appBarForegroundColor,
                  centerTitle: true,
                ),
                body: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _inquiryStream,
                    builder: (context, snapshot) => _buildInquiryList(snapshot),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: screenWidth * 0.5,
              child: Scaffold(
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 30, 40, 10),
                      child: Text(
                        _selectedTitle ?? '왼쪽에서 문의를 선택해주세요.',
                        style: TextStyle(
                          fontSize: _selectedTitle == null ? 20 : 22,
                          fontWeight: _selectedTitle == null
                              ? FontWeight.normal
                              : FontWeight.bold,
                          color:
                              _selectedTitle == null ? Colors.grey : Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      child: _selectedCid == null || _selectedTitle == null
                          ? Center(
                              child: Text(
                                '문의가 선택되지 않았습니다.',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : _buildMessageList(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: SizedBox(
                        width: screenWidth * 0.45,
                        child: TextField(
                          controller: chatController,
                          maxLines: null,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () => _sendMessage(),
                              icon: Icon(
                                Icons.keyboard_return_outlined,
                                size: 28,
                              ),
                              color: Colors.black,
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  } // build

  // Widget ----------------------------------------------

  Widget _buildInquiryList(AsyncSnapshot<QuerySnapshot> snapshot) {
    if (snapshot.hasError) {
      return Center(
        child: Text(
          'Firestore 오류:\n${snapshot.error}',
          textAlign: TextAlign.center,
        ),
      );
    }
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    }
    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return Center(child: Text('문의가 없습니다.'));
    }
    final docs = snapshot.data!.docs;

    final Map<String, Inquiry> threadMap = {};

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;

      final int cid = (data['cid'] ?? 0);
      final String title = (data['title'] ?? '상품 문의');
      final String contents = (data['contents'] ?? '');

      final DateTime time = _safeTime(data['timestamp']);
      final String key = '${cid}_$title';

      if (threadMap.containsKey(key)) continue;

      threadMap[key] = Inquiry(
        threadKey: key,
        cid: cid,
        title: title,
        lastMessage: contents,
        lastTime: time,
      );
    }

    final threads = threadMap.values.toList()
      ..sort((a, b) => b.lastTime.compareTo(a.lastTime));

    return ListView.builder(
      itemCount: threads.length,
      itemBuilder: (context, index) {
        final t = threads[index];
        final bool isSelected = t.threadKey == _selectedThreadKey;

        _loadCustomer(t.cid);

        final customer = _customerCache[t.cid];
        final String displayName = customer?.name ?? '고객 #${t.cid}';
        final String displayEmail = customer?.email ?? '이메일 정보 없음';

        return Padding(
          padding: const EdgeInsets.all(5.0),
          child: GestureDetector(
            onTap: () {
              _selectedThreadKey = t.threadKey;
              _selectedCid = t.cid;
              _selectedTitle = t.title;

              _messageStream = FirebaseFirestore.instance
                  .collection('ask')
                  .where('cid', isEqualTo: t.cid)
                  .where('title', isEqualTo: t.title)
                  .orderBy('timestamp', descending: false)
                  .snapshots();

              setState(() {});
            },
            child: Card(
              elevation: isSelected ? 4 : 1,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: isSelected ? Colors.blueAccent : Colors.transparent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '진행 중',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                        Text(
                          _formatDateTimeShort(t.lastTime),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        displayName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        displayEmail,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        t.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        t.lastMessage,
                        style: TextStyle(fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageList() {
    if (_messageStream == null) {
      return Center(child: Text('문의가 선택되지 않았습니다.'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _messageStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Firestore 오류:\n${snapshot.error}',
              textAlign: TextAlign.center,
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('아직 채팅 내역이 없습니다.'));
        }
        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;

            final bool isCustomer = data['eid'] == null;
            final String content = (data['contents'] ?? '');
            final DateTime time = _safeTime(data['timestamp']);

            bool showDateHeader = false;
            if (index == 0) {
              showDateHeader = true;
            } else {
              final prevData =
                  docs[index - 1].data() as Map<String, dynamic>;
              final prevTime = _safeTime(prevData['timestamp']);
              final bool sameDay =
                  time.year == prevTime.year &&
                  time.month == prevTime.month &&
                  time.day == prevTime.day;
              if (!sameDay) showDateHeader = true;
            }

            bool showTime = true;
            if (index < docs.length - 1) {
              final nextData =
                  docs[index + 1].data() as Map<String, dynamic>;
              final bool nextIsCustomer = nextData['eid'] == null;
              final DateTime nextTime = _safeTime(nextData['timestamp']);

              final bool sameSender = isCustomer == nextIsCustomer;
              final bool sameMinute =
                  time.year == nextTime.year &&
                  time.month == nextTime.month &&
                  time.day == nextTime.day &&
                  time.hour == nextTime.hour &&
                  time.minute == nextTime.minute;

              if (sameSender && sameMinute) {
                showTime = false;
              }
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showDateHeader)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(44, 10, 44, 10),
                      child: _buildDateDivider(_formatDate(time)),
                    ),
                  _buildChatItem(
                    text: content,
                    time: time,
                    isCustomer: isCustomer,
                    showTime: showTime,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  DateTime _safeTime(dynamic ts) {
    if (ts is Timestamp) return ts.toDate();
    if (ts is String && ts.isNotEmpty) {
      return DateTime.tryParse(ts) ?? DateTime.now();
    }
    return DateTime.now();
  }

  Widget _buildDateDivider(String text) {
    return Row(
      children: [
        Expanded(
          child: Divider(thickness: 2, color: Colors.grey),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 24,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Divider(thickness: 2, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildChatItem({
    required String text,
    required DateTime time,
    required bool isCustomer,
    required bool showTime,
  }) {
    final Alignment alignment =
        isCustomer ? Alignment.centerLeft : Alignment.centerRight;
    final BorderRadius radius = isCustomer
        ? BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          )
        : BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          );
    final String timeLabel = _formatTime(time);

    return Column(
      crossAxisAlignment:
          isCustomer ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Align(
          alignment: alignment,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.4,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: radius,
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 20,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        if (showTime)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
            child: Align(
              alignment: alignment,
              child: Text(
                timeLabel,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    final int hour = dt.hour;
    final int minute = dt.minute;
    final bool isPm = hour >= 12;
    final int h12 = ((hour + 11) % 12) + 1;
    final String mm = minute.toString().padLeft(2, '0');
    return '${isPm ? '오후' : '오전'} $h12:$mm';
  }

  String _formatDate(DateTime dt) {
    final String m = dt.month.toString().padLeft(2, '0');
    final String d = dt.day.toString().padLeft(2, '0');
    return '${dt.year}.$m.$d';
  }

  String _formatDateTimeShort(DateTime dt) {
    final String y = dt.year.toString();
    final String m = dt.month.toString().padLeft(2, '0');
    final String d = dt.day.toString().padLeft(2, '0');
    final String hh = dt.hour.toString().padLeft(2, '0');
    final String mm = dt.minute.toString().padLeft(2, '0');
    return '$y.$m.$d $hh:$mm';
  }

  // Functions -------------------------------------

  Future<void> _sendMessage() async {
    if (_selectedCid == null || _selectedTitle == null) {
      snack.errorSnackBar("문의 선택", "먼저 왼쪽에서 문의를 선택해주세요.");
      return;
    }

    final text = chatController.text.trim();
    if (text.isEmpty) return;

    chatController.clear();

    await FirebaseFirestore.instance.collection('ask').add({
      'cid': _selectedCid,
      'eid': _dummyAdminEid, // 더미 관리자 아이디
      'contents': text,
      'timestamp': FieldValue.serverTimestamp(),
      'title': _selectedTitle,
    });
  }
}

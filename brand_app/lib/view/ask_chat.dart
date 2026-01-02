import 'package:brand_app/util/pcolor.dart';
import 'package:brand_app/util/snackbar.dart';
import 'package:flutter/material.dart';

// Inquiry 모델
class Inquiry {
  int? id;
  int cid;
  String cname;
  String cemail;
  String pname;
  String mname;
  String size;
  int quantity;
  String color;
  int pid;
  String sname;
  DateTime timeStamp;

  Inquiry({
    this.id,
    required this.cid,
    required this.cname,
    required this.cemail,
    required this.pname,
    required this.mname,
    required this.size,
    required this.quantity,
    required this.color,
    required this.pid,
    required this.sname,
    required this.timeStamp,
  });

  factory Inquiry.fromJson(Map<String, dynamic> json) {
    return Inquiry(
      id: json['id'],
      cid: json['cid'],
      cname: json['cname'],
      cemail: json['cemail'],
      pname: json['pname'],
      mname: json['mname'],
      size: json['size'].toString(),
      quantity: json['quantity'],
      color: json['color'],
      pid: json['pid'],
      sname: json['sname'],
      timeStamp: DateTime.parse(json['timeStamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cid': cid,
      'cname': cname,
      'cemail': cemail,
      'pname': pname,
      'mname': mname,
      'size': size,
      'quantity': quantity,
      'color': color,
      'pid': pid,
      'sname': sname,
      'timeStamp': timeStamp.toIso8601String(),
    };
  }
}

// ChatMessage 모델
class ChatMessage {
  int? id;
  int iid;
  int? cid;
  int? eid;
  String content;
  DateTime timeStamp;

  ChatMessage({
    this.id,
    required this.iid,
    this.cid,
    this.eid,
    required this.content,
    required this.timeStamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      iid: json['iid'],
      cid: json['cid'],
      eid: json['eid'],
      content: json['content'],
      timeStamp: DateTime.parse(json['timeStamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'iid': iid,
      'cid': cid,
      'eid': eid,
      'content': content,
      'timeStamp': timeStamp.toIso8601String(),
    };
  }
}

// AskChat
class AskChat extends StatefulWidget {
  const AskChat({super.key});

  @override
  State<AskChat> createState() => _AskChatState();
}

class _AskChatState extends State<AskChat> {
  final TextEditingController chatController = TextEditingController();
  final CustomSnackbar snack = CustomSnackbar();
  
  late List<Inquiry> _inquiries;
  late List<ChatMessage> _allMessages;
  int? _selectedInquiryId;
  final int _dummyAdminEid = 101; // 더미데이터

  @override
  void initState() {
    super.initState();
    // 더미
    _inquiries = [
      Inquiry(
        id: 1,
        cid: 1,
        cname: '김민구',
        cemail: 'user1@xyz.com',
        pname: '나이키 에어포스',
        mname: 'Nike',
        size: '260',
        quantity: 1,
        color: 'Black',
        pid: 1001,
        sname: '강남점',
        timeStamp: DateTime(2025, 12, 30, 17, 16),
      ),
      Inquiry(
        id: 2,
        cid: 2,
        cname: '김민규',
        cemail: 'user2@xyz.com',
        pname: '아디다스 123',
        mname: 'Adidas',
        size: '270',
        quantity: 2,
        color: 'White',
        pid: 1002,
        sname: '강북점',
        timeStamp: DateTime(2025, 12, 30, 18, 10),
      ),
      Inquiry(
        id: 3,
        cid: 3,
        cname: '김민뀨',
        cemail: 'user3@xyz.com',
        pname: '뉴발란스 뉴발란스',
        mname: 'New Balance',
        size: '255',
        quantity: 1,
        color: 'Red',
        pid: 1003,
        sname: '종로점',
        timeStamp: DateTime(2025, 12, 31, 10, 20),
      ),
    ];

    // 더미 ChatMessage
    _allMessages = [
      ChatMessage(
        id: 1,
        iid: 1,
        cid: 1,
        eid: null,
        content: 'user1 문의',
        timeStamp: DateTime(2025, 12, 30, 17, 16, 10),
      ),
      ChatMessage(
        id: 2,
        iid: 1,
        cid: null,
        eid: _dummyAdminEid,
        content: '답변',
        timeStamp: DateTime(2025, 12, 30, 17, 17, 30),
      ),
      ChatMessage(
        id: 3,
        iid: 1,
        cid: 1,
        eid: null,
        content: 'ㅇㅇ',
        timeStamp: DateTime(2025, 12, 30, 17, 18, 5),
      ),
      ChatMessage(
        id: 4,
        iid: 1,
        cid: null,
        eid: _dummyAdminEid,
        content: 'ㄱㄱ',
        timeStamp: DateTime(2025, 12, 30, 17, 19, 40),
      ),

      ChatMessage(
        id: 8,
        iid: 2,
        cid: 2,
        eid: null,
        content: 'user2 ㄱㄱ',
        timeStamp: DateTime(2025, 12, 30, 18, 15, 0),
      ),
      ChatMessage(
        id: 9,
        iid: 2,
        cid: null,
        eid: _dummyAdminEid,
        content: 'ㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇ',
        timeStamp: DateTime(2025, 12, 30, 18, 16, 30),
      ),
      ChatMessage(
        id: 10,
        iid: 2,
        cid: 2,
        eid: null,
        content: 'ㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇ',
        timeStamp: DateTime(2025, 12, 30, 18, 17, 10),
      ),
      ChatMessage(
        id: 11,
        iid: 2,
        cid: null,
        eid: _dummyAdminEid,
        content: 'ㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇ',
        timeStamp: DateTime(2025, 12, 30, 18, 18, 30),
      ),
      ChatMessage(
        id: 12,
        iid: 2,
        cid: null,
        eid: _dummyAdminEid,
        content: 'ㅇㅇㅇㅇㅇㅇㅇㅇㅇㅇ',
        timeStamp: DateTime(2025, 12, 30, 18, 18, 35),
      ),
      ChatMessage(
        id: 13,
        iid: 2,
        cid: 2,
        eid: null,
        content: 'ㅇ',
        timeStamp: DateTime(2025, 12, 31, 18, 20, 0),
      ),

      ChatMessage(
        id: 14,
        iid: 3,
        cid: 3,
        eid: null,
        content: 'user3 문의',
        timeStamp: DateTime(2025, 12, 30, 10, 29, 10),
      ),
      ChatMessage(
        id: 15,
        iid: 3,
        cid: null,
        eid: _dummyAdminEid,
        content: 'ㅇㅇ',
        timeStamp: DateTime(2025, 12, 31, 14, 23, 0),
      ),
      ChatMessage(
        id: 16,
        iid: 3,
        cid: 3,
        eid: null,
        content: 'ㅇㅇ',
        timeStamp: DateTime(2026, 01, 01, 04, 25, 30),
      ),    ];
  }

  @override
  void dispose() {
    chatController.dispose();
    super.dispose();
  }

  // 현재 선택된 문의
  Inquiry? get _selectedInquiry {
    if (_selectedInquiryId == null) return null;
    return _inquiries.firstWhere(
      (inq) => inq.id == _selectedInquiryId,
      orElse: () => _inquiries.first,
    );
  }

  // 현재 선택된 문의의 메시지들
  List<ChatMessage> get _selectedMessages {
    if (_selectedInquiryId == null) return [];
    final list = _allMessages.where((m) => m.iid == _selectedInquiryId).toList()
      ..sort((a, b) => a.timeStamp.compareTo(b.timeStamp));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Row(
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
                child: ListView.builder(
                  itemCount: _inquiries.length,
                  itemBuilder: (context, index) {
                    final inquiry = _inquiries[index];
                    final bool isSelected = inquiry.id == _selectedInquiryId;

                    return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Card(
                        elevation: isSelected ? 4 : 1,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: isSelected
                                ? Colors.blueAccent
                                : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                              child: Container(
                                color: Colors.grey,
                                width: 120,
                                height: 90,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 4.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Text(
                                        inquiry.cemail,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        SizedBox(
                                          width: screenWidth * 0.15,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('고객 이름 : ${inquiry.cname}'),
                                              Text('지점 위치 : ${inquiry.sname}'),
                                              Text('제품 번호 : ${inquiry.pid}'),
                                              Text(
                                                '제품명 : ${inquiry.pname}',
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: screenWidth * 0.15,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('제조사 : ${inquiry.mname}'),
                                              Text('색상 : ${inquiry.color}'),
                                              Text('사이즈 : ${inquiry.size}'),
                                              Text('수량 : ${inquiry.quantity}'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _selectedInquiryId = inquiry.id;
                                });
                              },
                              icon: Icon(Icons.arrow_forward_ios_outlined),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
                  if (_selectedInquiry != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 30, 40, 10),
                      child: Text(
                        '[${_selectedInquiry!.sname}] ${_selectedInquiry!.cemail}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 30, 40, 10),
                      child: Text(
                        '왼쪽에서 문의를 선택해주세요.',
                        style: TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                    ),
                  Expanded(
                    child: _selectedInquiryId == null
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
    );
  } // build

  // Widgets ---------------------------------------------
  Widget _buildMessageList() { // << StreamBuilder로 교체 (Firebase 적용 시)
    final messages = _selectedMessages;

    if (messages.isEmpty) {
      return Center(child: Text('아직 채팅 내역이 없습니다.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        final bool isCustomer = msg.cid != null;
        final String content = msg.content;
        final DateTime time = msg.timeStamp;

        bool showDateHeader = false;
        if (index == 0) {
          showDateHeader = true;
        } else {
          final prev = messages[index - 1];
          final prevTime = prev.timeStamp;
          final bool sameDay =
              time.year == prevTime.year &&
              time.month == prevTime.month &&
              time.day == prevTime.day;
          if (!sameDay) showDateHeader = true;
        }

        bool showTime = true;

        if (index < messages.length - 1) {
          final next = messages[index + 1];
          final DateTime nextTime = next.timeStamp;
          final bool nextIsCustomer = next.cid != null;

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
  }

  Widget _buildDateDivider(String text) {
    return Row(
      children: [
        Expanded(child: Divider(thickness: 2, color: Colors.grey)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            text,
            style: TextStyle(fontSize: 24, color: Colors.grey),
          ),
        ),
        Expanded(child: Divider(thickness: 2, color: Colors.grey)),
      ],
    );
  }

  Widget _buildChatItem({
    required String text,
    required DateTime time,
    required bool isCustomer,
    required bool showTime,
  }) {
    final Alignment alignment = isCustomer
        ? Alignment.centerLeft
        : Alignment.centerRight;

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
      crossAxisAlignment: isCustomer
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        Align(
          alignment: alignment,
          child: Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: radius,
            ),
            child: Text(
              text,
              style: TextStyle(fontSize: 20, color: Colors.black87),
            ),
          ),
        ),
        if (showTime)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
            child: Align(
              alignment: isCustomer
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: Text(
                timeLabel,
                style: TextStyle(fontSize: 15, color: Colors.grey),
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

  // Functions -----------------------------------
  void _sendMessage() async {
    if (_selectedInquiryId == null) {
      snack.errorSnackBar(
        "문의 선택",
        "먼저 왼쪽에서 문의를 선택해주세요.",
      );
      return;
    }

    final text = chatController.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();

    final newMessage = ChatMessage(
      id: (_allMessages.isEmpty ? 1 : (_allMessages.last.id ?? 0) + 1),
      iid: _selectedInquiryId!,
      cid: null,
      eid: _dummyAdminEid,
      content: text,
      timeStamp: now,
    );

    setState(() {
      _allMessages.add(newMessage);
      chatController.clear();
    });

    // Firebase 코드 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    //
    // await FirebaseFirestore.instance
    //   .collection('?')
    //   .doc(_selectedInquiryId!.toString())
    //   .collection('?')
    //   .add(newMessage.toJson());
  }
}

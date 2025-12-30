import 'package:flutter/material.dart';

class AskChat extends StatefulWidget {
  const AskChat({super.key});

  @override
  State<AskChat> createState() => _AskChatState();
}

class _AskChatState extends State<AskChat> {
  // Property
  TextEditingController chatController = TextEditingController();
  final Map<String, Object?> chat1 = {
    "id": 1,
    "cid": 1,
    "iid": null,
    "timeStamp": DateTime(2025, 12, 30, 17, 16, 10),
    "content": 'zzzzzzzz',
    "title": '주문 문의',
  };
  final Map<String, Object?> chat2 = {
    "id": 2,
    "cid": null,
    "iid": 1,
    "timeStamp": DateTime(2025, 12, 30, 17, 20, 19),
    "content": 'okokokokok',
    "title": '주문 문의',
  };

  late final List<Map<String, Object?>> chats;

  List data = [
    'aaaaaaaaaaaa',
    'bbbbbbbbbbbb',
    'ccccccccccccccc',
    'dddddddddddddddd',
    'eeeeeeeeeeeeeee'
  ];

  @override
  void initState() {
    super.initState();
    chats = [chat1, chat2];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Scaffold(
              appBar: AppBar(
                title: Text('문의 내역'),
                centerTitle: true,
              ),
              body: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Card(
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                              child: Container(
                                color: Colors.grey,
                                width: 120,
                                height: 100,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width*0.16,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(data[index], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                            Text('이름 : '),
                                            Text('제조사 : '),
                                            Text('사이즈 : '),
                                            Text('수량 : '),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width*0.16,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('지점 위치 : '),
                                            Text('제품 번호 : '),
                                            Text('색상 : '),
                                            Text('결재자 : '),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
            width: MediaQuery.of(context).size.width * 0.5,
            child: Scaffold(
              appBar: AppBar(
                title: Text('문의'),
                centerTitle: true,
              ),
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(60, 30, 60, 30),
                    child: _buildDateDivider('2025.12.30'),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: chats.length,
                      itemBuilder: (context, index) {
                        final msg = chats[index];
                        final bool isCustomer = msg['cid'] != null;
                        final String content =
                            (msg['content'] ?? '') as String;
                        final DateTime time =
                            msg['timeStamp'] as DateTime;

                        bool showTime = true;
                        if (index > 0) {
                          final prev = chats[index - 1];
                          final bool prevIsCustomer =
                              prev['cid'] != null;
                          final DateTime prevTime =
                              prev['timeStamp'] as DateTime;

                          final bool sameSender =
                              isCustomer == prevIsCustomer;
                          final bool sameMinute =
                              time.year == prevTime.year &&
                              time.month == prevTime.month &&
                              time.day == prevTime.day &&
                              time.hour == prevTime.hour &&
                              time.minute == prevTime.minute;

                          if (sameSender && sameMinute) {
                            showTime = false;
                          }
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: _buildChatItem(
                            text: content,
                            time: time,
                            isCustomer: isCustomer,
                            showTime: showTime,
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width*0.4,
                          child: TextField(
                            controller: chatController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(0)
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            //
                          },
                          icon: Icon(Icons.keyboard_return_outlined, size: 40),
                          color: Colors.black,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  } // build

  // Widget --------------------------------
  Widget _buildDateDivider(String text) {
    return Row(
      children: [
        Expanded(
          child: Divider(thickness: 2, color: Colors.grey),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(text, style: TextStyle(fontSize: 24, color: Colors.grey)),
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
            constraints: BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: radius,
            ),
            child: Text(
              text, style: TextStyle(fontSize: 20, color: Colors.black87)),
          ),
        ),
        if (showTime)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
            child: Align(
              alignment:
                  isCustomer ? Alignment.centerLeft : Alignment.centerRight,
              child: Text(timeLabel, style: TextStyle(fontSize: 15, color: Colors.grey)),
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
} // class

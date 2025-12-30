import 'package:customer_app/config.dart' as config;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//  Chatting - ask
/*
  Create: 30/12/2025 12:30, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: 
  Desc: Chatting - ask

  DateTime MUST converted using value.toIso8601String()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class Chatting extends StatefulWidget {
  const Chatting({super.key});

  @override
  State<Chatting> createState() => _ChattingState();
}

class _ChattingState extends State<Chatting> {
  //  Dummies
  final Map<String, Object?> chat1 = {
    "id": 1,
    "cid": 1,
    "iid": null,
    "timeStamp": DateTime(2025, 12, 29, 13, 11, 12),
    "content": '이 상품을 공짜로 주면 유혈 사태는 일어나지 않을 것입니다.',
    "title": '주문 문의',
  };
  final Map<String, Object?> chat2 = {
    "id": 2,
    "cid": null,
    "iid": 1,
    "timeStamp": DateTime(2025, 12, 29, 13, 11, 15),
    "content": '혹시 미친놈이세요?',
    "title": '주문 문의',
  };

  final List<Map<String, Object?>> totalChates = [];

  @override
  void initState() {
    super.initState();
    totalChates.add(chat1);
    totalChates.add(chat2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("\$브랜드이름", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade300),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
            child: Icon(Icons.search),
          ),
        ],
      ),
      body: Column(
        children: [
          //  Listview builder needed on realease
          config.chatDate(title: '\$주문 문의', datetime: DateTime.now()),
          Expanded(
            child: ListView.builder(
              itemCount: totalChates.length,
              itemBuilder: (context, index) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: totalChates[index]['cid'] == null
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.end,
                  children: [
                    if (totalChates[index]['cid'] != null)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          DateFormat(
                            config.chatDateFormat,
                          ).format(totalChates[index]['timeStamp'] as DateTime),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.5,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(totalChates[index]['content'] as String),
                        ),
                      ),
                    ),
                    if (totalChates[index]['cid'] == null)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          DateFormat(
                            config.chatDateFormat,
                          ).format(totalChates[index]['timeStamp'] as DateTime),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  //  Widget
}

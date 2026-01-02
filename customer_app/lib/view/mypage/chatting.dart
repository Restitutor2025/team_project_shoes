import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  void initState() {
    super.initState();
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
      body: StreamBuilder<QuerySnapshot>(
        //  데이타 바뀌어도 자동 동기화
        stream: FirebaseFirestore.instance
            .collection("ask")
            .orderBy("timestamp", descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('❌ Firestore error:\n${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final totalChates = snapshot.data!.docs;
          if (totalChates.isEmpty) {
            return Center(child: Text('문서가 0개야 (ask 컬렉션 비었거나 권한/프로젝트 문제 가능)'));
          }
          return ListView.builder(
            itemCount: totalChates.length,
            itemBuilder: (context, index) {
              final chattime = totalChates[index]['timestamp'].toDate();
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
                        DateFormat(config.chatDateFormat).format(chattime),
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
                        child: Text(totalChates[index]['contents'] as String),
                      ),
                    ),
                  ),
                  if (totalChates[index]['cid'] == null)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        DateFormat(config.chatDateFormat).format(chattime),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  //  Widget
}

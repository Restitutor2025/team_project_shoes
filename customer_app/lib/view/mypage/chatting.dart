import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/config.dart' as config;
import 'package:customer_app/model/customer.dart';
import 'package:customer_app/model/purchase.dart';
import 'package:customer_app/model/usercontroller.dart';
import 'package:customer_app/view/mypage/board_review.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

//  Chatting - ask
/*
  Create: 30/12/2025 12:30, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
    asdddasdasa
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
  //  Property
  late Customer customer;
  UserController userController = Get.find<UserController>();

  late int cid;
  late final PurchaseRow values;
  late TextEditingController tEC1;
  final String roomId = 'simple_chat';

  @override
  void initState() {
    super.initState();
    userController.user == null
      ? customer = Customer(id: 1, email: 'email', password: 'password', name: 'name', phone: 'phone', date: DateTime.now(), address: 'address')
      : customer = userController.user!;
    tEC1 = TextEditingController();
    cid = customer.id!;

    values = Get.arguments as PurchaseRow;
  }

  @override
  void dispose() {
    tEC1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("상품 문의", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey[300]),
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
            .where('pcid', isEqualTo: values.purchase.id)
            .orderBy("timestamp", descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Firestore error:\n${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final totalChates = snapshot.data!.docs;
          if (totalChates.isEmpty) {
            return Center(child: Text('No data in firebase'));
          }
          return ListView.builder(
            itemCount: totalChates.length,
            itemBuilder: (context, index) {
              final chattime = totalChates[index]['timestamp'].toDate();
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: (totalChates[index]['eid'] != null)
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.end,
                children: [
                  if (totalChates[index]['eid'] == null)
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
                        child: Text('${totalChates[index]['contents'] as String}'),
                      ),
                    ),
                  ),
                  if (totalChates[index]['eid'] != null)
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
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: tEC1,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(
                    hintText: '메시지를 입력하세요',
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 48,
                height: 48,
                child: ElevatedButton(
                  onPressed: _send,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: CircleBorder(),
                    backgroundColor: Colors.black,
                  ),
                  child: Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _send() async {
    final text = tEC1.text.trim();
    if (text.isEmpty) return;

    tEC1.clear();

    await FirebaseFirestore.instance
        .collection('ask')
        .add({
      'cid': cid,
      'eid': null,
      'pcid': values.purchase.id,
      'contents': text,
      'timestamp': FieldValue.serverTimestamp(),
      'title': '${values.productName ?? "상품"} 문의'
    });
  }
}

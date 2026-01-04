import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/config.dart' as config;
import 'package:customer_app/model/customer.dart';
import 'package:customer_app/model/usercontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Chatting extends StatefulWidget {
  const Chatting({super.key});

  @override
  State<Chatting> createState() => _ChattingState();
}

class _ChattingState extends State<Chatting> {
  late Customer customer;
  final UserController userController = Get.find<UserController>();

  late int cid;

  // ✅ PurchaseRow 제거, 필요한 값만 받기
  late int pcid;
  late String productName;

  late TextEditingController tEC1;

  @override
  void initState() {
    super.initState();

    customer = userController.user ??
        Customer(
          id: 1,
          email: 'email',
          password: 'password',
          name: 'name',
          phone: 'phone',
          date: DateTime.now(),
          address: 'address',
        );

    cid = customer.id ?? 1;
    tEC1 = TextEditingController();

    // ✅ args는 Map으로 받는다
    final args = (Get.arguments as Map<String, dynamic>? ?? {});
    pcid = (args['pcid'] ?? 0) as int;
    productName = (args['productName'] ?? '상품').toString();
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
        title: const Text("상품 문의", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey[300]),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
            child: Icon(Icons.search),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("ask")
            .where('pcid', isEqualTo: pcid)
            .orderBy("timestamp", descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Firestore error:\n${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final totalChats = snapshot.data!.docs;
          if (totalChats.isEmpty) {
            return const Center(child: Text('No data in firebase'));
          }

          return ListView.builder(
            itemCount: totalChats.length,
            itemBuilder: (context, index) {
              final doc = totalChats[index].data() as Map<String, dynamic>;

              // ✅ serverTimestamp() 아직 null일 수 있음 방어
              final Timestamp? ts = doc['timestamp'] as Timestamp?;
              final DateTime chatTime = (ts ?? Timestamp.now()).toDate();

              final bool isEmployee = doc['eid'] != null;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment:
                    isEmployee ? MainAxisAlignment.start : MainAxisAlignment.end,
                children: [
                  if (!isEmployee)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(DateFormat(config.chatDateFormat).format(chatTime)),
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
                        child: Text((doc['contents'] ?? '').toString()),
                      ),
                    ),
                  ),
                  if (isEmployee)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(DateFormat(config.chatDateFormat).format(chatTime)),
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                    shape: const CircleBorder(),
                    backgroundColor: Colors.black,
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
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

    await FirebaseFirestore.instance.collection('ask').add({
      'cid': cid,
      'eid': null,
      'pcid': pcid,
      'contents': text,
      'timestamp': FieldValue.serverTimestamp(),
      'title': '$productName 문의',
    });
  }
}

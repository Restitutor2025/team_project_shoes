import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/config.dart' as config;
import 'package:customer_app/model/customer.dart';
import 'package:customer_app/model/usercontroller.dart';
import 'package:customer_app/view/mypage/purchase_list.dart';
import 'package:customer_app/view/mypage/support_center.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

//  Mypage
/*
  Create: 29/12/2025 18:00, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
    CHECKER
  Version: 1.0
  Dependency: 
  Desc: Mypage

  DateTime MUST converted using value.toIso8601String()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class Mypage extends StatefulWidget {
  const Mypage({super.key});

  @override
  State<Mypage> createState() => _MypageState();
}

class _MypageState extends State<Mypage> {
  //  Property
  int purchases = 0;
  int reviews = 0;
  int asks = 0;
  late Customer customer;
  UserController userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    userController.user == null
      ? customer = Customer(id: 1, email: 'email', password: 'password', name: 'name', phone: 'phone', date: DateTime.now(), address: 'address')
      : customer = userController.user!;
    _loadCounts();
  }

  List<dynamic> _unwrapList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map && decoded['results'] is List) {
      return decoded['results'] as List;
    }
    return const [];
  }

  Future<List<dynamic>> _getList(String path) async {
    final url = Uri.parse("http://${config.hostip}:8008/$path");
    final res = await http.get(url);

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode} (${url.path}): ${res.body}');
    }

    final decoded = json.decode(utf8.decode(res.bodyBytes));
    final list = _unwrapList(decoded);
    return list;
  }

  Future<void> _loadCounts() async {

    try {
      final purchaseList = (await _getList(
        'purchase/selectcustomer?cid=${customer.id!}',
      ));
      final int purchaseCount = purchaseList.length;

      final int reviewCount = await _countFirestoreByCid(
        collection: 'review',
        cid: customer.id!,
      );

      final int askCount = await _countFirestoreByCid(
        collection: 'ask',
        cid: customer.id!,
      );

      if (!mounted) return;
      setState(() {
        purchases = purchaseCount;
        reviews = reviewCount;
        asks = askCount;
      });
    } catch (e, st) {
      debugPrint('mypage count error: $e\n$st');
    }
  }

  Future<int> _countFirestoreByCid({
    required String collection,
    required int cid,
  }) async {
    final fs = FirebaseFirestore.instance;

    final q1 = await fs
        .collection(collection)
        .where('cid', isEqualTo: cid)
        .get();
    final q2 = await fs
        .collection(collection)
        .where('cid', isEqualTo: cid.toString())
        .get();

    final ids = <String>{};
    for (final d in q1.docs) {
      ids.add(d.id);
    }
    for (final d in q2.docs) {
      ids.add(d.id);
    }

    return ids.length;
  }

  //  Query by using FKs from cid
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('마이 페이지'),
        centerTitle: true,
        leading: Icon(Icons.menu),
        actions: [Icon(Icons.settings)],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Row(
                children: [Icon(Icons.person), Text('\t\t${customer.name}')],
              ),
            ),
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey, width: 1),
              ),
              elevation: 0,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          IconButton(onPressed: () {
                            Get.to(PurchaseList(), arguments: {'cid': customer.id!});
                          }, icon: Icon(Icons.shopping_cart)),
                          Text('구매 내역'),
                          Text(purchases.toString()),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Icon(Icons.note_add),
                          Text('리뷰 내역'),
                          Text(reviews.toString()),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          IconButton(onPressed: () {
                            Get.to(SupportCenter());
                          }, icon: Icon(Icons.headphones)),
                          Text('고객 센터'),
                          Text(asks.toString()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey, width: 1),
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      '\n\t\t\t\t도움말\n',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 20, 0, 20),
                    child: Row(
                      children: [
                        Icon(Icons.recycling),
                        Text(
                          '  취소/반품/교환 내역',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 20, 0, 20),
                    child: Row(
                      children: [
                        Icon(Icons.article),
                        Text(
                          '  개인정보 처리방침',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 20, 0, 20),
                    child: Row(
                      children: [
                        Icon(Icons.warning),
                        Text(
                          '  서비스 이용 약관',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 20, 0, 20),
                    child: Row(
                      children: [
                        Icon(Icons.help),
                        Text(
                          '  버전 정보',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Image.asset(
              config.rlogoImage,
              width: MediaQuery.of(context).size.width,
              height: 100,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}

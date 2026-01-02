import 'package:customer_app/config.dart' as config;
import 'package:flutter/material.dart';

//  Mypage
/*
  Create: 29/12/2025 18:00, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
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
  late int purchases;
  late int reviews;
  late int asks;

  @override
  void initState() {
    super.initState();
    purchases = 0;
    reviews = 0;
    asks = 0;
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
                children: [Icon(Icons.question_mark), Text('\t\tUser')],
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
                          Icon(Icons.shopping_cart),
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
                          Icon(Icons.headphones),
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

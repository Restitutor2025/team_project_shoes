import 'package:customer_app/config.dart' as config;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PurchaseList extends StatefulWidget {
  const PurchaseList({super.key});

  @override
  State<PurchaseList> createState() => _PurchaseListState();
}

class _PurchaseListState extends State<PurchaseList> {
  //  Dummies
  final Map<String, Object?> purchase1 = {
    "id": 1,
    "quantity": 1,
    "price": 10000,
    "date": DateTime.now(),
  };
  final Map<String, Object?> purchase2 = {
    "id": 2,
    "quantity": 3,
    "price": 50000,
    "date": DateTime.now(),
  };

  final List<Map<String, Object?>> totalPurchases = [];

  @override
  void initState() {
    super.initState();
    totalPurchases.add(purchase1);
    totalPurchases.add(purchase2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("구매 목록", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade300),
        ),
      ),
      body: ListView.builder(
        itemCount: totalPurchases.length,
        itemBuilder: (context, index) {
          return SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: 180,
            child: Card(
              color: Colors.white,
              child: Row(
                children: [
                  Image.asset(
                    config.rlogoImage,
                    width: 50,
                    height: 50,
                    fit: BoxFit.contain,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 30, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text('\$상품 이름?', style: TextStyle(fontSize: 15)),
                              Text('X개', style: TextStyle(fontSize: 15)),
                              Text(
                                config.formatter.format(
                                  totalPurchases[index]["price"],
                                ),
                                style: TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              '구매 날짜: ${DateFormat(config.dateFormat).format(totalPurchases[index]['date'] as DateTime)}',
                              style: TextStyle(fontSize: 15),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 100,
                                height: 35,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    elevation: 1,
                                  ),
                                  child: Text(
                                    '반품 신청',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              '수령 날짜: ${DateFormat(config.dateFormat).format(totalPurchases[index]['date'] as DateTime)}',
                              style: TextStyle(fontSize: 15),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 100,
                                height: 35,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    elevation: 1,
                                  ),
                                  child: Text(
                                    '리뷰 하기',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
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
    );
  }
}

import 'package:customer_app/config.dart' as config;
import 'package:customer_app/model/purchase.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PurchaseList extends StatefulWidget {
  const PurchaseList({super.key});

  @override
  State<PurchaseList> createState() => _PurchaseListState();
}

class _PurchaseListState extends State<PurchaseList> {
  //  Property
  late List<dynamic> totalPurchases = [];

  @override
  void initState() {
    super.initState();
    setPurchaseList();
  }

  void setPurchaseList() async {
    try {
      final data = await config.getJSONData('/purchase');

      if (!mounted) {
        debugPrint('ERROR: widget already disposed');

        return;
      }
      setState(() {
        totalPurchases = data;
      });
    } catch (e, stack) {
      debugPrint('setPurchaseList error: $e');
      debugPrint('$stack');

      if (!mounted) {
        debugPrint('ERROR: widget already disposed');
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('구매 내역을 불러오지 못했습니다')));
    }
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
      body: totalPurchases.isEmpty
      ? CircularProgressIndicator()
      : ListView.builder(
        itemCount: totalPurchases.length,
        itemBuilder: (context, index) {
          final purchase = totalPurchases[index];
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

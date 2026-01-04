import 'package:customer_app/config.dart' as config;
import 'package:customer_app/model/purchase.dart';
import 'package:customer_app/view/mypage/chatting.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PurchaseList extends StatefulWidget {
  const PurchaseList({super.key});

  @override
  State<PurchaseList> createState() => _PurchaseListState();
}

class PurchaseRow {
  final Purchase purchase;
  final String? productName;
  final String? imageUrl; // 또는 path

  PurchaseRow({
    required this.purchase,
    required this.productName,
    required this.imageUrl,
  });
}

class _PurchaseListState extends State<PurchaseList> {
  //  Property
  List<PurchaseRow> totalPurchases = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final cid = 1;
    try {
      final rows = await setPurchaseList(cid);
      if (!mounted) return;
      setState(() {
        totalPurchases = rows;
        isLoading = false;
      });
    } catch (e, st) {
      debugPrint('PurchaseList load error: $e\n$st');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<PurchaseRow>> setPurchaseList(int cid) async {
    final purchases = (await config.getJSONData(
      'purchase/select?cid=$cid',
    )).cast<Purchase>();
    final rows = <PurchaseRow>[];

    for (final p in purchases) {
      final namesRaw = await config.getJSONData(
        'productname/select?pid=${p.pid}',
      );
      String? name;
      if (namesRaw.isNotEmpty) {
        final first = namesRaw.first;
        if (first is Map && first['name'] != null) {
          name = first['name'].toString();
        } else if (first is List && first.isNotEmpty) {
          name = first[0].toString();
        } else {
          name = first.toString();
        }
      }

      final imageUrl =
          'http://${config.hostip}:8008/productimage/view?pid=${p.pid}&position=main';

      rows.add(PurchaseRow(purchase: p, productName: name, imageUrl: imageUrl));
    }

    return rows;
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : totalPurchases.isEmpty
          ? Center(child: Text('구매 내역이 없습니다.'))
          : ListView.builder(
              itemCount: totalPurchases.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 180,
                  child: Card(
                    color: Colors.white,
                    child: Row(
                      children: [
                        Image.network(
                          totalPurchases[index].imageUrl ?? '',
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  10,
                                  30,
                                  0,
                                  0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      '${totalPurchases[index].productName}',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    Text(
                                      '${config.formatter.format(totalPurchases[index].purchase.quantity)}개',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    Text(
                                      '총 구매액: ${config.formatter.format(totalPurchases[index].purchase.finalprice)}',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    '구매 날짜: ${DateFormat(config.dateFormat).format(totalPurchases[index].purchase.purchasedate)}',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 100,
                                      height: 35,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          final row = totalPurchases[index];
                                          Get.to(
                                            const Chatting(),
                                            arguments: {
                                              'pcid': row
                                                  .purchase
                                                  .id, // 구매 PK (pcid로 쓸 값)
                                              'productName':
                                                  row.productName ?? '상품',
                                            },
                                          )?.then((_) => setState(() {}));
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          elevation: 1,
                                        ),
                                        child: Text(
                                          '문의 하기',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    '수령 날짜: ${DateFormat(config.dateFormat).format(totalPurchases[index].purchase.pickupdate!)}',
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

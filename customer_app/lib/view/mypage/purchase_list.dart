import 'dart:convert';

import 'package:customer_app/config.dart' as config;
import 'package:customer_app/model/customer.dart';
import 'package:customer_app/model/purchase.dart';
import 'package:customer_app/model/usercontroller.dart';
import 'package:customer_app/view/mypage/board_review.dart';
import 'package:customer_app/view/mypage/chatting.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PurchaseList extends StatefulWidget {
  const PurchaseList({super.key});

  @override
  State<PurchaseList> createState() => _PurchaseListState();
}

class PurchaseRow {
  final Purchase purchase;
  final String? productName;
  final String imageUrl;

  PurchaseRow({
    required this.purchase,
    required this.productName,
    required this.imageUrl,
  });
}

class _PurchaseListState extends State<PurchaseList> {
  List<PurchaseRow> totalPurchases = [];
  bool isLoading = true;
  late Customer customer;
  final UserController userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();

    customer =
        userController.user ??
        Customer(
          id: 1,
          email: 'email',
          password: 'password',
          name: 'name',
          phone: 'phone',
          date: DateTime.now(),
          address: 'address',
        );

    _init();
  }

  Future<void> _init() async {
    final cid = customer.id;
    if (cid == null) {
      setState(() {
        totalPurchases = [];
        isLoading = false;
      });
      return;
    }

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
      setState(() => isLoading = false);
    }
  }

  /// getJSONData가 "List"를 주든, {"results": List}를 주든 안전 처리
  List<dynamic> _unwrapList(dynamic raw) {
    if (raw is List) return raw;
    if (raw is Map && raw['results'] is List) return raw['results'] as List;
    return const [];
  }

  Future<List<dynamic>> getJSONData(String page) async {
    var url = Uri.parse("http://${config.hostip}:8008/$page");
    var response = await http.get(url);

    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataConvertedJSON["results"];
    return result;
  }

  Future<List<PurchaseRow>> setPurchaseList(int cid) async {
    final raw = await getJSONData('purchase/selectcustomer?cid=$cid');
    final list = _unwrapList(raw);

    final purchases = list
        .whereType<Map>()
        .map((e) => Purchase.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    // 병렬로 productname 조회 (속도 개선)
    final futures = purchases.map((p) async {
      String? name;

      try {
        final namesRaw = await config.getJSONData(
          'productname/select?pid=${p.pid}',
        );
        final namesList = _unwrapList(namesRaw);

        if (namesList.isNotEmpty) {
          final first = namesList.first;
          if (first is Map && first['name'] != null) {
            name = first['name'].toString();
          } else {
            name = first.toString();
          }
        }
      } catch (_) {
        // 이름 조회 실패해도 목록은 뜨게 둠
      }

      final imageUrl =
          'http://${config.hostip}:8008/productimage/view?pid=${p.pid}&position=main';

      return PurchaseRow(purchase: p, productName: name, imageUrl: imageUrl);
    }).toList();

    return await Future.wait(futures);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "구매 목록",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade300),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : totalPurchases.isEmpty
          ? const Center(child: Text('구매 내역이 없습니다.'))
          : ListView.builder(
              itemCount: totalPurchases.length,
              itemBuilder: (context, index) {
                final row = totalPurchases[index];
                final p = row.purchase;

                final pickUpText = (p.pickupdate == null)
                    ? '미수령'
                    : DateFormat(config.dateFormat).format(p.pickupdate!);

                return SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 180,
                  child: Card(
                    color: Colors.white,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Image.network(
                            row.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image_not_supported),
                          ),
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
                                      row.productName ?? '(이름 없음)',
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                    Text(
                                      '${config.formatter.format(p.quantity)}개',
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                    Text(
                                      '총 구매액: ${config.formatter.format(p.finalprice)}',
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    '구매 날짜: ${DateFormat(config.dateFormat).format(p.purchasedate)}',
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 100,
                                      height: 35,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Get.to(
                                            const Chatting(),
                                            arguments: row,
                                          )?.then((_) => setState(() {}));
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          elevation: 1,
                                        ),
                                        child: const Text(
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
                                    '수령 날짜: $pickUpText',
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 100,
                                      height: 35,
                                      child: ElevatedButton(
                                        onPressed: p.pickupdate == null
                                            ? null
                                            : () {
                                                Get.to(
                                                  const BoardReview(),
                                                  arguments: row,
                                                )?.then((_) => setState(() {}));
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          elevation: 1,
                                        ),
                                        child: const Text(
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

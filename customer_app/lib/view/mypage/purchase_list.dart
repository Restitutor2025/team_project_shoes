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
  final List<PurchaseRow> totalPurchases = [];
  bool isLoading = true;

  String? loadError;

  late Customer customer;
  late final UserController userController;

  @override
  void initState() {
    super.initState();

    userController = Get.isRegistered<UserController>()
        ? Get.find<UserController>()
        : UserController();

    final u = userController.user;
    if (u == null) {
      customer = Customer(
        id: null,
        email: '',
        password: '',
        name: '',
        phone: '',
        date: DateTime.now(),
        address: '',
      );
      setState(() {
        isLoading = false;
        loadError = '로그인이 필요합니다.';
      });
      return;
    }

    customer = u;
    _init();
  }

  Future<void> _init() async {
    final cid = customer.id;
    if (cid == null) {
      setState(() {
        isLoading = false;
        loadError = '고객 ID가 없습니다.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      loadError = null;
    });

    try {
      final rows = await _setPurchaseList(cid);
      if (!mounted) return;
      setState(() {
        totalPurchases
          ..clear()
          ..addAll(rows);
        isLoading = false;
      });
    } catch (e, st) {
      debugPrint('PurchaseList load error: $e\n$st');
      if (!mounted) return;
      setState(() {
        isLoading = false;
        loadError = e.toString();
      });
    }
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

  Future<List<PurchaseRow>> _setPurchaseList(int cid) async {
    final purchaseList = await _getList('purchase/selectcustomer?cid=$cid');

    final purchases = <Purchase>[];
    for (final item in purchaseList) {
      if (item is Map) {
        try {
          purchases.add(Purchase.fromJson(Map<String, dynamic>.from(item)));
        } catch (e) {
          debugPrint('Purchase.fromJson parse error: $e | item=$item');
        }
      }
    }

    final futures = purchases.map((p) async {
      String? name;

      try {
        final names = await _getList('productname/select?pid=${p.pid}');
        if (names.isNotEmpty) {
          final first = names.first;
          if (first is Map) {
            name = (first['name'] ?? first['pname'] ?? first['product_name'])
                ?.toString();
          } else {
            name = first.toString();
          }
        }
      } catch (e) {
        debugPrint('productname load error: $e');
      }

      final imageUrl =
          'http://${config.hostip}:8008/productimage/view?pid=${p.pid}&position=main';

      return PurchaseRow(
        purchase: p,
        productName: name,
        imageUrl: imageUrl,
      );
    }).toList();

    return Future.wait(futures);
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (loadError != null) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 40),
              const SizedBox(height: 10),
              Text(
                loadError!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _init,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    } else if (totalPurchases.isEmpty) {
      body = const Center(child: Text('구매 내역이 없습니다.'));
    } else {
      body = ListView.builder(
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
                          padding: const EdgeInsets.fromLTRB(10, 30, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
      );
    }

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
      body: body,
    );
  }
}

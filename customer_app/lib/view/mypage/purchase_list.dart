import 'dart:convert';

import 'package:customer_app/config.dart' as config;
import 'package:customer_app/model/purchase.dart';
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
  final String? imageUrl;

  const PurchaseRow({
    required this.purchase,
    required this.productName,
    required this.imageUrl,
  });
}

class _PurchaseListState extends State<PurchaseList> {
  List<PurchaseRow> totalPurchases = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final int cid = (Get.arguments?['cid'] as int?) ?? 1;

    try {
      final rows = await _loadPurchaseRows(cid);
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

  /// 옵션 pid -> 대표 group_id (이미지/이름이 대표 pid에만 있는 구조 대응)
  Future<int> _resolveGroupId(int pid) async {
    try {
      final url = Uri.parse(
        'http://${config.hostip}:8008/product/selectdetail2?pid=$pid',
      );
      final res = await http.get(url);
      if (res.statusCode != 200) return pid;

      final decoded = json.decode(utf8.decode(res.bodyBytes));
      // 응답 형태가 { "group_id": ... } 인 케이스
      final gid = decoded is Map ? decoded['group_id'] : null;
      if (gid == null) return pid;

      final parsed = int.tryParse(gid.toString());
      return parsed ?? pid;
    } catch (e) {
      debugPrint('resolveGroupId error (pid=$pid): $e');
      return pid;
    }
  }

  Future<List<PurchaseRow>> _loadPurchaseRows(int cid) async {
    // 1) purchases 로딩
    final raw = await config.getJSONData('purchase/select?cid=$cid');

    List<Purchase> purchases = raw.whereType<Purchase>().toList();
    if (purchases.isEmpty) {
      purchases = raw
          .whereType<Map>()
          .map((e) => Purchase.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    if (purchases.isEmpty) return <PurchaseRow>[];

    // 2) pid -> groupId 매핑 (병렬)
    final Map<int, int> groupIdByPid = {};
    await Future.wait(
      purchases.map((p) async {
        groupIdByPid[p.pid] = await _resolveGroupId(p.pid);
      }),
    );

    // 3) product name은 groupId 기준으로 가져오기 (캐싱 + 병렬)
    final Map<int, String?> nameByGroupId = {};
    final uniqueGroupIds = groupIdByPid.values.toSet().toList();

    Future<String?> fetchName(int pid) async {
      try {
        final namesRaw = await config.getJSONData(
          'productname/select?pid=$pid',
        );
        if (namesRaw.isEmpty) return null;

        final first = namesRaw.first;

        // Name 모델로 파싱된 경우
        // ignore: avoid_dynamic_calls
        if (first is dynamic) {
          try {
            // ignore: avoid_dynamic_calls
            final v = (first as dynamic).name;
            if (v != null) return v.toString();
          } catch (_) {}
        }

        if (first is Map) return first['name']?.toString();
        if (first is List && first.isNotEmpty) return first.first?.toString();
        return first.toString();
      } catch (e) {
        debugPrint('ProductName load error (pid=$pid): $e');
        return null;
      }
    }

    await Future.wait(
      uniqueGroupIds.map((gid) async {
        nameByGroupId[gid] = await fetchName(gid);
      }),
    );

    // 4) rows 조립 (이미지/이름 모두 groupId 기준)
    return purchases.map((p) {
      final gid = groupIdByPid[p.pid] ?? p.pid;

      final imageUrl =
          'http://${config.hostip}:8008/productimage/view?pid=$gid&position=main';

      return PurchaseRow(
        purchase: p,
        productName: nameByGroupId[gid],
        imageUrl: imageUrl,
      );
    }).toList();
  }

  String _fmtMoney(dynamic value) {
    final n = num.tryParse(value?.toString() ?? '');
    if (n == null) return value?.toString() ?? '';
    return NumberFormat('#,###').format(n);
  }

  String _fmtDate(dynamic value) {
    if (value == null) return '';
    if (value is DateTime) return DateFormat('yyyy-MM-dd').format(value);
    final s = value.toString();
    final dt = DateTime.tryParse(s);
    if (dt != null) return DateFormat('yyyy-MM-dd').format(dt);
    return s;
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

                return SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 180,
                  child: Card(
                    color: Colors.white,
                    child: Row(
                      children: [
                        Image.network(
                          row.imageUrl ?? '',
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stack) {
                            debugPrint(
                              'Image load failed: ${row.imageUrl} / $error',
                            );
                            return const SizedBox(
                              width: 50,
                              height: 50,
                              child: Icon(Icons.image_not_supported_outlined),
                            );
                          },
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
                                      row.productName ?? '상품',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "${row.purchase.quantity}개",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(10, 5, 0, 0),
                                child: Row(
                                  children: [
                                    Text(
                                      "주문 금액: ${_fmtMoney(row.purchase.finalprice)}원",
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(10, 5, 0, 0),
                                child: Row(
                                  children: [
                                    Text(
                                      "픽업 날짜: ${_fmtDate(row.purchase.pickupdate)}",
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(10, 5, 0, 0),
                                child: Row(
                                  children: [
                                    Text(
                                      "구매 날짜: ${_fmtDate(row.purchase.purchasedate)}",
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  10,
                                  10,
                                  0,
                                  0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      width: 100,
                                      height: 35,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Get.to(
                                            const Chatting(),
                                            arguments: {
                                              'pcid': row.purchase.id,
                                              'productName':
                                                  row.productName ?? '상품',
                                            },
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
                                    SizedBox(
                                      width: 100,
                                      height: 35,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          // TODO: 리뷰 화면 연결
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
                                  ],
                                ),
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

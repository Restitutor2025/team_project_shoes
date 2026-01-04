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
    // ✅ Restitutor 브랜치 방식 유지: arguments로 cid 받되 없으면 1
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

  Future<List<PurchaseRow>> _loadPurchaseRows(int cid) async {
    // 1) purchases 로딩 (config.dart에서 key 추출하도록 고친 상태 가정)
    final raw = await config.getJSONData('purchase/selectcustomer?cid=$cid');

    // config.dart가 Purchase로 파싱해준 경우
    List<Purchase> purchases = raw.whereType<Purchase>().toList();

    // 혹시 Map으로 들어오는 경우 대비 (안전장치)
    if (purchases.isEmpty) {
      purchases = raw
          .whereType<Map>()
          .map((e) => Purchase.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    if (purchases.isEmpty) return <PurchaseRow>[];

    // 2) 상품명 pid별 캐싱 + 병렬 호출
    final Map<int, String?> nameByPid = {};
    final uniquePids = purchases.map((p) => p.pid).toSet().toList();

    Future<String?> fetchName(int pid) async {
      try {
        final namesRaw = await config.getJSONData('productname/select?pid=$pid');
        if (namesRaw.isEmpty) return null;

        final first = namesRaw.first;

        // Name 모델로 파싱된 경우 (config.dart에서 productname을 name으로 처리했을 수도 있음)
        // ignore: avoid_dynamic_calls
        if (first is dynamic) {
          try {
            // ignore: avoid_dynamic_calls
            final v = (first as dynamic).name;
            if (v != null) return v.toString();
          } catch (_) {}
        }

        // Map 형태인 경우
        if (first is Map) {
          final v = first['name'];
          return v?.toString();
        }

        // List 형태인 경우
        if (first is List && first.isNotEmpty) {
          return first.first?.toString();
        }

        return first.toString();
      } catch (e) {
        debugPrint('ProductName load error (pid=$pid): $e');
        return null;
      }
    }

    await Future.wait(uniquePids.map((pid) async {
      nameByPid[pid] = await fetchName(pid);
    }));

    // 3) PurchaseRow 조립
    return purchases.map((p) {
      final imageUrl =
          'http://${config.hostip}:8008/productimage/view?pid=${p.pid}&position=main';

      return PurchaseRow(
        purchase: p,
        productName: nameByPid[p.pid],
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
    // pickupdate가 DateTime일 수도, String일 수도 있어서 전부 대응
    if (value is DateTime) {
      return DateFormat('yyyy-MM-dd').format(value);
    }
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
                              errorBuilder: (_, __, ___) => const SizedBox(
                                width: 50,
                                height: 50,
                                child: Icon(Icons.image_not_supported_outlined),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 30, 0, 0),
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
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 5, 0, 0),
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
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 5, 0, 0),
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
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 5, 0, 0),
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
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 10, 0, 0),
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
                                                  // ✅ pcid는 purchase PK
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

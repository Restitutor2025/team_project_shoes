import 'dart:convert';

import 'package:customer_app/config.dart' as config;
import 'package:customer_app/model/purchase.dart';
import 'package:customer_app/model/usercontroller.dart';
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

  late final UserController userController;

  @override
  void initState() {
    super.initState();
    userController = Get.find<UserController>();
    _init();
  }

  Future<void> _init() async {
    // 유저별 구매목록: arguments cid 우선, 없으면 로그인 유저 id, 그래도 없으면 1
    final int? argCid = Get.arguments?['cid'] as int?;
    final int? loginCid = userController.user?.id;
    final int cid = argCid ?? loginCid ?? 1;

    debugPrint(
      'PurchaseList cid=$cid args=${Get.arguments} user=${userController.user?.id}',
    );

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
      setState(() => isLoading = false);
    }
  }

  /// 옵션 pid -> 대표 group_id (이미지/이름이 대표 pid(group_id)에만 있는 구조 대응)
  Future<int> _resolveGroupId(int pid) async {
    try {
      final url = Uri.parse('http://${config.hostip}:8008/product/selectdetail2?pid=$pid');
      final res = await http.get(url);
      if (res.statusCode != 200) return pid;

      final decoded = json.decode(utf8.decode(res.bodyBytes));

      // {"results": [...], "group_id": ...}
      if (decoded is Map && decoded['group_id'] != null) {
        return int.tryParse(decoded['group_id'].toString()) ?? pid;
      }

      // 혹시 {"results":[{...,"group_id":...}]} 같은 케이스 방어
      if (decoded is Map &&
          decoded['results'] is List &&
          (decoded['results'] as List).isNotEmpty) {
        final first = (decoded['results'] as List).first;
        if (first is Map && first['group_id'] != null) {
          return int.tryParse(first['group_id'].toString()) ?? pid;
        }
      }

      return pid;
    } catch (e) {
      debugPrint('resolveGroupId error (pid=$pid): $e');
      return pid;
    }
  }

  /// ✅ productname/select 응답은 pid가 없어서 Name.fromJson이 깨질 수 있음
  /// 그래서 config.getJSONData를 쓰지 말고, 여기서 직접 파싱해서 name만 뽑자.
  Future<String?> _fetchProductNameDirect(int pidOrGroupId) async {
    try {
      final url = Uri.parse('http://${config.hostip}:8008/productname/select?pid=$pidOrGroupId');
      final res = await http.get(url);
      if (res.statusCode != 200) return null;

      final decoded = json.decode(utf8.decode(res.bodyBytes));
      if (decoded is! Map) return null;

      final results = decoded['results'];
      if (results is! List || results.isEmpty) return null;

      final first = results.first;
      if (first is Map && first['name'] != null) return first['name'].toString();

      return null;
    } catch (e) {
      debugPrint('productname/select parse error (pid=$pidOrGroupId): $e');
      return null;
    }
  }

  /// 보조 플랜: product/selectdetail2 결과에 product_name이 붙어오는 구조면 거기서 꺼내기
  Future<String?> _fetchNameFromSelectDetail2(int pidOrGroupId) async {
    try {
      final url = Uri.parse('http://${config.hostip}:8008/product/selectdetail2?pid=$pidOrGroupId');
      final res = await http.get(url);
      if (res.statusCode != 200) return null;

      final decoded = json.decode(utf8.decode(res.bodyBytes));
      if (decoded is! Map) return null;

      final results = decoded['results'];
      if (results is! List || results.isEmpty) return null;

      final first = results.first;
      if (first is Map) {
        final v = first['product_name'] ?? first['name'];
        return v?.toString();
      }
      return null;
    } catch (e) {
      debugPrint('selectdetail2 name fallback error (pid=$pidOrGroupId): $e');
      return null;
    }
  }

  Future<List<PurchaseRow>> _loadPurchaseRows(int cid) async {
    // ✅ mypage 카운트랑 동일 라우트로 통일 (서버 구현 확실한 쪽)
    final raw = await config.getJSONData('purchase/selectcustomer?cid=$cid');

    // config.dart가 Purchase로 파싱해준 경우
    List<Purchase> purchases = raw.whereType<Purchase>().toList();

    // 혹시 Map으로 들어오는 경우 대비
    if (purchases.isEmpty) {
      purchases = raw
          .whereType<Map>()
          .map((e) => Purchase.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    if (purchases.isEmpty) return <PurchaseRow>[];

    // 1) pid -> groupId 매핑 (병렬)
    final Map<int, int> groupIdByPid = {};
    await Future.wait(
      purchases.map((p) async {
        groupIdByPid[p.pid] = await _resolveGroupId(p.pid);
      }),
    );

    // 2) 상품명은 groupId 기준으로 가져오기 (캐싱 + 병렬)
    final Map<int, String?> nameByGroupId = {};
    final uniqueGroupIds = groupIdByPid.values.toSet().toList();

    await Future.wait(
      uniqueGroupIds.map((gid) async {
        // 1차: productname/select 직접 파싱
        String? name = await _fetchProductNameDirect(gid);

        // 2차: selectdetail2 결과에서 product_name fallback
        name ??= await _fetchNameFromSelectDetail2(gid);

        nameByGroupId[gid] = name;
      }),
    );

    // 3) rows 조립 (이미지/이름 모두 groupId 기준)
    return purchases.map((p) {
      final int gid = groupIdByPid[p.pid] ?? p.pid;

      final String imageUrl =
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
                                debugPrint('Image load failed: ${row.imageUrl} / $error');
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
                                    padding: const EdgeInsets.fromLTRB(10, 30, 0, 0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                    child: Text(
                                      "주문 금액: ${_fmtMoney(row.purchase.finalprice)}원",
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(10, 5, 0, 0),
                                    child: Text(
                                      "픽업 날짜: ${_fmtDate(row.purchase.pickupdate)}",
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(10, 5, 0, 0),
                                    child: Text(
                                      "구매 날짜: ${_fmtDate(row.purchase.purchasedate)}",
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                                  'productName': row.productName ?? '상품',
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

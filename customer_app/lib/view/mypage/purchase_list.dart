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
    // 유저별 cid: arguments 우선, 없으면 로그인 유저 id, 그래도 없으면 1
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

      // 1) {"group_id": ...}
      if (decoded is Map && decoded['group_id'] != null) {
        return int.tryParse(decoded['group_id'].toString()) ?? pid;
      }

      // 2) {"results":[{...,"group_id":...}]}
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

  Future<List<PurchaseRow>> _loadPurchaseRows(int cid) async {
    // ✅ mypage 카운트랑 동일 라우트 사용 (서버 구현 확실한 쪽)
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

    Future<String?> fetchName(int pidOrGroupId) async {
      try {
        final namesRaw = await config.getJSONData(
          'productname/select?pid=$pidOrGroupId',
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
        debugPrint('ProductName load error (pid=$pidOrGroupId): $e');
        return null;
      }
    }

    await Future.wait(
      uniqueGroupIds.map((gid) async {
        nameByGroupId[gid] = await fetchName(gid);
      }),
    );

    // 3) rows 조립 (이미지/이름 모두 groupId 기준)
    return purchases.map((p) {
      final int gid = groupIdByPid[p.pid] ?? p.pid;

      final imageUrl =
          'http://${config.hostip}:8

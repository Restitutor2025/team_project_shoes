import 'dart:developer';

import 'package:brand_app/util/pcolor.dart';
import 'package:brand_app/view/purchase_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PurchaseSummary {
  final int pcid;
  final int cid;
  final String cemail;
  final String cname;
  final String pname;
  final int finalprice;
  final int size;
  final String color;
  final int quantity;
  final String sname;
  final int? rid;
  final DateTime? purchasedate;
  final DateTime? pickupdate;
  final DateTime? refunddate;

  PurchaseSummary({
    required this.pcid,
    required this.cid,
    required this.cemail,
    required this.cname,
    required this.pname,
    required this.finalprice,
    required this.size,
    required this.color,
    required this.quantity,
    required this.sname,
    this.rid,
    this.purchasedate,
    this.pickupdate,
    this.refunddate,
  });

  factory PurchaseSummary.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      return DateTime.parse(v.toString());
    }

    return PurchaseSummary(
      pcid: json['pcid'] as int,
      cid: json['cid'] as int,
      cemail: json['cemail'] as String,
      cname: json['cname'] as String,
      pname: json['pname'] as String,
      finalprice: json['finalprice'] as int,
      size: json['size'] as int,
      color: json['color'] as String,
      quantity: json['quantity'] as int,
      sname: json['sname'] as String,
      rid: json['rid'] as int?,
      purchasedate: parseDate(json['purchasedate']),
      pickupdate: parseDate(json['pickupdate']),
      refunddate: parseDate(json['refunddate']),
    );
  }

  Map<String, dynamic> toJson() {

    return {
      'pcid': pcid,
      'cid': cid,
      'cemail': cemail,
      'cname': cname,
      'pname': pname,
      'finalprice': finalprice,
      'size': size,
      'color': color,
      'quantity': quantity,
      'sname': sname,
      'rid': rid,
      'purchasedate': purchasedate!.toIso8601String(),
      'pickupdate': pickupdate!.toIso8601String(),
      'refunddate': refunddate!.toIso8601String(),
    };
  }
}

class PurchaseView extends StatefulWidget {
  const PurchaseView({super.key});

  @override
  State<PurchaseView> createState() => _PurchaseViewState();
}

class _PurchaseViewState extends State<PurchaseView> {
  TextEditingController searchController = TextEditingController();

  String currentStatus(Map<String, Object?> item) {
    final hasPurchaseDate = item['purchasedate'] != null;
    final hasPickupDate = item['pickupdate'] != null;

    final hasRefundId = item['rid'] != null; 
    final hasRefundDate = item['refunddate'] != null;

    if (hasRefundId && hasRefundDate) {
      return '반품완료';
    }
    if (hasRefundId) {
      return '반품대기';
    }
    if (hasPurchaseDate && hasPickupDate) {
      return '수령완료';
    }
    if (hasPurchaseDate) {
      return '수령대기';
    }
    return '알수없음';
  }

  String formatDate(dynamic x) {
    if (x == null) return '-';
    if (x is DateTime) {
      return DateFormat('yyyy-MM-dd HH:mm').format(x);
    }
    try {
      final parsed = DateTime.parse(x.toString());
      return DateFormat('yyyy-MM-dd HH:mm').format(parsed);
    } catch (e) {
      log('date parse error: $e');
      return x.toString();
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case '알수없음':
        return Colors.blueGrey;
      case '수령대기':
        return Colors.blue;
      case '수령완료':
        return Colors.green;
      case '반품대기':
        return Colors.orange;
      case '반품완료':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // 더미 데이터
  final Map<String, Object?> pc1 = {
    "pcid": 1,
    "cid": 1,
    "cemail": 'kimbobbbbb@xyz.com',
    "cname": '김밥',
    "pname": '나이키 아디다스',
    "finalprice": 540000,
    "size": 245,
    "color": 'White',
    "quantity": 3,
    "sname": '강북점',
    "rid": null,
    "purchasedate": DateTime(2026, 1, 1, 18, 00, 00),
    "pickupdate": DateTime(2026, 1, 2, 18, 00, 00),
    "refunddate": null,
  };

  final Map<String, Object?> pc2 = {
    "pcid": 2,
    "cid": 2,
    "cemail": 'stststst@iii.com',
    "cname": '앤서니키디스',
    "pname": '나이키 아디다스',
    "finalprice": 600000,
    "size": 255,
    "color": 'White',
    "quantity": 4,
    "sname": '강남점',
    "rid": 1,
    "purchasedate": DateTime(2026, 1, 2, 18, 00, 00),
    "pickupdate": DateTime(2026, 1, 3, 14, 30, 00),
    "refunddate": DateTime(2026, 1, 7, 16, 00, 00),
  };

  final Map<String, Object?> pc3 = {
    "pcid": 3,
    "cid": 3,
    "cemail": '348957340@uyssre.com',
    "cname": '지미페이지',
    "pname": '나이키 아디다스',
    "finalprice": 400000,
    "size": 270,
    "color": 'Red',
    "quantity": 2,
    "sname": '송파점',
    "rid": 2,
    "purchasedate": DateTime(2025, 12, 30, 18, 00, 00),
    "pickupdate": DateTime(2026, 1, 1, 11, 00, 00),
    "refunddate": null,
  };

  final Map<String, Object?> pc4 = {
    "pcid": 4,
    "cid": 4,
    "cemail": 'asdas34as@neves.com',
    "cname": '데이비드길모어',
    "pname": '나이키 아디다스',
    "finalprice": 540000,
    "size": 235,
    "color": 'White',
    "quantity": 3,
    "sname": '마포점',
    "rid": null,
    "purchasedate": DateTime(2026, 1, 4, 18, 00, 00),
    "pickupdate": null,
    "refunddate": null,
  };

  final Map<String, Object?> pc5 = {
    "pcid": 5,
    "cid": 5,
    "cemail": '390dfs909fd@kingfd.com',
    "cname": '크리스마틴',
    "pname": '나이키 아디다스',
    "finalprice": 140000,
    "size": 245,
    "color": 'White',
    "quantity": 1,
    "sname": '구로점',
    "rid": null,
    "purchasedate": DateTime(2026, 1, 1, 12, 00, 00),
    "pickupdate": DateTime(2026, 1, 3, 10, 00, 00),
    "refunddate": null,
  };

  late final List<Map<String, Object?>> data;

  @override
  void initState() {
    super.initState();
    data = [pc1, pc2, pc3, pc4, pc5]; // 더미
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('주문 조회'),
        backgroundColor: Pcolor.appBarBackgroundColor,
        foregroundColor: Pcolor.appBarForegroundColor,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: '주문 검색',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  color: Colors.black,
                  onPressed: () {},
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final item = data[index];
                  final String status = currentStatus(item);

                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item['cemail'].toString(),
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(right: 8),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('이름 : ${item['cname']}'),
                                              Text('구매번호 : ${item['pcid']}'),
                                              Text('제품명 : ${item['pname']}', overflow: TextOverflow.ellipsis),
                                              Text('주문날짜 : ${formatDate(item['purchasedate'])}'),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 8),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('주문금액 : ${item['finalprice']}'),
                                              Text('사이즈 : ${item['size']}'),
                                              Text('색상 : ${item['color']}'),
                                              Text('수량 : ${item['quantity']}'),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 15, 0, 20),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: _statusColor(status).withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: _statusColor(status), width: 0.7),
                                      ),
                                      child: Text(
                                        status,
                                        style: TextStyle(
                                          color: _statusColor(status),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: ElevatedButton(
                                      onPressed: () => Get.to(
                                        PurchaseDetailView(),
                                        arguments: item,
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5)
                                        ),
                                      ),
                                      child: Text('자세히 보기'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:developer';

import 'package:brand_app/util/pcolor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PurchaseDetailView extends StatefulWidget {
  const PurchaseDetailView({super.key});

  @override
  State<PurchaseDetailView> createState() => _PurchaseDetailViewState();
}

class _PurchaseDetailViewState extends State<PurchaseDetailView> {
  // Property
  var value = Get.arguments ?? "__";

  String formatDate(dynamic x) {
    if (x == null) return '-';

    if (x is DateTime) {
      return DateFormat('yyyy-MM-dd HH:mm').format(x);
    }

    try {
      final parsed = DateTime.parse(x.toString());
      return DateFormat('yyyy-MM-dd HH:mm').format(parsed);
    } catch (e) {
      log('date parse error (detail): $e');
      return x.toString();
    }
  }

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

  @override
  Widget build(BuildContext context) {

    if (value is! Map<String, dynamic>) {
      return Scaffold(
        appBar: AppBar(
          title: Text('자세히 보기'),
          backgroundColor: Pcolor.appBarBackgroundColor,
          foregroundColor: Pcolor.appBarForegroundColor,
          centerTitle: true,
        ),
        body: Center(
          child: Text('주문 정보를 불러올 수 없습니다.'),
        ),
      );
    }

    final Map<String, dynamic> data = value as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text('자세히 보기'),
        backgroundColor: Pcolor.appBarBackgroundColor,
        foregroundColor: Pcolor.appBarForegroundColor,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      data['cemail']?.toString() ?? '-',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _statusColor((currentStatus(data).toString())).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: _statusColor((currentStatus(data).toString())),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      (currentStatus(data).toString()).isEmpty ? '상태 없음' : (currentStatus(data).toString()),
                                      style: TextStyle(
                                        color: _statusColor((currentStatus(data).toString())),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
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
                                    padding: const EdgeInsets.fromLTRB(0, 0, 8, 4),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 2),
                                          child: Text('이름 : ${data['cname'] ?? '-'}'),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 2),
                                          child: Text('제품명 : ${data['pname']?.toString() ?? '-'}'),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 2),
                                          child: Text('구매번호 : ${data['pcid'] ?? '-'}'),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 2),
                                          child: Text('주문날짜 : ${formatDate(data['purchasedate'])}'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8, bottom: 4),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 2),
                                          child: Text('주문금액 : ${data['finalprice'] ?? '-'}')),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 2),
                                          child: Text('사이즈 : ${data['size'] ?? '-'}')),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 2),
                                          child: Text('색상 : ${data['color'] ?? '-'}')),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 2),
                                          child: Text('수량 : ${data['quantity'] ?? '-'}')),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 8),
                      child: Text(
                        '수령 · 반품 정보',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if ((currentStatus(data).toString()) == '주문완료' || (currentStatus(data).toString()) == '수령대기')
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text('수령지점 : ${data['sname']?.toString() ?? '-'}'),
                              ),

                            if ((currentStatus(data).toString()) == '수령완료' ||
                                (currentStatus(data).toString()) == '반품대기' ||
                                (currentStatus(data).toString()) == '반품완료') ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text('수령지점 : ${data['sname']?.toString() ?? '-'}'),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text('수령날짜 : ${formatDate(data['pickupdate'])}'),
                              ),
                            ],

                            if ((currentStatus(data).toString()) == '반품대기' || (currentStatus(data).toString()) == '반품완료')
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text('반품지점 : ${data['sname']?.toString() ?? '-'}'),
                              ),

                            if ((currentStatus(data).toString()) == '반품완료')
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text('반품날짜 : ${formatDate(data['refunddate'])}'),
                              ),

                            if (!((currentStatus(data).toString()) == '주문완료' ||
                                (currentStatus(data).toString()) == '수령대기' ||
                                (currentStatus(data).toString()) == '수령완료' ||
                                (currentStatus(data).toString()) == '반품대기' ||
                                (currentStatus(data).toString()) == '반품완료'))
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  '추가 수령/반품 정보가 없습니다.',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:developer';

import 'package:brand_app/ip/ipaddress.dart'; // ✅ 추가: 이미지 URL에 사용
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
  // var value = Get.arguments ?? "__";          // ❌ 사용 방식 변경
  late final Map<String, dynamic> data;          // ✅ 추가: arguments를 Map으로 보관
  late final String status;                      // ✅ 추가: 상태를 한 번만 계산

  @override
  void initState() {
    super.initState();
    final value = Get.arguments;
    if (value is Map<String, dynamic>) {
      data = value;
    } else {
      data = <String, dynamic>{};
      log('PurchaseDetailView: 잘못된 arguments 타입: ${value.runtimeType}');
    }
    status = currentStatus(data); // ✅ 한 번만 계산해서 재사용
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
      log('date parse error (detail): $e');
      return x.toString();
    }
  }

  // ✅ 타입을 Map<String, dynamic>으로 변경
  String currentStatus(Map<String, dynamic> item) {
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


  Widget _buildProductImage(BuildContext context) {
    final pid = data['pid'];

    double width = MediaQuery.of(context).size.width * 0.5;
    double height = 220.0;

    // pid 없으면 기존처럼 회색 박스
    if (pid == null) {
      return Container(
        width: MediaQuery.of(context).size.width * 0.5,
        height: 220,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
      );
    }
    
    final imageUrl = "${IpAddress.baseUrl}/productimage/view?pid=$pid&position=main";

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: width,
            height: height,
            alignment: Alignment.center,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.broken_image),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
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
                  child: _buildProductImage(context),
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
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _statusColor(status).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: _statusColor(status),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      status.isEmpty ? '상태 없음' : status,
                                      style: TextStyle(
                                        color: _statusColor(status),
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
                                          child: Text('주문금액 : ${data['finalprice'] ?? '-'}'),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 2),
                                          child: Text('사이즈 : ${data['size'] ?? '-'}'),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 2),
                                          child: Text('색상 : ${data['color'] ?? '-'}'),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 2),
                                          child: Text('수량 : ${data['quantity'] ?? '-'}'),
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
                            if (status == '주문완료' || status == '수령대기')
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text('수령지점 : ${data['sname']?.toString() ?? '-'}'),
                              ),
                            if (status == '수령완료' ||
                                status == '반품대기' ||
                                status == '반품완료') ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text('수령지점 : ${data['sname']?.toString() ?? '-'}'),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text('수령날짜 : ${formatDate(data['pickupdate'])}'),
                              ),
                            ],
                            if (status == '반품대기' || status == '반품완료')
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  '반품지점 : ${data['sname']?.toString() ?? '-'}',
                                ),
                              ),
                            if (status == '반품완료')
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text('반품날짜 : ${formatDate(data['refunddate'])}'),
                              ),
                            if (!(status == '주문완료' ||
                                status == '수령대기' ||
                                status == '수령완료' ||
                                status == '반품대기' ||
                                status == '반품완료'))
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
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

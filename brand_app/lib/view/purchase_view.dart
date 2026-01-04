import 'dart:convert';

import 'package:brand_app/ip/ipaddress.dart';
import 'package:brand_app/util/pcolor.dart';
import 'package:brand_app/view/purchase_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PurchaseSummary {
  final int pcid;
  final int pid;
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
    required this.pid,
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
      pcid: json['pcid'],
      pid: json['pid'],
      cid: json['cid'],
      cemail: json['cemail'],
      cname: json['cname'],
      pname: json['pname'],
      finalprice: json['finalprice'],
      size: json['size'],
      color: json['color'],
      quantity: json['quantity'],
      sname: json['sname'],
      rid: json['rid'],
      purchasedate: parseDate(json['purchasedate']),
      pickupdate: parseDate(json['pickupdate']),
      refunddate: parseDate(json['refunddate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pcid': pcid,
      'pid': pid,
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
      'purchasedate': purchasedate?.toIso8601String(),
      'pickupdate': pickupdate?.toIso8601String(),
      'refunddate': refunddate?.toIso8601String(),
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

  final List<String> _searchFields = ['고객이메일', '주문번호', '제품명'];
  String selectedSearchField = '고객이메일';

  final List<String> _statusOptions = [
    '전체',
    '수령대기',
    '수령완료',
    '반품대기',
    '반품완료',
    '알수없음',
  ];
  String selectedStatus = '전체';

  List<PurchaseSummary> data = [];
  List<PurchaseSummary> filteredData = [];
  bool _isLoading = true;

  String currentStatus(PurchaseSummary item) {
    final hasPurchaseDate = item.purchasedate != null;
    final hasPickupDate = item.pickupdate != null;

    final hasRefundId = item.rid != null;
    final hasRefundDate = item.refunddate != null;

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

  String formatDate(DateTime? x) {
    if (x == null) return '-';
    return DateFormat('yyyy-MM-dd HH:mm').format(x);
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
  void initState() {
    super.initState();
    loadPurchaseData();
  }

  Future<void> loadPurchaseData() async {
    var url = Uri.parse("${IpAddress.baseUrl}/purchase/selectSummary");
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        final decodeData = json.decode(utf8.decode(response.bodyBytes));
        List result = decodeData['results'];

        data = result.map((e) => PurchaseSummary.fromJson(e)).toList();
        filteredData = List.from(data);
      } else {
        print("loadPurchaseData statusCode: ${response.statusCode}");
      }
    } catch (e) {
      print("loadPurchaseData error: $e");
    } finally {
      _isLoading = false;
      setState(() {});
    }
  }

  void _applyFilters() {
    final query = searchController.text.trim();
    List<PurchaseSummary> temp = List.from(data);

    if (selectedStatus != '전체') {
      temp = temp.where((item) => currentStatus(item) == selectedStatus).toList();
    }

    if (query.isNotEmpty) {
      temp = temp.where((item) {
        switch (selectedSearchField) {
          case '고객이메일':
            return item.cemail.toLowerCase().contains(query.toLowerCase());
          case '주문번호':
            return item.pcid.toString().contains(query);
          case '제품명':
            return item.pname.toLowerCase().contains(query.toLowerCase());
          default:
            return true;
        }
      }).toList();
    }

    filteredData = temp;
    setState(() {});
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: DropdownButtonFormField<String>(
                      value: selectedSearchField,
                      items: _searchFields.map(
                              (f) => DropdownMenuItem<String>(
                                value: f,
                                child: Text(f, style: TextStyle(fontSize: 13)),
                              ),
                            ).toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        selectedSearchField = value;
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: '검색',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.search),
                            color: Colors.black,
                            onPressed: () => _applyFilters(),
                          ),
                        ),
                        onSubmitted: (_) => _applyFilters(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<String>(
                    value: selectedStatus,
                    items: _statusOptions.map(
                            (s) => DropdownMenuItem<String>(
                              value: s,
                              child: Text(s, style: const TextStyle(fontSize: 13)),
                            ),
                          ).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      selectedStatus = value;
                      setState(() {});
                      _applyFilters();
                    },
                  ),
                  Text(
                    '총 ${filteredData.length}건',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
        
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : (filteredData.isEmpty
                        ? Center(child: Text('검색 결과가 없습니다.'))
                        : ListView.builder(
                            itemCount: filteredData.length,
                            itemBuilder: (context, index) {
                              final PurchaseSummary item = filteredData[index];
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
                                        Padding(
                                          padding: const EdgeInsets.only(right: 12.0, top: 4),
                                          child: Text(
                                            '${index + 1}',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Expanded(
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
                                                              item.cemail,
                                                              style: TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 16,
                                                              ),
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
                                                                Text('이름 : ${item.cname}'),
                                                                Text('주문번호 : ${item.pcid}'),
                                                                Text('제품명 : ${item.pname}',
                                                                  overflow:TextOverflow.ellipsis,
                                                                ),
                                                                Text('주문날짜 : ${formatDate(item.purchasedate)}'),
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
                                                                Text('주문금액 : ${item.finalprice}'),
                                                                Text('사이즈 : ${item.size}'),
                                                                Text('색상 : ${item.color}'),
                                                                Text('수량 : ${item.quantity}'),
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
                                                          border: Border.all(
                                                            color: _statusColor(status),
                                                            width: 0.7,
                                                          ),
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
                                                          arguments: item.toJson(),
                                                        ),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.black,
                                                          foregroundColor: Colors.white,
                                                          shape:RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(5),
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
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

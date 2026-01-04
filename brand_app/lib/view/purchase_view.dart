import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:brand_app/ip/ipaddress.dart';

class PurchaseSummary {
  final int pcid, pid, mid, cid, finalprice, size, quantity;
  final String cemail, cname, pname, color, sname;
  final int? rid;
  final DateTime? purchasedate, pickupdate, refunddate;

  PurchaseSummary({
    required this.pcid, required this.pid, required this.mid, required this.cid,
    required this.cemail, required this.cname, required this.pname,
    required this.finalprice, required this.size,
    required this.color, required this.quantity, required this.sname,
    this.rid, this.purchasedate, this.pickupdate, this.refunddate,
  });

  factory PurchaseSummary.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null || v == "null" || v == "") return null;
      return DateTime.tryParse(v.toString());
    }

    return PurchaseSummary(
      pcid: json['pcid'] ?? 0,
      pid: json['pid'] ?? 0,
      mid: json['mid'] ?? 0, // ✅ mid 파싱 추가
      cid: json['cid'] ?? 0,
      cemail: json['cemail']?.toString() ?? "-",
      cname: json['cname']?.toString() ?? "-",
      pname: (json['pname'] ?? json['product_name'] ?? "상품명 없음").toString(),
      finalprice: json['finalprice'] ?? 0,
      size: int.tryParse(json['size']?.toString() ?? "0") ?? 0,
      color: json['color']?.toString() ?? "-",
      quantity: json['quantity'] ?? 0,
      sname: json['sname']?.toString() ?? "-",
      rid: json['rid'],
      purchasedate: parseDate(json['purchasedate']),
      pickupdate: parseDate(json['pickupdate']),
      refunddate: parseDate(json['refunddate']),
    );
  }

  Map<String, dynamic> toJson() => {
    'pcid': pcid, 'pid': pid, 'mid': mid, 'cid': cid, 'cemail': cemail, 'cname': cname,
    'pname': pname, 'finalprice': finalprice, 'size': size,
    'color': color, 'quantity': quantity, 'sname': sname, 'rid': rid,
    'purchasedate': purchasedate?.toIso8601String(),
    'pickupdate': pickupdate?.toIso8601String(),
    'refunddate': refunddate?.toIso8601String(),
  };
}

class PurchaseView extends StatefulWidget {
  const PurchaseView({super.key});
  @override
  State<PurchaseView> createState() => _PurchaseViewState();
}

class _PurchaseViewState extends State<PurchaseView> {
  final f = NumberFormat('###,###,###,###');
  TextEditingController searchController = TextEditingController();
  String selectedSearchField = '고객이메일';
  String selectedStatus = '전체';
  List<PurchaseSummary> data = [];
  List<PurchaseSummary> filteredData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPurchaseData();
  }

  Future<void> loadPurchaseData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    var url = Uri.parse("${IpAddress.baseUrl}/purchase/selectSummaryTest");
    try {
      var response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final body = utf8.decode(response.bodyBytes);
        final decodeData = json.decode(body);
        List results = decodeData['results'] ?? [];
        setState(() {
          data = results.map((e) => PurchaseSummary.fromJson(e)).toList();
          _applyFilters();
        });
      }
    } catch (e) {
      debugPrint("에러: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    final query = searchController.text.trim().toLowerCase();
    setState(() {
      filteredData = data.where((item) {
        bool statusMatch = (selectedStatus == '전체' || _getStatus(item) == selectedStatus);
        bool searchMatch = true;
        if (query.isNotEmpty) {
          if (selectedSearchField == '고객이메일') searchMatch = item.cemail.toLowerCase().contains(query);
          else if (selectedSearchField == '주문번호') searchMatch = item.pcid.toString().contains(query);
          else if (selectedSearchField == '제품명') searchMatch = item.pname.toLowerCase().contains(query);
        }
        return statusMatch && searchMatch;
      }).toList();
    });
  }

  String _getStatus(PurchaseSummary item) => item.rid != null ? (item.refunddate != null ? '반품완료' : '반품대기') : (item.pickupdate != null ? '수령완료' : '수령대기');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(title: const Text("주문 내역 관리", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), centerTitle: true, backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0.5),
      body: Column(
        children: [
          _buildSearchArea(),
          Expanded(child: _isLoading ? const Center(child: CircularProgressIndicator(color: Colors.black)) : _buildListArea()),
        ],
      ),
    );
  }

  Widget _buildSearchArea() {
    return Container(
      color: Colors.white, padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                DropdownButton<String>(
                  value: selectedSearchField, underline: const SizedBox(),
                  items: ['고객이메일', '주문번호', '제품명'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
                  onChanged: (v) => setState(() => selectedSearchField = v!),
                ),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: searchController, onChanged: (_) => _applyFilters(), decoration: const InputDecoration(hintText: "검색어 입력", border: InputBorder.none, isDense: true))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['전체', '수령대기', '수령완료', '반품대기', '반품완료'].map((status) {
                bool isSelected = selectedStatus == status;
                return GestureDetector(
                  onTap: () { setState(() => selectedStatus = status); _applyFilters(); },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: isSelected ? Colors.black : Colors.white, border: Border.all(color: isSelected ? Colors.black : Colors.grey[300]!), borderRadius: BorderRadius.circular(20)),
                    child: Text(status, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 12)),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListArea() {
    if (filteredData.isEmpty) return const Center(child: Text("내역이 없습니다."));
    return ListView.builder(
      padding: const EdgeInsets.all(16), itemCount: filteredData.length,
      itemBuilder: (context, index) {
        final item = filteredData[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      // 💡 핵심: 이미지는 mid를 기준으로 가져옵니다.
                      "${IpAddress.baseUrl}/productimage/view?pid=${item.mid}&position=main",
                      width: 80, height: 80, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(width: 80, height: 80, color: Colors.grey[200], child: const Icon(Icons.image)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("ID: ${item.pcid}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            _buildStatusBadge(_getStatus(item)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(item.pname, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text("${item.color} / ${item.size}mm", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        const SizedBox(height: 4),
                        Text("${item.cname} (${item.cemail})", style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item.purchasedate != null ? DateFormat('yyyy-MM-dd').format(item.purchasedate!) : "-", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  Text("${f.format(item.finalprice)}원", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = status.contains('완료') ? Colors.green : (status.contains('반품') ? Colors.red : Colors.blue);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
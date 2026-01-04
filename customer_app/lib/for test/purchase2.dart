import 'dart:convert';
import 'package:customer_app/database/selected_store_database.dart';
import 'package:customer_app/ip/ipaddress.dart';
import 'package:customer_app/util/pcolor.dart';
import 'package:customer_app/view/home/tabbar.dart';
import 'package:customer_app/view/map/map_select.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Purchase2 extends StatefulWidget {
  const Purchase2({super.key});

  @override
  State<Purchase2> createState() => _Purchase2State();
}

class _Purchase2State extends State<Purchase2> {
  final SelectedStoreDatabase dbHandler = SelectedStoreDatabase();

  late TextEditingController branchNameController;
  int? selectedSid;
  int _radioValue = 0;
  final f = NumberFormat('###,###,###,###');

  /// 🔥 여러 상품
  late List<Map<String, dynamic>> selectedProducts;

  @override
  void initState() {
    super.initState();

    branchNameController = TextEditingController();

    /// arguments 에서 items 받기
    selectedProducts = List<Map<String, dynamic>>.from(
      Get.arguments?['items'] ?? [],
    );

    _refreshStoreInfo();
  }

  // ================= 지점 정보 =================
  Future<void> _refreshStoreInfo() async {
    int? sid = await dbHandler.queryStoreId();
    if (sid == null) return;

    try {
      var url = Uri.parse("${IpAddress.baseUrl}/store/select");
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        List results = data['results'];

        var matched =
            results.firstWhere((s) => s['id'] == sid, orElse: () => null);

        if (matched != null) {
          setState(() {
            selectedSid = sid;
            branchNameController.text = matched['name'];
          });
        }
      }
    } catch (e) {
      debugPrint("지점 정보 로드 에러: $e");
    }
  }

  Future<void> _selectBranch() async {
    await Get.to(() => const MapSelect());
    await _refreshStoreInfo();
  }

  // ================= 결제 =================
  Future<void> _handlePayment() async {
    if (selectedSid == null) {
      Get.snackbar(
        "알림",
        "수령하실 지점을 선택해주세요.",
        backgroundColor: Pcolor.errorBackColor,
        colorText: Colors.white,
      );
      return;
    }

    final int totalPrice = selectedProducts.fold(
      0,
      (sum, item) => sum + (item['price'] * item['quantity'] as int ),
    );

    for (final item in selectedProducts) {
      await http.post(
        Uri.parse("${IpAddress.baseUrl}/purchase/insert"),
        body: {
          "quantity": item['quantity'].toString(),
          "finalprice":
              (item['price'] * item['quantity']).toString(),
          "code": "ORD${DateTime.now().millisecondsSinceEpoch}",
          "pid": item['pid'].toString(),
          "cid": item['cid'].toString(),
          "eid": selectedSid.toString(),
        },
      );
    }

    _showCompleteDialog();
  }

  void _showCompleteDialog() {
    Get.defaultDialog(
      title: "결제 완료",
      middleText: "${branchNameController.text} 매장으로 주문이 완료되었습니다.",
      onConfirm: () => Get.offAll(() => const Tabbar()),
      textConfirm: "확인",
      confirmTextColor: Colors.white,
      buttonColor: Colors.black,
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final int totalPrice = selectedProducts.fold(
      0,
      (sum, item) => sum + (item['price'] * item['quantity']as int),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Pcolor.basebackgroundColor,
        title: const Text("결제하기"),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xfff3f3f3),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("수령매장 선택", style: TextStyle(fontWeight: FontWeight.bold)),
            _storeBox(),
            const SizedBox(height: 10),

            const Text("주문 상품", style: TextStyle(fontWeight: FontWeight.bold)),
            ...selectedProducts.map(_productItem).toList(),

            const SizedBox(height: 10),
            const Text("결제 수단", style: TextStyle(fontWeight: FontWeight.bold)),
            _buildPaymentRadio(),

            const Text("최종 주문 정보", style: TextStyle(fontWeight: FontWeight.bold)),
            _buildPriceInfo(totalPrice),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            onPressed: _handlePayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedSid == null ? Colors.grey : Colors.black,
            ),
            child: const Text(
              "결제하기",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  // ================= UI =================

  Widget _productItem(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        decoration:
            BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Image.network(
              item['image'],
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.image_not_supported, size: 72),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['name'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(item['manufacturername']),
                  Text(
                      "${item['size']} / ${item['color']} / ${item['quantity']}개"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _storeBox() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: _selectBranch,
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Pcolor.basebackgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              const Text("지점", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  branchNameController.text.isEmpty
                      ? "미지정"
                      : branchNameController.text,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Icon(Icons.search),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentRadio() {
    return Column(
      children: [
        RadioListTile(
            value: 0,
            groupValue: _radioValue,
            title: const Text('간편 결제'),
            onChanged: (v) => setState(() => _radioValue = v!)),
        RadioListTile(
            value: 1,
            groupValue: _radioValue,
            title: const Text('신용카드'),
            onChanged: (v) => setState(() => _radioValue = v!)),
        RadioListTile(
            value: 2,
            groupValue: _radioValue,
            title: const Text('매장에서 결제'),
            onChanged: (v) => setState(() => _radioValue = v!)),
      ],
    );
  }

  Widget _buildPriceInfo(int price) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(20),
      decoration:
          BoxDecoration(color: Pcolor.basebackgroundColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('구매가 합계'),
              Text("${f.format(price)} 원"),
            ],
          ),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('총 결제금액',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                "${f.format(price)} 원",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

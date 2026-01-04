import 'dart:convert';
import 'package:customer_app/database/selected_store_database.dart'; // 💡 보내주신 DB 핸들러
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
  final SelectedStoreDatabase dbHandler = SelectedStoreDatabase(); // 💡 DB 핸들러 선언
  late TextEditingController branchNameController;
  int? selectedSid; 
  late int _radioValue; 
  final f = NumberFormat('###,###,###,###');
  late Map<String, dynamic> selectedProduct;

  @override
  void initState() {
    super.initState();
    selectedProduct = Get.arguments ?? {};
    branchNameController = TextEditingController();
    _radioValue = 0;
    
    // 처음 화면에 들어왔을 때도 기존에 저장된 지점이 있다면 불러옵니다.
    _refreshStoreInfo();
  }

  // 💡 DB에서 저장된 sid를 읽어와서 화면의 지점명과 sid를 업데이트하는 함수
  Future<void> _refreshStoreInfo() async {
    int? sid = await dbHandler.queryStoreId();
    if (sid != null) {
      // 서버에서 지점 리스트를 가져와서 sid에 맞는 이름을 찾습니다.
      try {
        var url = Uri.parse("${IpAddress.baseUrl}/store/select");
        var response = await http.get(url);
        if (response.statusCode == 200) {
          var data = json.decode(utf8.decode(response.bodyBytes));
          List results = data['results'];
          // DB의 sid와 일치하는 지점 찾기
          var matched = results.firstWhere((s) => s['id'] == sid, orElse: () => null);
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
  }

  // ✅ 지점 선택 버튼 클릭 시
  Future<void> _selectBranch() async {
    // 1. 지점 선택 페이지로 이동 (MapSelect에서 DB 저장을 완료하고 돌아온다고 가정)
    await Get.to(() => const MapSelect());
    
    // 2. 돌아오자마자 DB에서 다시 읽어와서 화면 갱신 (setState 실행)
    await _refreshStoreInfo();
  }

  // ✅ 결제 로직
  Future<void> _handlePayment() async {
    if (selectedSid == null) {
      Get.snackbar("알림", "수령하실 지점을 선택해주세요.", 
          backgroundColor: Pcolor.errorBackColor, colorText: Colors.white);
      return;
    }

    int total = (selectedProduct['price'] ?? 0) * (selectedProduct['quantity'] ?? 1);
    
    var url = Uri.parse("${IpAddress.baseUrl}/purchase/insert");
    try {
      var response = await http.post(
        url,
        body: {
          "quantity": (selectedProduct['quantity'] ?? 1).toString(),
          "finalprice": total.toString(),
          "code": "ORD${DateTime.now().millisecondsSinceEpoch}",
          "pid": selectedProduct['pid'].toString(), 
          "cid": selectedProduct['cid'].toString(), 
          "eid": selectedSid.toString(),             
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        if (data['result'] == "OK") {
          _showCompleteDialog();
        }
      }
    } catch (e) {
      Get.snackbar("에러", "서버 통신 오류");
    }
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
    int totalPrice = (selectedProduct['price'] ?? 0) * (selectedProduct['quantity'] ?? 1);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Pcolor.basebackgroundColor,
        title: const Text("결제하기"),
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("수령매장 선택", style: TextStyle(fontWeight: FontWeight.bold)),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: Pcolor.basebackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('지점', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              branchNameController.text.isEmpty ? '미지정' : branchNameController.text,
                              style: TextStyle(
                                color: branchNameController.text.isEmpty ? Colors.grey : Colors.black,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: TextField(
                              readOnly: true,
                              onTap: _selectBranch,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                                filled: true,
                                fillColor: const Color.fromARGB(255, 194, 194, 194),
                                suffixIcon: IconButton(
                                  onPressed: _selectBranch,
                                  icon: const Icon(Icons.search, color: Colors.black, size: 20),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const Text("주문 상품", style: TextStyle(fontWeight: FontWeight.bold)),
              // ... (주문 상품 정보 디자인 유지)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                selectedProduct['image'] ?? "",
                                width: 72, height: 72, fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported, size: 72),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(selectedProduct['name'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(selectedProduct['manufacturername'] ?? ""),
                                  Text("${selectedProduct['size']} / ${selectedProduct['color']} / ${selectedProduct['quantity']}개"),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("결제 금액"),
                            Text("${f.format(totalPrice)} 원"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // ... (결제 수단 및 최종 금액 정보 유지)
              const Text("결제 수단", style: TextStyle(fontWeight: FontWeight.bold)),
              _buildPaymentRadio(),
              const Text("최종 주문 정보", style: TextStyle(fontWeight: FontWeight.bold)),
              _buildPriceInfo(totalPrice),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            onPressed: _handlePayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedSid == null ? Colors.grey : Colors.black, // 💡 sid 유무에 따라 색상 변경
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            ),
            child: const Text("결제하기", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
          ),
        ),
      ),
    );
  }

  // 나머지 위젯들 (디자인용)
  Widget _buildPaymentRadio() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(color: Pcolor.basebackgroundColor, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            RadioListTile(value: 0, groupValue: _radioValue, title: const Text('간편 결제'), onChanged: (v) => setState(() => _radioValue = v!)),
            RadioListTile(value: 1, groupValue: _radioValue, title: const Text('신용카드'), onChanged: (v) => setState(() => _radioValue = v!)),
            RadioListTile(value: 2, groupValue: _radioValue, title: const Text('매장에서 결제'), onChanged: (v) => setState(() => _radioValue = v!)),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceInfo(int price) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(color: Pcolor.basebackgroundColor, borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
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
                  const Text('총 결제금액', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('${f.format(price)}원', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
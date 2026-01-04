import 'dart:convert';
import 'package:customer_app/database/cartdatabasehandler.dart';
import 'package:customer_app/for%20test/purchase2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:customer_app/ip/ipaddress.dart';
import 'package:customer_app/model/product.dart';
import 'package:customer_app/model/cart.dart';
import 'package:customer_app/model/usercontroller.dart'; 
import 'package:customer_app/util/pcolor.dart';

class Detail2 extends StatefulWidget {
  const Detail2({super.key});

  @override
  State<Detail2> createState() => _Detail2State();
}

class _Detail2State extends State<Detail2> {
  // Property
  late Product product;
  String? koreanName;
  final Cartdatabasehandler handler = Cartdatabasehandler();
  final UserController userController = Get.find<UserController>(); 

  List allOptions = []; 
  List sizeList = [];   
  List colorList = [];  
  
  int? selectedSizeIndex;
  int? selectedColorIndex;
  String selectedSize = "";
  String selectedColor = "";
  int count = 1;

  @override
  void initState() {
    super.initState();
    product = Get.arguments['product'];
    koreanName = Get.arguments['koreanName'];
    getGroupData();
  }

  // 서버에서 해당 mid 그룹의 모든 옵션 가져오기
  Future<void> getGroupData() async {
    var url = Uri.parse("${IpAddress.baseUrl}/product/selectdetail2?pid=${product.id}");
    try {
      var response = await http.get(url);
      var data = json.decode(utf8.decode(response.bodyBytes));
      if (data['results'] != null) {
        setState(() {
          allOptions = data['results'];
          sizeList = allOptions.map((e) => e['size']).where((e) => e != null).toSet().toList();
          colorList = allOptions.map((e) => e['color']).where((e) => e != null).toSet().toList();
          sizeList.sort();
          colorList.sort();
        });
      }
    } catch (e) { debugPrint("Error: $e"); }
  }

  // ✅ 장바구니 저장 및 구매 로직 수정
  void _handleAction({required bool isCart}) async {
    if (selectedSize.isEmpty || selectedColor.isEmpty) {
      Get.snackbar("알림", "옵션을 모두 선택해주세요.", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (userController.user == null) {
      Get.snackbar("알림", "로그인이 필요한 서비스입니다.");
      return;
    }
    
    int userCid = int.parse(userController.user!.id.toString()); 

    var matchedItem = allOptions.firstWhere(
      (item) => item['size'].toString() == selectedSize && item['color'].toString() == selectedColor,
      orElse: () => null,
    );

    if (matchedItem == null) return;
    int finalPid = matchedItem['id'];

    if (isCart) {
      try {
        await handler.insertCart(Cart(cid: userCid, cartid: finalPid));
        Get.back(); 
        Get.snackbar("성공", "장바구니에 담겼습니다.", backgroundColor: Colors.blue, colorText: Colors.white);
      } catch (e) { debugPrint("SQLite Error: $e"); }
    } else {
      // 💡 [수정 포인트] Shoppingcart와 형식을 맞추기 위해 "items" 키를 사용한 리스트로 전달
      Get.back();
      Get.to(() => const Purchase2(), arguments: {
        "items": [
          {
            "pid": finalPid,
            "cid": userCid,
            "price": matchedItem['price'] ?? product.price,
            "quantity": count,
            "name": matchedItem['product_name'] ?? koreanName ?? product.ename,
            "productname": matchedItem['product_name'] ?? koreanName ?? product.ename,
            "manufacturername": matchedItem['manufacturer_name'] ?? "브랜드",
            "size": selectedSize,
            "color": selectedColor,
            "image": '${IpAddress.baseUrl}/productimage/view?pid=${product.mid ?? product.id}&position=main',
          }
        ]
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int imgId = (product.mid != null && product.mid != 0) ? product.mid! : (product.id ?? 0);

    return Scaffold(
      backgroundColor: Pcolor.basebackgroundColor,
      appBar: AppBar(title: Text(koreanName ?? "상품 상세"), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            imgId != 0 
              ? Image.network('${IpAddress.baseUrl}/productimage/view?pid=$imgId&position=main', fit: BoxFit.cover)
              : const SizedBox(height: 200, child: Icon(Icons.image_not_supported)),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${product.price}원", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(koreanName ?? product.ename, style: const TextStyle(fontSize: 18)),
                  const Divider(height: 40),
                  Image.asset('images/size.png', fit: BoxFit.fill),
                  const SizedBox(height: 20),
                  if (imgId != 0) ...[
                    _img(imgId, 'top'), _img(imgId, 'side'), _img(imgId, 'back'),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () => showPurchaseSheet(),
            child: const Text("구매하기", style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
        ),
      ),
    );
  }

  Widget _img(int pid, String pos) => Image.network(
    '${IpAddress.baseUrl}/productimage/view?pid=$pid&position=$pos', 
    fit: BoxFit.contain, 
    errorBuilder: (c, e, s) => const SizedBox.shrink()
  );

  void showPurchaseSheet() {
    Get.bottomSheet(
      StatefulBuilder(builder: (context, setBS) {
        return Container(
          padding: const EdgeInsets.all(25),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(child: Icon(Icons.maximize, color: Colors.grey)),
                const SizedBox(height: 10),
                const Text("옵션 선택", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                const Text("사이즈"),
                _grid(sizeList, selectedSizeIndex, (i) => setBS(() { selectedSizeIndex = i; selectedSize = sizeList[i].toString(); }), 4),
                const SizedBox(height: 20),
                const Text("컬러"),
                _grid(colorList, selectedColorIndex, (i) => setBS(() { selectedColorIndex = i; selectedColor = colorList[i].toString(); }), 3),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("수량", style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        IconButton(onPressed: () => setBS(() => count > 1 ? count-- : null), icon: const Icon(Icons.remove_circle_outline)),
                        Text("$count", style: const TextStyle(fontSize: 18)),
                        IconButton(onPressed: () => setBS(() => count++), icon: const Icon(Icons.add_circle_outline)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(children: [
                  Expanded(child: OutlinedButton(style: OutlinedButton.styleFrom(minimumSize: const Size(0, 55)), onPressed: () => _handleAction(isCart: true), child: const Text("장바구니", style: TextStyle(color: Colors.black)))),
                  const SizedBox(width: 10),
                  Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.black, minimumSize: const Size(0, 55)), onPressed: () => _handleAction(isCart: false), child: const Text("바로구매", style: TextStyle(color: Colors.white)))),
                ]),
              ],
            ),
          ),
        );
      }),
      isScrollControlled: true,
    );
  }

  Widget _grid(List list, int? sIdx, Function(int) onTap, int count) => GridView.builder(
    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: list.length,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: count, childAspectRatio: 2.2, crossAxisSpacing: 8, mainAxisSpacing: 8),
    itemBuilder: (context, i) => GestureDetector(
      onTap: () => onTap(i),
      child: Container(decoration: BoxDecoration(color: sIdx == i ? Colors.black : Colors.grey[100], borderRadius: BorderRadius.circular(8)), child: Center(child: Text(list[i].toString(), style: TextStyle(color: sIdx == i ? Colors.white : Colors.black)))),
    ),
  );
}
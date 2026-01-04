import 'dart:convert';

import 'package:customer_app/model/usercontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:customer_app/database/cartdatabasehandler.dart';
import 'package:customer_app/model/cart.dart';
import 'package:customer_app/ip/ipaddress.dart';
import 'package:customer_app/for test/purchase2.dart';

class Shoppingcart extends StatefulWidget {
  const Shoppingcart({super.key});

  @override
  State<Shoppingcart> createState() => _ShoppingcartState();
}

class _ShoppingcartState extends State<Shoppingcart> {
  final UserController userController = Get.find<UserController>();
  final Cartdatabasehandler handler = Cartdatabasehandler();

  late Future<List<Cart>> cartFuture;

  /// cart.id -> quantity
  final Map<int, int> quantityMap = {};

  @override
  void initState() {
    super.initState();
    cartFuture = handler.queryCart();
  }

  // ================= pid -> 옵션 상세 =================
  Future<Map<String, dynamic>?> getProductDetail(int pid) async {
    final url =
        Uri.parse("${IpAddress.baseUrl}/product/selectdetail2?pid=$pid");

    final response = await http.get(url);
    final data = json.decode(utf8.decode(response.bodyBytes));

    final List results = data['results'];
    if (results.isEmpty) return null;

    // 장바구니에 담긴 pid와 정확히 일치하는 옵션
    return results.firstWhere(
      (e) => e['id'] == pid,
      orElse: () => results.first,
    );
  }

  // ================= 장바구니 삭제 =================
  Future<void> deleteCartItem(int cartRowId) async {
    await handler.deleteCart(cartRowId);
    quantityMap.remove(cartRowId);

    setState(() {
      cartFuture = handler.queryCart();
    });
  }

  // ================= 여러 상품 결제 이동 =================
  Future<void> goToPayment(List<Cart> carts) async {
    if (carts.isEmpty) return;

    final List<Map<String, dynamic>> orderItems = [];

    for (final cart in carts) {
      final int pid = cart.cartid;
      final int qty = quantityMap[cart.id] ?? 1;

      final item = await getProductDetail(pid);
      if (item == null) continue;

      orderItems.add({
        "pid": pid,
        "cid": userController.user!.id,

        "price": item['price'],
        "quantity": qty,

        // 🔥 상품명
        "name": item['product_name'],
        "productname": item['product_name'],

        // 🔥 제조사
        "manufacturername": item['manufacturer_name'],

        "size": item['size'],
        "color": item['color'],

        "image":
            '${IpAddress.baseUrl}/productimage/view?pid=${item['mid']}&position=main',
      });
    }

    if (orderItems.isEmpty) return;

    Get.to(
      () => const Purchase2(),
      arguments: {
        "items": orderItems,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("장바구니"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Cart>>(
        future: cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("장바구니가 비어있습니다"));
          }

          final carts = snapshot.data!;

          return Column(
            children: [
              /// ================= 상품 리스트 =================
              Expanded(
                child: ListView.builder(
                  itemCount: carts.length,
                  itemBuilder: (context, index) {
                    final cart = carts[index];
                    final int cartRowId = cart.id!;
                    final int pid = cart.cartid;

                    quantityMap.putIfAbsent(cartRowId, () => 1);

                    return FutureBuilder<Map<String, dynamic>?>(
                      future: getProductDetail(pid),
                      builder: (context, productSnapshot) {
                        if (!productSnapshot.hasData) {
                          return const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text("상품 정보 불러오는 중..."),
                          );
                        }

                        final item = productSnapshot.data!;
                        final int qty = quantityMap[cartRowId] ?? 1;
                        final int price = item['price'] ?? 0;
                        final int mid = item['mid'];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// 이미지
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    '${IpAddress.baseUrl}/productimage/view?pid=$mid&position=main',
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(
                                      Icons.image_not_supported,
                                      size: 80,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                /// 상품 정보
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['product_name'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "제조사: ${item['manufacturer_name'] ?? ''}",
                                      ),
                                      Text(
                                        "사이즈: ${item['size']} / 색상: ${item['color']}",
                                      ),
                                      const SizedBox(height: 8),

                                      /// 수량 조절
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove,
                                                size: 18),
                                            onPressed: () {
                                              setState(() {
                                                if (qty > 1) {
                                                  quantityMap[cartRowId] =
                                                      qty - 1;
                                                }
                                              });
                                            },
                                          ),
                                          Text(
                                            "$qty",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add,
                                                size: 18),
                                            onPressed: () {
                                              setState(() {
                                                quantityMap[cartRowId] =
                                                    qty + 1;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                /// 가격 + 삭제
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () =>
                                          deleteCartItem(cartRowId),
                                    ),
                                    Text(
                                      "${price * qty}원",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              /// ================= 결제 버튼 =================
              Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => goToPayment(carts),
                    child: const Text("결제하기"),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

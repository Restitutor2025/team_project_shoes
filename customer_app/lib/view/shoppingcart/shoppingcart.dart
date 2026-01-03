import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:customer_app/database/cartdatabasehandler.dart';
import 'package:customer_app/model/cart.dart';
import 'package:customer_app/ip/ipaddress.dart';

class Shoppingcart extends StatefulWidget {
  const Shoppingcart({super.key});

  @override
  State<Shoppingcart> createState() => _ShoppingcartState();
}

class _ShoppingcartState extends State<Shoppingcart> {
  final Cartdatabasehandler handler = Cartdatabasehandler();

  Map<String, dynamic>? incomingItem;
  late Future<List<Cart>> cartFuture;

  /// ✅ cart.id → qty
  final Map<int, int> quantityMap = {};

  @override
  void initState() {
    super.initState();

    incomingItem = Get.arguments;

    if (incomingItem != null && incomingItem!['pid'] != null) {
      handler.insertCart(
        Cart(cartid: incomingItem!['pid']),
      );
    }

    cartFuture = handler.queryCart();
  }

  // ================= pid → 상품 상세 =================
  Future<List<Map<String, dynamic>>> getProductDetail(int pid) async {
    final url =
        Uri.parse("${IpAddress.baseUrl}/product/selectdetail?pid=$pid");

    final response = await http.get(url);
    final dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));

    final List results = dataConvertedJSON['results'];
    return results
        .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  // ================= 주문 데이터 =================
  List<Map<String, dynamic>> buildOrderItems(List<Cart> carts) {
    return carts.map((cart) {
      return {
        "cart_id": cart.id,
        "pid": cart.cartid,
        "qty": quantityMap[cart.id] ?? 1,
      };
    }).toList();
  }

  // ================= 장바구니 삭제 =================
  Future<void> deleteCartItem(int cartRowId) async {
    await handler.deleteCart(cartRowId);

    // 수량 Map에서도 제거
    quantityMap.remove(cartRowId);

    // 장바구니 다시 로드
    setState(() {
      cartFuture = handler.queryCart();
    });
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
        builder: (context, cartSnapshot) {
          if (cartSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!cartSnapshot.hasData || cartSnapshot.data!.isEmpty) {
            return const Center(child: Text("장바구니가 비어있습니다"));
          }

          final carts = cartSnapshot.data!;

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

                    // 처음 row는 수량 1
                    quantityMap.putIfAbsent(cartRowId, () => 1);

                    return FutureBuilder<List<Map<String, dynamic>>>(
                      future: getProductDetail(pid),
                      builder: (context, productSnapshot) {
                        if (!productSnapshot.hasData) {
                          return const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text("상품 정보 불러오는 중..."),
                          );
                        }

                        final productList = productSnapshot.data!;
                        if (productList.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        final item = productList[0];

                        final int price = (item['price'] is int)
                            ? item['price']
                            : int.tryParse("${item['price']}") ?? 0;
                        final int qty = quantityMap[cartRowId] ?? 1;

                        /// ================= 카드 UI =================
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
                                    '${IpAddress.baseUrl}/productimage/view?pid=$pid&position=main',
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
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
                                        item['name'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                          "제조사: ${item['manufacturer'] ?? ''}"),
                                      Text(
                                          "사이즈: ${item['size'] ?? ''} / 색상: ${item['color'] ?? ''}"),
                                      const SizedBox(height: 8),

                                      /// 수량 조절
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove,
                                                size: 18),
                                            onPressed: () {
                                              setState(() {
                                                if ((quantityMap[cartRowId] ??
                                                        1) >
                                                    1) {
                                                  quantityMap[cartRowId] =
                                                      (quantityMap[cartRowId] ??
                                                              1) -
                                                          1;
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
                                                    (quantityMap[cartRowId] ??
                                                            1) +
                                                        1;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                /// 오른쪽 영역 (가격 + 삭제)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () {
                                        deleteCartItem(cartRowId);
                                      },
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

              /// ================= 하단 결제 버튼 =================
              Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      final orderItems = buildOrderItems(carts);
                      debugPrint("ORDER ITEMS => $orderItems");

                      // Get.toNamed("/payment", arguments: orderItems);
                    },
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

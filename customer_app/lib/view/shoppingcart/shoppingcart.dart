import 'package:flutter/material.dart';

class Shoppingcart extends StatefulWidget {
  const Shoppingcart({super.key});

  @override
  State<Shoppingcart> createState() => _ShoppingcartState();
}

class _ShoppingcartState extends State<Shoppingcart> {
  List<Map<String, dynamic>> cartList = [
    {
      'brand': '나이키',
      'name': '나이키 에어포스',
      'price': 92000,
      'quantity': 1,
      'size': '270',
      'color': '화이트',
      'image': 'images/logo.png',
    },
    {
      'brand': '나이키',
      'name': '에어맥스',
      'price': 93000,
      'quantity': 1,
      'size': '265',
      'color': '블랙',
      'image': 'images/logo.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "장바구니",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      /// ================= 리스트 =================
      body: ListView.builder(
        itemCount: cartList.length,
        itemBuilder: (context, index) {
          final item = cartList[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                    child: Image.asset(
                      item['image'],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// 상품 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['brand'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['name'],
                          style: const TextStyle(fontSize: 13),
                        ),

                        const SizedBox(height: 6),

                        /// 사이즈 & 색상
                        Text(
                          "사이즈: ${item['size']} / 색상: ${item['color']}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// 수량 조절
                        Row(
                          children: [
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                  if (item['quantity'] > 1) {
                                    item['quantity']--;
                                  }

                                setState(() {
                                });
                              },
                              icon: const Icon(Icons.remove),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                "${item['quantity']}",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                setState(() {
                                  item['quantity']++;
                                });
                              },
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  /// 가격 + 삭제
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            cartList.removeAt(index);
                          });
                        },
                        child: const Icon(Icons.close, size: 20),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        "${item['price']}원",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),

      /// ================= 하단 결제 =================
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              "총결제금액:${totalPrice()}원",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text("구매하기"),
            ),
          ),
        ],
      ),
    );
  }

  // ================= 총 결제 금액 =================
  int totalPrice() {
    int total = 0;
    for (var item in cartList) {
      total += item['price'] * item['quantity']as int;
    }
    return total;
  }
}

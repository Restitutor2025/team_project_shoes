import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Wishlist extends StatefulWidget {
  const Wishlist({super.key});

  @override
  State<Wishlist> createState() => _WishlistState();
}

class _WishlistState extends State<Wishlist> {
  String selectedColor = '블랙';
  String selectedSize = '260';

final List<String> colorList = ['블랙', '화이트', '레드'];
final List<String> sizeList = ['250', '255', '260', '265', '270'];

  List<Map<String, dynamic>> wishList = [
    {
      'brand': '나이키',
      'name': '나이키 에어포스',
      'price': 92000,
      'image': 'images/logo.png',
      'checked': false,
      'count': 0,
    },
    {
      'brand': '아디다스',
      'name': '슈퍼스타',
      'price': 89000,
      'image': 'images/logo.png',
      'checked': false,
      'count': 0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "찜목록",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      /// ================= 리스트 =================
      body: ListView.builder(
        itemCount: wishList.length,
        itemBuilder: (context, index) {
          final item = wishList[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
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
                        Text(
                          "${item['price']}원",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// 체크박스 + 버튼
                  Column(
                    children: [
                      Checkbox(
                        value: item['checked'],
                        onChanged: (value) {
                          setState(() {
                            item['checked'] = value!;
                          });
                        },
                      ),
                      SizedBox(
                        width: 72,
                        height: 30,
                        child: ElevatedButton(
                          onPressed: () => shoppingcartmove(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child:Text(
                            "장바구니",
                            style: TextStyle(fontSize: 11),
                          ),
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

      /// ================= 하단 삭제 버튼 =================
      bottomNavigationBar: SizedBox(
        height: 56,
        child: ElevatedButton(
          onPressed: deletedialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          child:  Text("삭제하기"),
        ),
      ),
    );
  }

  /// ================= 삭제 다이얼로그 =================
  void deletedialog() {
    Get.defaultDialog(
      title: "찜 목록 삭제",
      middleText: "선택한 상품을 삭제하시겠습니까?",
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              wishList.removeWhere((item) => item['checked'] == true);
            });
            Get.back();
          },
          child: const Text("삭제"),
        ),
        TextButton(
          onPressed: () => Get.back(),
          child: const Text("취소"),
        ),
      ],
    );
  }

  /// ================= 장바구니 바텀시트 =================
 void shoppingcartmove(int index) {
    final item = wishList[index];

    Get.bottomSheet(
  Container(
    height: 500,
    padding: const EdgeInsets.all(16),
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            "옵션 선택",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),

        const SizedBox(height: 20),

        ///  컬러 선택
        const Text("컬러"),
        DropdownButton<String>(
          value: selectedColor,
          isExpanded: true,
          items: colorList.map((color) {
            return DropdownMenuItem(
              value: color,
              child: Text(color),
            );
          }).toList(),
          onChanged: (value) {
              selectedColor = value!;
            setState(() {
            });
          },
        ),

        const SizedBox(height: 16),

        /// 🔽 사이즈 선택
        const Text("사이즈"),
        DropdownButton<String>(
          value: selectedSize,
          isExpanded: true,
          items: sizeList.map((size) {
            return DropdownMenuItem(
              value: size,
              child: Text(size),
            );
          }).toList(),
          onChanged: (value) {
              selectedSize = value!;
            setState(() {
            });
          },
        ),

        SizedBox(height: 24),

        /// 수량 선택
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                item['count']--;
                setState(() {
                });
              },
              icon: const Icon(Icons.remove),
            ),
            Text(
              "${item['count']}",
              style: TextStyle(fontSize: 18),
            ),
            IconButton(
              onPressed: () {
                  item['count']++;
                setState(() {
                });
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),

        const Spacer(),

        // 장바구니 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
           
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text("장바구니 담기"),
          ),
        ),
      ],
    ),
  ),
);

  }
}

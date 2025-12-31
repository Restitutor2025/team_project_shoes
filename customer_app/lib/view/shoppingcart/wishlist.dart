import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Wishlist extends StatefulWidget {
  const Wishlist({super.key});

  @override
  State<Wishlist> createState() => _WishlistState();
}

class _WishlistState extends State<Wishlist> {
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
        title: Text(
          "찜목록",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: wishList.length,
        itemBuilder: (context, index) {
          final item = wishList[index];

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 이미지
                Image.asset(
                  item['image'],
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),

                SizedBox(width: 12),

                // 상품 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item['brand'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(item['name']),
                      SizedBox(height: 4),
                      Text(
                        "${item['price']}원",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                // 체크박스 + 버튼
                Column(
                  mainAxisSize: MainAxisSize.min,
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
                      width: 70,
                      height: 30,
                      child: ElevatedButton(
                        onPressed: () {
                          shoppingcartmove(index);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text(
                          "장바구니",
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SizedBox(
        height: 56,
        child: ElevatedButton(
          onPressed: deletedialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          child: Text("삭제하기"),
        ),
      ),
    );
  }

  void deletedialog() {
    Get.defaultDialog(
      title: "찜 목록 삭제",
      middleText: "찜 목록에서 삭제하시겠습니까?",
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text("삭제"),
        ),
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text("취소"),
        ),
      ],
    );
  }

  void shoppingcartmove(int index) {
    final item = wishList[index];

    Get.bottomSheet(
      Container(
        height: 500,
        color: Colors.white,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("수량"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (item['count'] > 0) {
                        item['count']--;
                      }
                    });
                  },
                  icon: Icon(Icons.remove),
                ),
                Text("${item['count']}"),
                IconButton(
                  onPressed: () {
                    setState(() {
                      item['count']++;
                    });
                  },
                  icon: Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

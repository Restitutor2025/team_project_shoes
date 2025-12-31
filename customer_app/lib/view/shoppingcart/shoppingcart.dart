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
      'count': 0,
      'image': 'images/logo.png',
    },
    {
      'brand': '나이키2',
      'name': '나이키 에어포스2',
      'price': 93000,
      'count': 0,
      'image': 'images/logo.png',
    },
    // 나중에 여기 계속 추가 가능
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "장바구니",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: cartList.length,
        itemBuilder: (context, index) {
          final item = cartList[index];

          return ListTile(
            leading: Image.asset(
              item['image'],
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
            title: Text(
              item['brand'],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(item['name']),
                Row(
                  mainAxisSize: MainAxisSize.min,
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
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      cartList.removeAt(index); // ❌ 상품 삭제
                    });
                  },
                  child: Icon(Icons.close),
                ),
                Text(
                  "${item['price']}원",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "총결제금액: 원",
              style: TextStyle(fontWeight: FontWeight.bold),
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
              child: Text("구매하기"),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ 총 결제 금액 계산
  // int totalPrice() {
  //   int total = 0;
  //   for (var item in cartList) {
  //     total += item['price'] * item['count'];
  //   }
  //   return total;
  // }
}

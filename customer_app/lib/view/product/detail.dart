import 'dart:convert';

import 'package:customer_app/ip/ipaddress.dart';
import 'package:customer_app/model/product.dart';
import 'package:customer_app/util/pcolor.dart';
import 'package:customer_app/view/home/home.dart';
import 'package:customer_app/view/mypage/mypage.dart';
import 'package:customer_app/view/product/purchase.dart';
import 'package:customer_app/view/shoppingcart/shoppingcart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

/* 
Description : 상품 상세페이지 화면
  - 1) 상품 테이블에 저장된 값으로 이미지, 상품명, 가격 띄워주기.
      - 스크롤 뷰로 깨지지 않게
  - 2) 구매하기 버튼 누르면 바텀 시트로 사이즈 선택창 그리드뷰로 띄워주기
  - 3) 사이즈 선택 된 경우, 바텀 시트로 컬러 선택 창 띄워주기
      - 하단에 수량 선택 할 수 있게 
  - 4) 장바구니 담기, 구매하기 버튼 컬러 미 선택 시 에러 스낵바나 알림 창 띄워주기
Date : 2025-12-30
Author : 지현
*/

class Detail extends StatefulWidget {
  const Detail({super.key});

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  // Property
  List productList = []; // 제품 데이터 받아오기
  ScrollController scrollController = ScrollController(); // 스크롤 컨트롤러
  List sizeList = []; // 사이즈 데이터 받아올 곳
  List productName = []; // 제품명 데이터 받아올 곳
  List colorList = []; // 컬러 데이터 받아올 곳
  late int count = 1; // 제품 수량
  Color changeSizeColor = Pcolor.appBarForegroundColor;
  int? indexNum; // 사이즈 선택 인덱스 비교용
  int? colorIndexNum; // 컬러 선택 인덱스 비교용
  String selectedSize = "";
  String selectedColor = "";
  // List<Map<String, String>>productList = Get.arguments ?? '___';
  Product product = Get.arguments ?? '__';
  
  @override
  void initState() {
    super.initState();
    // addData(); // 더미 데이터 넣어줄 예정
    getJSONData();

  }

  Future<void> getJSONData() async{
    var url = Uri.parse(
      "${IpAddress.baseUrl}/product/selectdetail?pid=${product.id}", 
    ); 
    var response = await http.get(url);
    var dataConvertdJSON = json.decode(utf8.decode(response.bodyBytes));

    List results = dataConvertdJSON['results'];
    
    if (results.isNotEmpty) {
    setState(() {
      productList = results;
      sizeList = results.map((item) => item['size']).toSet().toList(); 
      colorList = results.map((item) => item['color']).toSet().toList();
      
      productName = [results[0]]; 
    });
  }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
        actions: [
          IconButton(onPressed: () {
            // 검색 페이지 이동
          }, 
          icon: Icon(Icons.search) //
          ),
          IconButton(onPressed: () {
            Home();
          }, 
          icon: Icon(Icons.home) //
          ),
          IconButton(onPressed: () {
            Shoppingcart();
          }, 
          icon: Icon(Icons.shopping_cart_outlined) //
          ),
          IconButton(onPressed: () {
            Mypage();
          }, 
          icon: Icon(Icons.more_horiz) //
          ),
        ]
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    '${IpAddress.baseUrl}/productimage/view?pid=${product.id}&position=main', //상품이미지
                    fit: BoxFit.contain,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${product.price.toString()}원",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0
                        ),
                        ),
                      Text( 
                         productName.isNotEmpty
                          ? productList[0]["name"].toString()
                          : ""
                        ),
                      Text(
                        product.ename,
                        style: TextStyle(
                          color: Colors.blueGrey
                        ),
                        ),
                    ],
                  ),
                ],
              ),
              Image.network(
                    '${IpAddress.baseUrl}/productimage/view?pid=${product.id}&position=main', //상품이미지
                    fit: BoxFit.contain,
                  ),
            ],
          ),
        ),
      ),
      bottomNavigationBar:SizedBox(
        height: 80,
        child: Column(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(100, 50)
              ),
              onPressed: () {
                sizeSheet();
              }, 
              child: Text("결제하기"),
              )
          ],
        ),
      ),
    );
  } // build

   // --- Functions ---
  void sizeSheet(){
    Get.bottomSheet(
      Container(
        width: 500,
        height: 500,
        color: Pcolor.basebackgroundColor,
        child: Column(
          children: [
            Icon(Icons.horizontal_rule_sharp),
            SizedBox(height: 12),
            Text(
              '구매하기',
              style: TextStyle(fontWeight: FontWeight.bold),
              ),
            Text('Text Line 2'),
            Container(
                  decoration: BoxDecoration(
                  color: Pcolor.appBarForegroundColor,
                  borderRadius: BorderRadius.circular(16), 
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              '${IpAddress.baseUrl}/productimage/view?pid=${product.id}&position=main', //상품이미지
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  productName[0]["name"].toString(),
                                style: TextStyle(
                                fontWeight: FontWeight.bold),),
                                Text(productList[0]['m.name'].toString()),
                                SizedBox(height: 12),
                              ],
                            ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
            Text("사이즈"),
            SizedBox(
              height: 50,
              child: GridView.builder(
                  controller: scrollController,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 0.01,
                    childAspectRatio: 2.0
                  ), 
                  itemCount: sizeList.length,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      height: 30,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            // colorSheet();
                            indexNum = index;
                            selectedSize = sizeList[index].toString();
                            setState(() {});
                          },
                          child: Card(
                            color: (indexNum == index) 
                              ? Pcolor.errorBackColor
                              : Pcolor.basebackgroundColor,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(sizeList[index].toString(),),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }
              ),
            ),
            Text("색상"),
            SizedBox(
              width: 200,
              height: 70,
              child: GridView.builder(
                itemCount: colorList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                ), 
                controller: scrollController,
                itemBuilder: (context, index) {
                  return Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: Pcolor.appBarBackgroundColor,
                      borderRadius: BorderRadius.circular(15)
                    ),
                    child: GestureDetector(
                      onTap: () {
                        colorIndexNum = index;
                        setState(() {});
                        selectedColor = colorList[index].toString();
                      },
                      child: Card(
                        color: (colorIndexNum == index)
                        ? Pcolor.errorBackColor
                        : Pcolor.basebackgroundColor,
                        child: Center(
                          child:
                            Text(colorList[index])
                        ),
                      ),
                    ),
                  );
                },
                ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    count--;
                    setState(() {});
                  },
                  child: Text('-'),
                ),
                Text("$count"),
                TextButton.icon(
                  label: Icon(Icons.add),
                  onPressed: () {
                    count++;
                    setState(() {});
                  },
                ),
              ]
            ),
            Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Get.to(Shoppingcart(), arguments: {
                  "pid": product.id, // pid
                  "name": productName[0]["name"], // 상품명
                  "size": selectedSize, // 고른 사이즈
                  "color": selectedColor, // 선택 컬러
                  "price": product.price, // 상품 가격
                  "quantity": count, // 수량
                  "image": '${IpAddress.baseUrl}/productimage/view?pid=${product.id}&position=main' // 이미지
                  });
                },
                 child: Text("장바구니"),
                 ),
              ElevatedButton(
                onPressed: () {
                  Get.to(Purchase(), arguments: {
                  "pid": product.id,
                  "name": productName[0]["name"],
                  "size": selectedSize,
                  "color": selectedColor,
                  "price": product.price,
                  "quantity": count,
                  "image": '${IpAddress.baseUrl}/productimage/view?pid=${product.id}&position=main'
                });
                },
                 child: Text("구매하기"),
                 ),
            ],
          ),
          ],
        ),
      )
    );
  }
} // class

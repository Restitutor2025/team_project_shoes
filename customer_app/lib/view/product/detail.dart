import 'package:flutter/material.dart';

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
  // late List<Product> productList; 제품 데이터 받아오기
  List<Map<String, String>> productList = [];

  
  @override
  void initState() {
    super.initState();
    addData(); // 더미 데이터 넣어줄 예정
  }
    void addData() {
    productList.add({
      'imageName': 'images/logo.png',
      'productName': '킨 제스퍼 여성화',
    });

    productList.add({
      'imageName': 'images/logo.png',
      'productName': '아디다스 삼바',
    });
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
            // 홈 화면 이동
          }, 
          icon: Icon(Icons.home) //
          ),
          IconButton(onPressed: () {
            // 장바구니 페이지 이동
          }, 
          icon: Icon(Icons.shopping_cart_outlined) //
          ),
          IconButton(onPressed: () {
            // 마이 페이지 이동
          }, 
          icon: Icon(Icons.more_horiz) //
          ),
        ]
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: productList.length,
              itemBuilder: (context, index) {
                return Column(
                children: [
                  Image.asset(productList[index]['imageName']!),
                  Text(productList[index]['productName']!)
                ],
              );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              //
            },
            child: Text(
              "결제하기",
              style: TextStyle(),
              )
            )
        ],
      ),
    );
  }
}
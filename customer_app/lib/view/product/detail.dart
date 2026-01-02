import 'package:customer_app/model/product.dart';
import 'package:customer_app/util/pcolor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  // List<Map<String, String>> productList = []; // 제품 데이터 받아올 곳
  ScrollController scrollController = ScrollController();
  List<String> sizeList = []; // 사이즈 데이터 받아올 곳
  List<String> colorList = []; // 컬러 데이터 받아올 곳
  late int count = 1; // 제품 수량
  Color changeSizeColor = Pcolor.appBarForegroundColor;
  int? indexNum;
  // List<Map<String, String>>productList = Get.arguments ?? '___';
  Product product = Get.arguments ?? '__';
  
  @override
  void initState() {
    super.initState();
    // addData(); // 더미 데이터 넣어줄 예정
    print(sizeList);
    sizeList = ['230','230','230','230','230','230'];
    colorList = ['빨강','파랑','노랑'];

  }
    // void addData() {
    // productList.add({
    //   'imageName': 'images/logo.png',
    //   'detailImageName': 'images/logo_non.png',
    //   'productPrice': '100,000',
    //   'productName': '킨 제스퍼 여성화',
    //   'englishName': 'KEEN JASPER Women Sneakers',
    // }); 더미 데이터_테스트용

  //}

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
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.network(
                  'http://172.16.250.183:8008/productimage/view?pid=${product.id}&position=main', //상품이미지
                  fit: BoxFit.contain,
                ),
                Text(
                  product.ename,
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                  ),
                Text(
                  product.ename,
                  style: TextStyle(
                    color: Colors.blueGrey
                  ),
                  ),
              ],
            ),
            Image.network(
                  'http://172.16.250.183:8008/productimage/view?pid=${product.id}&position=main', //상품이미지
                  fit: BoxFit.contain,
                ),
          ],
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
                              'http://172.16.250.183:8008/productimage/view?pid=${product.id}&position=main', //상품이미지
                              fit: BoxFit.contain,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  "킨 재스퍼 여성 스니커즈 발라드",
                                style: TextStyle(
                                fontWeight: FontWeight.bold),),
                                Text('KEEN'),
                                SizedBox(height: 12),
                              ],
                            ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
            SizedBox(
              height: 150,
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
                    final bool choiseCardIndex = (indexNum==index);
                    return SizedBox(
                      height: 30,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            // colorSheet();
                            indexNum=index;
                            
                            setState(() {});
                          },
                          child: Card(
                            color: choiseCardIndex 
                              ? Pcolor.errorBackColor
                              : Pcolor.basebackgroundColor,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(sizeList[index]),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }
              ),
            ),
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
                    child: Card(
                      child: Center(
                        child:
                          Text(colorList[index])
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
          ],
        ),
      )
    );

  }

  // void colorSheet(){
  //   Get.bottomSheet(
  //     Container(
  //       width: 500,
  //       height: 300,
  //       color: Pcolor.basebackgroundColor,
  //       child: Column(
  //         children: [
  //           Icon(Icons.horizontal_rule_sharp),
  //           Text("색깔"),
  //           SizedBox(height: 12),
  //           SizedBox(
  //             width: 200,
  //             height: 70,
  //             child: GridView.builder(
  //               itemCount: colorList.length,
  //               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //               crossAxisCount: 3,
  //               crossAxisSpacing: 10,
  //               mainAxisSpacing: 10,
  //               ), 
  //               controller: scrollController,
  //               itemBuilder: (context, index) {
  //                 return Container(
  //                   height: 10,
  //                   decoration: BoxDecoration(
  //                     color: Pcolor.effectBackColor,
  //                     borderRadius: BorderRadius.circular(15)
  //                   ),
  //                   child: Card(
  //                     child: Center(
  //                       child:
  //                         Text(colorList[index])
  //                     ),
  //                   ),
  //                 );
  //               },
  //               ),
  //           ),
            
  //         Column(
  //         children: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.end,
  //             children: [
  //               TextButton(
  //                 onPressed: () {
  //                   count--;
  //                   setState(() {});
  //                 },
  //                 child: Text('-'),
  //               ),
  //               Text("$count"),
  //               TextButton.icon(
  //                 label: Icon(Icons.add),
  //                 onPressed: () {
  //                   count++;
  //                   setState(() {});
  //                 },
  //               ),
  //             ]
  //           ),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             ElevatedButton(
  //               onPressed: () {
  //                 //
  //               },
  //                child: Text("장바구니"),
  //                ),
  //             ElevatedButton(
  //               onPressed: () {
  //                 //
  //               },
  //                child: Text("구매하기"),
  //                ),
  //           ],
  //         ),
  //         ]
  //         )
  //         ]
  //         ),
  //     ),
  //   );
  // }



} // class

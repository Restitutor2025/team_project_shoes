import 'package:flutter/material.dart';

/* 
Description : 상품 재고 조회 화면
  - 1) 상단에 검색 TextEditingController 넣기
      - 상품 테이블에서 검색 할 수 있게
  - 2) 상품 테이블에 저장된 값으로 이미지, 제조사, 상품명, 재고수량 띄워주기.
      - GridViewBbuilder로
Date : 2025-12-31
Author : 지현
*/

class ProductInventory extends StatefulWidget {
  const ProductInventory({super.key});

  @override
  State<ProductInventory> createState() => _ProductInventoryState();
}

class _ProductInventoryState extends State<ProductInventory> {
  // Property 
  TextEditingController searchController = TextEditingController(); // 검색 controller
  ScrollController scrollController = ScrollController(); // GridViewBbuilder용
  List<Map<String,String>> procduct = []; // 상품 데이터 받아올 곳
  List<String> brand_name = ['kin','nike','nike','nike',"nike","nike","nike","nike","nike","nike","nike"];
  List<String> procduct_name = ['터프 테라 스웨이드','에어 맥스','어쩌구','저쩌구',"11","111","111","333","444","333","22"]; // 상품명 데이터 받아올 곳
  List<String> imageName = ['images/kin.png','images/kin2.png','images/kin3.png','images/puma.png','images/puma1.png','images/puma2.png','images/kin.png','images/kin2.png','images/kin3.png','images/puma.png','images/puma1.png']; // 상품명 데이터 받아올 곳
  List<String> procduct_count = ['40','20','30','40',"11","111","111","333","444","333","22"];

  @override
  void initState() {
    super.initState();
    addData();
  }
  void addData() {
    procduct.add({
      'quantity': '30',
      'productName': '킨 제스퍼 여성화',
      'englishName': 'KEEN JASPER Women Sneakers',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            SizedBox(height: 7,),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: '검색어를 입력하세요',
                suffixIcon: IconButton(
                  onPressed: () {
                    //
                  }, 
                  icon: Icon(Icons.search)
                  ),
              ),
              keyboardType: TextInputType.text,
              maxLength: 20,
              maxLines: 1,
              ),
            )
          ],
        ),
        toolbarHeight: 100,
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 300,
              width: MediaQuery.maybeWidthOf(context),
              child: GridView.builder(
                controller: scrollController,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 1,
                  ), 
                  itemCount: imageName.length,
                  itemBuilder: (context, index) {
                  return Card(
                    child: Column(
                      children: [
                        Image.asset(
                          imageName[index],
                          width: 100,
                          height: 100,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Text(brand_name[index]),
                                  Text(procduct_name[index]),
                                ],
                              ),
                              Text(procduct_count[index]),
                            ],
                          ),
                      ],
                    ),
                  );
                  // 작업 내용 중간 push 후 수정 예정
                },
                ),
            ),
          ],
        ),
      ),
    );
  }
}
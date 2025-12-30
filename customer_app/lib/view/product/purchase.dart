import 'package:customer_app/util/pcolor.dart';
import 'package:customer_app/view/product/detail.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/* 
Description : 사용자 결제 화면
  - 1) 상세페이지에서 넘어온 상품 정보, 수량, 구매 금액등을 획득.
  - 2) 획득된 정보를 memory에 존재 함으로 snapshot으로 Data를 가져온다.
  - 3) TextEditingController에 입력한 게 있는 경우 검색으로 넘겨준다.
  - 4) 검색으로 이동후에 돌아왔을 경우 매장 정보를 가지고 와서 새로 텍스트필드에 넣어준다.
  - 5) 픽업장소 미 지정 시
      - 지점 하단 지점명 대신 "미지정"으로 입력, 텍스트 컬러 -> 회색
      - 결제하기 하단 버튼 컬러 회색 & 눌리지 않게
  - 5) 픽업 장소 정해진 상태에서 결제하기 누르면 결제 완료 페이지 띄워준다. 
Date : 2025-12-30
Author : 지현
*/

class Purchase extends StatefulWidget {
  const Purchase({super.key});

  @override
  State<Purchase> createState() => _PurchaseState();
}

class _PurchaseState extends State<Purchase> {
  // Property
  late TextEditingController branchName; //  매장명
  late bool isBranchSelected; // 픽업 장소 선택 여부
  late int _radioValue; // Radio

  @override
  void initState() {
    super.initState();
    branchName = TextEditingController();
    isBranchSelected = false;
    _radioValue = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("결제하기"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "수령매장 선택",
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                  color: Pcolor.basebackgroundColor,
                  borderRadius: BorderRadius.circular(16), // ← 동그랗게
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '지점',
                              style: TextStyle(
                                fontWeight: FontWeight.bold
                              ),
                              ),
                            Text(
                            branchName.text.isEmpty ? '미지정' : branchName.text,
                            style: TextStyle(
                              color: branchName.text.isEmpty ? Colors.grey : Colors.black,
                            ),
                          ),
                          ],
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Container(
                            height: 40,
                            child: TextField(
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                                filled: true,
                                fillColor: const Color.fromARGB(255, 194, 194, 194),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                  horizontal: 12,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () async {
                                    final result = await Get.to(() => Detail(), arguments: {
                                      'branchName': branchName.text,
                                    });
                                    if (result != null && result['branchName'] != null) {
                                      setState(() {
                                        branchName.text = result['branchName'];
                                        isBranchSelected = true; // 버튼 활성화
                                      });
                                    }
                                  },
                                  icon: Icon(
                                    Icons.search,
                                    color: Pcolor.appBarForegroundColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Text(
                "주문 상품",
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
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
                            child: Image.asset(
                              'images/logo.png',
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  "킨 재스퍼 여성 스니커즈 발라드",
                                style: TextStyle(
                                fontWeight: FontWeight.bold),),
                                Text('킨'),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "240 SIZE",
                                    style: TextStyle(
                                    fontWeight: FontWeight.bold),),
                                    Text(
                                      " / ",
                                    style: TextStyle(
                                    fontWeight: FontWeight.bold),),
                                    Text(
                                      "1 개",
                                    style: TextStyle(
                                    fontWeight: FontWeight.bold),),
                                  ],
                                ),
                                SizedBox(height: 12),
                              ],
                            ),
                            ),
                        ],
                      ),
                      Divider(),
                      SizedBox(height: 12),
                      Text("data"),
                      SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              Text(
                "최종 주문 정보",
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  decoration: BoxDecoration(
                  color: Pcolor.basebackgroundColor,
                  borderRadius: BorderRadius.circular(16), 
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        RadioGroup(
                        groupValue: _radioValue,
                        onChanged: (value) {
                          _radioValue = value!;
                          setState(() {});
                        }, 
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Radio(value: 0),Text('간편 결제'),
                              ],
                            ),
                            Row(
                              children: [
                                Radio(value: 1),Text('신용카드'),
                              ],
                            ),
                            Row(
                              children: [
                                Radio(value: 2),Text('매장에서 결제'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ]
                      )
                      ),
                )
              ),
              Text(
                "최종 주문 정보",
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  decoration: BoxDecoration(
                  color: Pcolor.basebackgroundColor,
                  borderRadius: BorderRadius.circular(16), 
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('구매가 합계'),
                                Text("382,000 원"), 
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('수수료'),
                                Text('6,000 원'),
                              ],
                            ),
                            SizedBox(height: 8),
                          ],
                        ),
                        SizedBox(height: 12),
                        Divider(),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                         Text(
                          '총 결제금액',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                         Text(
                          '388,000원',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
        );
  }
}
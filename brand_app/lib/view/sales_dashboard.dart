import 'package:flutter/material.dart';

/* 
Description : 상품 판매 및 매출 현황 화면
  - 1) 제품별 매출 현황, 제조사별 매출 비율 Row 로 한 화면에 띄워주기
      -futurebuilder _ listviewbuild 로 만들기
      - 상품명 , 컬러 , 매출 합계
  - 2) 제품별 매출 현황 글자 오른쪽에 날짜 선택 (년.월.일 각각) 해서 볼 수 있게
  - 3) 제조사 별 매출 비율
      - 파이 차트, 선 그래프 두가지로
Date : 2025-12-31
Author : 지현
*/

class SalesDashboard extends StatefulWidget {
  const SalesDashboard({super.key});

  @override
  State<SalesDashboard> createState() => _SalesDashboardState();
}

class _SalesDashboardState extends State<SalesDashboard> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
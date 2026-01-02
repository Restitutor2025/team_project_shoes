import 'dart:convert';

import 'package:brand_app/util/pcolor.dart';
import 'package:brand_app/view/sample_data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

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
  final List<SampleData> chartdata;
  const SalesDashboard({super.key, required this.chartdata});

  @override
  State<SalesDashboard> createState() => _SalesDashboardState();
}

class _SalesDashboardState extends State<SalesDashboard> {
  // Property
  List data = []; // 받아올 데이터
  late TooltipBehavior tooltipBehavior =TooltipBehavior(enable: true); //도움말;
  List<String> imageName = ['images/kin.png','images/kin2.png','images/kin3.png','images/puma.png','images/puma1.png','images/puma2.png','images/kin.png','images/kin2.png']; // 상품이미지 데이터 대신

  @override
  void initState() {
    super.initState();
    getJSONData();
  }

  
  Future<void> getJSONData() async{
    var url = Uri.parse(
      "https://raw.githubusercontent.com/who0oami/-_0430/refs/heads/main/shoes_sample", // 주소_ 변경 예정
    );
    var response = await http.get(url); 
    var dataConvertdJSON = json.decode(utf8.decode(response.bodyBytes));

    List results = dataConvertdJSON['results']; // 테이블 보면서 변경 예정
    data.addAll(results);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: data.isEmpty
        ? Text( 
          '데이터가 없습니다.',
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        )
        : Row(
          children: [
            SizedBox(
              width: 380,
              height: 600,
              child: Column(
                children: [
                  Text("제품 별 매출 현황"),
                  SizedBox(
                  width: 700,
                  height: 1200,
                    child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: Colors.white,
                          child: Row(
                            children: [
                              data[index]['image'].isEmpty
                                ? Icon(
                                  Icons.album,
                                  size: 100,
                                  )
                                  : Image.asset(
                                    imageName[index],
                                    height: 100,
                                    width: 100,
                                  ),
                                // :Image.network(
                                // data[index]['image'],
                                // height: 100,
                                // width: 100,
                                // ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data[index]['name'].toString(),
                                            style: TextStyle(
                                              color: Colors.black
                                            ),
                                          ),
                                          Text(
                                            data[index]['color'].toString(),
                                            style: TextStyle(
                                              color: Colors.black
                                            ),
                                          ),
                                        ],
                                      ),
                                  Text(
                                        data[index]['sales'].toString(),
                                        style: TextStyle(
                                          color: Colors.black
                                        ),
                                      ),
                                  ]
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      ),
                  ),
                ],
              ),
            ),
          SizedBox(
          width: 380,
          height: 600,
          child: SfCircularChart(
            title: ChartTitle(
              text: '제조사별 매출 비율\n\n'
            ),
            tooltipBehavior: tooltipBehavior,
            legend: Legend(isVisible: true),
            series:<CircularSeries<SampleData,String>> [ 
              PieSeries<SampleData,String>(
                name: '',
                dataSource: widget.chartdata,
                explode: true,//클릭 강조
                selectionBehavior: SelectionBehavior(enable: true),
                xValueMapper: (SampleData sdata,_)=> sdata.brand,
                yValueMapper:(SampleData sdata,_) => sdata.sales ,
                dataLabelSettings: DataLabelSettings(isVisible: true),
                enableTooltip: true,
              )
            ],
            ),
            ),
          ],
        ),
      ),
    );

  } // build
} // class
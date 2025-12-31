import 'package:brand_app/util/pcolor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PurchaseDetailView extends StatefulWidget {
  const PurchaseDetailView({super.key});

  @override
  State<PurchaseDetailView> createState() => _PurchaseDetailViewState();
}

class _PurchaseDetailViewState extends State<PurchaseDetailView> {

  var value = Get.arguments ?? "__";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('자세히 보기'),
        backgroundColor: Pcolor.appBarBackgroundColor,
        foregroundColor: Pcolor.appBarForegroundColor,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 15, 10),
                child: Container(
                  color: Colors.grey,
                  width: 360,
                  height: 240,
                ),
              ),
              Text('id: ${value['cemail']}'),
              Text('이름 : ${value['cname']}'),
              Text('구매번호 : ${value['pcid']}'),
              Text('제품명 : ${value['pname']}'),
              Text('구매날짜 : ${value['pdate']}'),
              Text('주문금액 : ${value['finalprice']}'),
              Text('사이즈 : ${value['size']}'),
              Text('색상 : ${value['color']}'),
              Text('수량 : ${value['quantity']}'),
              Text('현재 상태: ${value['pstatus']}')
            ],
          ),
        ),
      ),
    );
  }
}
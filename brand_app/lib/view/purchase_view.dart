import 'package:brand_app/util/pcolor.dart';
import 'package:brand_app/view/purchase_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PurchaseView extends StatefulWidget {
  const PurchaseView({super.key});

  @override
  State<PurchaseView> createState() => _PurchaseViewState();
}

class _PurchaseViewState extends State<PurchaseView> {
  // Property

  TextEditingController searchController = TextEditingController();

  final Map<String, Object?> pc1 = {
    "pcid": 1,
    "cid": 1,
    "cemail": 'kimbobbbbb@xyz.com',
    "cname": '김밥',
    "pname": '나이키 아디다스',
    "pdate": DateTime(2025, 12, 31, 11, 10, 33),
    "finalprice": 540000,
    "size": 245,
    "color": 'White',
    "quantity": 3,
    "pstatus": '수령대기'
  };
  final Map<String, Object?> pc2 = {
    "pcid": 2,
    "cid": 2,
    "cemail": 'stststst@iii.com',
    "cname": '스티커',
    "pname": '나이키 아디다스',
    "pdate": DateTime(2025, 12, 31, 08, 19, 20),
    "finalprice": 540000,
    "size": 255,
    "color": 'White',
    "quantity": 3,
    "pstatus": '반품완료'
  };
  final Map<String, Object?> pc3 = {
    "pcid": 3,
    "cid": 3,
    "cemail": '348957340@uyssre.com',
    "cname": '김상준',
    "pname": '나이키 아디다스',
    "pdate": DateTime(2025, 12, 30, 16, 10, 51),
    "finalprice": 540000,
    "size": 270,
    "color": 'Red',
    "quantity": 3,
    "pstatus": '반품대기'
  };
  final Map<String, Object?> pc4 = {
    "pcid": 4,
    "cid": 4,
    "cemail": 'asdas344as@neves.com',
    "cname": '데이비드 길모어',
    "pname": '나이키 아디다스',
    "pdate": DateTime(2025, 12, 29, 21, 50, 08),
    "finalprice": 540000,
    "size": 235,
    "color": 'White',
    "quantity": 3,
    "pstatus": '주문완료'
  };
  final Map<String, Object?> pc5 = {
    "pcid": 5,
    "cid": 5,
    "cemail": '390dfs909fd@kingfd.com',
    "cname": '크리스 마틴',
    "pname": '나이키 아디다스',
    "pdate": DateTime(2025, 12, 30, 11, 14, 24),
    "finalprice": 140000,
    "size": 245,
    "color": 'White',
    "quantity": 1,
    "pstatus": '수령완료'
  };

  late final List<Map<String, Object?>> data;

  @override
  void initState() {
    super.initState();
    data = [pc1, pc2, pc3, pc4, pc5];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('주문 조회'),
        backgroundColor: Pcolor.appBarBackgroundColor,
        foregroundColor: Pcolor.appBarForegroundColor,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Stack(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.9,
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25)
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  child: IconButton(
                    onPressed: () {
                      //
                    },
                    icon: Icon(Icons.search, size: 40),
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Card(
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 15, 10),
                            child: Container(
                              color: Colors.grey,
                              width: 120,
                              height: 100,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width*0.25,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('id: ${data[index]['cemail']}', style: TextStyle(fontWeight: FontWeight.bold)),
                                          Text('이름 : ${data[index]['cname']}'),
                                          Text('구매번호 : ${data[index]['pcid']}'),
                                          Text('제품명 : ${data[index]['pname']}'),
                                          Text('구매날짜 : ${data[index]['pdate']}'),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width*0.15,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('주문금액 : ${data[index]['finalprice']}'),
                                          Text('사이즈 : ${data[index]['size']}'),
                                          Text('색상 : ${data[index]['color']}'),
                                          Text('수량 : ${data[index]['quantity']}'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Text('현재 상태: ${data[index]['pstatus']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          Padding(
                            padding: const EdgeInsets.all(25.0),
                            child: ElevatedButton(
                              onPressed: () => Get.to(
                                PurchaseDetailView(),
                                arguments: data[index]
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.circular(5)
                                ),
                              ),
                              child: Text('자세히 보기')
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
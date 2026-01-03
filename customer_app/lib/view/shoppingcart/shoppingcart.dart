import 'dart:convert';

import 'package:customer_app/ip/ipaddress.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class Shoppingcart extends StatefulWidget {
  const Shoppingcart({super.key});

  @override
  State<Shoppingcart> createState() => _ShoppingcartState();
}

class _ShoppingcartState extends State<Shoppingcart> {
  List data=[];
  List imagedata=[];
  List colordata=[];
  List namedata=[];
  List sizedata=[];
  
  late int count;
  @override
  void initState() {
    super.initState();
    getJSONData();
    // getJSONDataimage();
    count=0;
  }

  Future<void> getJSONData()async{
    var url=Uri.parse("${IpAddress.baseUrl}/product/selectcart");
    var response =await http.get(url);
    data.clear();
    var dataConvertedJSON =json.decode(utf8.decode(response.bodyBytes));
    print("결과$dataConvertedJSON");
    final List  result =dataConvertedJSON['results'];
    data.addAll(result);
    setState(() {});

  }
   Future<void> getJSONDataimage()async{
    var url=Uri.parse("${IpAddress.baseUrl}/productimage/view2");
    var response =await http.get(url);
    imagedata.clear();
    var dataConvertedJSON =json.decode(utf8.decode(response.bodyBytes));
    List result =dataConvertedJSON['results'];
    imagedata.addAll(result);
    setState(() {});

  }

//  Future<void> getJSONDatacolor()async{
//     var url=Uri.parse("http://172.16.250.199:8008/color/select");
//     var response =await http.get(url);
//     colordata.clear();
//     var dataConvertedJSON =json.decode(utf8.decode(response.bodyBytes));
//     List result =dataConvertedJSON['results'];
//     colordata.addAll(result);
//     setState(() {});

//   }

//  Future<void> getJSONDataname()async{
//     var url=Uri.parse("http://172.16.250.199:8008/name/select");
//     var response =await http.get(url);
//     namedata.clear();
//     var dataConvertedJSON =json.decode(utf8.decode(response.bodyBytes));
//     List result =dataConvertedJSON['results'];
//     namedata.addAll(result);
//     setState(() {});

//   }


// Future<void> getJSONDatasize()async{
//     var url=Uri.parse("http://172.16.250.199:8008/size/select");
//     var response =await http.get(url);
//     sizedata.clear();
//     var dataConvertedJSON =json.decode(utf8.decode(response.bodyBytes));
//     List result =dataConvertedJSON['results'];
//     sizedata.addAll(result);
//     setState(() {});

//   }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "장바구니",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      /// ================= 리스트 =================
      body:
       Center(
        
         child: data.isEmpty
         ?Center(child: Text("데이터가 없습니다"),)
         :ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            
         
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      // child: Image.network(
                      //   imagedata[0]['path'],
                      //   width: 80,
                      //   height: 80,
                      //   fit: BoxFit.cover,
                      // ),
                    ),
         
                    const SizedBox(width: 12),
         
                    /// 상품 정보
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text(
                          //   namedata[index]['name'],
                          //   style: const TextStyle(
                          //     fontWeight: FontWeight.bold,
                          //     fontSize: 14,
                          //   ),
                          // ),
                          const SizedBox(height: 4),
                          Text(
                            data[index]['ename'],
                            style: const TextStyle(fontSize: 13),
                          ),
         
                          const SizedBox(height: 6),
         
                          /// 사이즈 & 색상
                          // Text(
                          //   "사이즈: ${sizedata[index]['size']} / 색상: ${colordata[index]['color']}",
                          //   style: TextStyle(
                          //     fontSize: 12,
                          //     color: Colors.grey[700],
                          //   ),
                          // ),
         
                          const SizedBox(height: 10),
         
                          /// 수량 조절
                          Row(
                            children: [
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                    if (data[index]['quantity'] > 1) {
                                      data[index]['quantity']--;
                                    }
         
                                  setState(() {
                                  });
                                },
                                icon: const Icon(Icons.remove),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  "${data[index]['quantity']}",
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  setState(() {
                                    data[index]['quantity']++;
                                  });
                                },
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
         
                    /// 가격 + 삭제
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                             
                            });
                          },
                          child: const Icon(Icons.close, size: 20),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          "${data[index]['price']}원",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
               ),
       ),

      /// ================= 하단 결제 =================
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              "총결제금액: 원",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
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
              child: const Text("구매하기"),
            ),
          ),
        ],
      ),
    );
  }

  // ================= 총 결제 금액 =================
  // int totalPrice() {
  //   int total = 0;
  //   for (var item in ) {
  //     total += item['price'] * item['quantity']as int;
  //   }
  //   return total;
  // }
}

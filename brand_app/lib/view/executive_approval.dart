import 'dart:convert';

import 'package:brand_app/ip/ipaddress.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ExecutiveApproval extends StatefulWidget {
  const ExecutiveApproval({super.key});

  @override
  State<ExecutiveApproval> createState() => _ExecutiveApprovalState();
}

class _ExecutiveApprovalState extends State<ExecutiveApproval> {
  List data=[];
    Future<void> getJSONData()async{
    var url=Uri.parse("${IpAddress.baseUrl}/request/select");
    var response =await http.get(url);
    data.clear();
    var dataConvertedJSON =json.decode(utf8.decode(response.bodyBytes));
    List result =dataConvertedJSON['results'];
    data.addAll(result);
    setState(() {});

  }

  @override
  void initState() {
    super.initState();
   getJSONData();
  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("data"),
      ),

      body: Center(
        child:data.isEmpty
        ?Center(child: Text("작성된 품의가 없습니다"),)
        :ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            return Card(
              child: Column(
                children: [
                  Row(
                    children: [
                      Text("이름: ${data[index]["requester_name"]}"),
                      Text("지점 위치: ${data[index]["store_name"]}"),
                    ],
                  ),
                  Row(
                    children: [
                      Text("제조사:${data[index]["manufacturer_name"]}"),
                      Text("제품번호:${data[index]["productnumber"]}"),
                    ],
                  ),
                  Row(
                    children: [
                      Text("Size: ${data[index]["size"]}"),
                      Text("Color: :${data[index]["color"]}"),
                    ],
                  ),
                  Row(
                    children: [
                      Text("수량:${data[index]["quantity"]}"),
                      Text("다음 결제자:${data[index]["next_approver_name"]}"),
                    ],
                  ),
                ],
              ),
            );
          },
          )
      ),
    );
  }
}
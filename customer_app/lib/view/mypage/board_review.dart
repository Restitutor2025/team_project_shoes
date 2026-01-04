import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/config.dart' as config;
import 'package:customer_app/model/name.dart';
import 'package:customer_app/model/product.dart';
import 'package:customer_app/model/product_size.dart';
import 'package:customer_app/model/purchase.dart';
import 'package:customer_app/model/review.dart';
import 'package:customer_app/util/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

//  board_review

/*
  Create: 30/12/2025 16:11, Creator: Chansol, Park
  Update log:
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
    02/01/2026 11:47, 'Point 1, Actual connection to Review DB, review null check', Creator: Chansol, Park
  Version: 1.0
  Dependency:
  Desc: board_review

  DateTime MUST converted using value.toIso8601String()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class BoardReview extends StatefulWidget {
  const BoardReview({super.key});

  @override
  State<BoardReview> createState() => _BoardReviewState();
}

class PurchaseRow {
  final Purchase purchase;
  final String? productName;
  final String? imageUrl; // 또는 path

  PurchaseRow({
    required this.purchase,
    required this.productName,
    required this.imageUrl,
  });
}

class _BoardReviewState extends State<BoardReview> {
  //  Property
  late TextEditingController tEC1;
  late double reviewScore;
  //  Point 1
  late bool starChosen;
  late bool reviewText;
  late Product product;
  late PurchaseRow purchaseRow;
  late int pNumber;

  @override
  void initState() {
    super.initState();
    tEC1 = TextEditingController();
    _initreview();
    reviewScore = 0;
    //  Point 1
    starChosen = false;
    reviewText = false;
  }

  _initreview() async{
    purchaseRow = Get.arguments;
    pNumber = purchaseRow.purchase.pid;
    product = getJSONData('product');
  }

  Future<List<dynamic>> getJSONData(String page) async {
    var url = Uri.parse("http://$hostip:8000/$page");
    var response = await http.get(url);

    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    final result = dataConvertedJSON["results"].first;

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("리뷰작성", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade300),
        ),
      ),

      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 40, 30, 0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Card(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Image.asset(
                              config.rlogoImage,
                              width: 50,
                              height: 50,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dName.name,
                                    style: TextStyle(fontSize: 17),
                                  ),
                                  Text(
                                    '(${purchaseRow.productName})',
                                    style: TextStyle(fontSize: 17),
                                  ),
                                  Text(
                                    '사이즈: ${dSize.size}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    '가격: ${purchaseRow.purchase.finalprice}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    '구매 갯수: ${purchaseRow.purchase.quantity}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Text('이 상품에 대해 얼마나 만족 하시나요?'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
              child: RatingBar(
                initialRating: reviewScore,
                unratedColor: Colors.white,
                allowHalfRating: true,
                itemCount: 5,
                ratingWidget: RatingWidget(
                  full: const Icon(Icons.star, color: Colors.black),
                  half: const Icon(Icons.star_half, color: Colors.black),
                  empty: const Icon(Icons.star_border, color: Colors.black),
                ),
                onRatingUpdate: (value) {
                  setState(() {
                    reviewScore = value;
                    if (!starChosen) {
                      starChosen = true;
                    }
                  });
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
              child: Text('이 상품에 대해 자세하게 적어주세요.'),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: TextField(
                  minLines: 8,
                  maxLines: null,
                  controller: tEC1,
                  keyboardType: TextInputType.text,
                  onTapOutside: (event) => FocusScope.of(context).unfocus(),
                  onChanged: (value) {
                    setState(() {
                      tEC1.text.trim() == ''
                          ? reviewText = false
                          : reviewText = true;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '리뷰를 작성해주세요!',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: ElevatedButton(
          onPressed: () async {
            await reviewDialog();
            //
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text('리뷰 작성 완료', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  } //  build

  //  Functions
  //  Point 1
  Future<void> submitReview() async {
    final Review review = Review(
      cid: 1.toString(), //  NIF in actual release
      pcid: dPurchase.id!,
      timestamp: DateTime.now(),
      contents: tEC1.text.trim(),
      star: reviewScore,
    );

    final querySnapshot = await FirebaseFirestore.instance
        .collection('review')
        .where('cid', isEqualTo: dPurchase.cid)
        .where('pcid', isEqualTo: dPurchase.id)
        .limit(1)
        .get();
        
    if (querySnapshot.docs.isNotEmpty) {
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('리뷰 작성 불가'),
          content: Text('이미 이 구매에 대한 리뷰를 작성하셨습니다.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('확인'),
            ),
          ],
        ),
      );
      return;
    }
    {
      await FirebaseFirestore.instance.collection('review').add(review.toMap());
      if (!mounted) return;
      setState(() {
        starChosen = false;
        reviewText = false;
        tEC1.clear();
        reviewScore = 0;
      });
    }
  }

  Future<void> reviewDialog() async {
    final String desc;
    if (starChosen == false) {
      desc = "별점을 입력하지 않았습니다.";
    } else if (reviewText == false) {
      desc = "리뷰 내용을 입력하지 않았습니다.";
    } else {
      desc = "리뷰를 확정 하겠습니까?";
    }
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('알림'),
          content: Text(desc),
          actions: [
            TextButton(
              onPressed: () async {
                if (!(starChosen && reviewText)) {
                  Get.back();
                  return;
                }
                try {
                  await submitReview();
                  Snackbar().okSnackBar('저장 성공', '리뷰 저장에 성공했습니다.');
                  Get.back();
                  Get.back();
                } catch (e) {
                  print('SAVE ERROR: $e');
                  Get.back();
                  Snackbar().errorSnackBar('저장 실패', '리뷰 저장에 실패했습니다,');
                }
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }
} //  class

import 'package:customer_app/config.dart' as config;
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

//  board_review

/*
  Create: 30/12/2025 16:11, Creator: Chansol, Park
  Update log:
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
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

class _BoardReviewState extends State<BoardReview> {
  //  Property

  late TextEditingController tEC1;

  late double reviewScore;

  @override
  void initState() {
    super.initState();

    tEC1 = TextEditingController();

    reviewScore = 0;
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

                height: 120,

                child: Card(
                  color: Colors.white,

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                    children: [
                      Image.asset(config.rlogoImage, width: 50, height: 50),

                      Text('\$상품 이름', style: TextStyle(fontSize: 17)),

                      Text(
                        '\$상품 정보',

                        style: TextStyle(
                          fontSize: 14,

                          color: const Color.fromARGB(255, 224, 223, 223),
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
          onPressed: () {
            reviewScore = 0;

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
  }
}

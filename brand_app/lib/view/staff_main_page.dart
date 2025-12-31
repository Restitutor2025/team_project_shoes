import 'package:brand_app/view/ask_chat.dart';
import 'package:brand_app/view/image_app_page.dart';
import 'package:brand_app/view/purchase_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffMainpage extends StatefulWidget {
  const StaffMainpage({super.key});

  @override
  State<StaffMainpage> createState() =>
      _StaffMainpageState();
}

class _StaffMainpageState extends State<StaffMainpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.black),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ElevatedButton(
                      onPressed: () =>
                          Get.to(ImageAppPage()),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(
                          MediaQuery.of(
                                context,
                              ).size.width *
                              0.2,
                          MediaQuery.of(
                                context,
                              ).size.height *
                              0.35,
                        ),
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadiusGeometry.circular(
                                4,
                              ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.add_outlined,
                            size: 75,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 5,
                            ),
                            child: Text(
                              "상품등록",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(
                          MediaQuery.of(
                                context,
                              ).size.width *
                              0.2,
                          MediaQuery.of(
                                context,
                              ).size.height *
                              0.35,
                        ),
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadiusGeometry.circular(
                                4,
                              ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons
                                .photo_size_select_actual_sharp,
                            size: 75,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 5,
                            ),
                            child: Text(
                              "배너등록",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(
                          MediaQuery.of(
                                context,
                              ).size.width *
                              0.2,
                          MediaQuery.of(
                                context,
                              ).size.height *
                              0.35,
                        ),
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadiusGeometry.circular(
                                4,
                              ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.task, size: 75),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 5,
                            ),
                            child: Text(
                              "상품재고",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(
                          MediaQuery.of(
                                context,
                              ).size.width *
                              0.2,
                          MediaQuery.of(
                                context,
                              ).size.height *
                              0.35,
                        ),
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadiusGeometry.circular(
                                4,
                              ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.bar_chart_outlined,
                            size: 75,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 5,
                            ),
                            child: Text(
                              "판매 및 매출 현황",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ElevatedButton(
                      onPressed: () => Get.to(AskChat()),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(
                          MediaQuery.of(
                                context,
                              ).size.width *
                              0.2,
                          MediaQuery.of(
                                context,
                              ).size.height *
                              0.35,
                        ),
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadiusGeometry.circular(
                                4,
                              ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.chat,
                            size: 75,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 5,
                            ),
                            child: Text(
                              "문의내역조회",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ElevatedButton(
                      onPressed: () => Get.to(PurchaseView()),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(
                          MediaQuery.of(
                                context,
                              ).size.width *
                              0.2,
                          MediaQuery.of(
                                context,
                              ).size.height *
                              0.35,
                        ),
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadiusGeometry.circular(
                                4,
                              ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_outlined,
                            size: 75,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 5,
                            ),
                            child: Text(
                              "주문조회",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(
                          MediaQuery.of(
                                context,
                              ).size.width *
                              0.2,
                          MediaQuery.of(
                                context,
                              ).size.height *
                              0.35,
                        ),
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadiusGeometry.circular(
                                4,
                              ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.check_box, size: 75),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 5,
                            ),
                            child: Text(
                              "수주조회",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(
                          MediaQuery.of(
                                context,
                              ).size.width *
                              0.2,
                          MediaQuery.of(
                                context,
                              ).size.height *
                              0.35,
                        ),
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadiusGeometry.circular(
                                4,
                              ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.content_paste_go_outlined,
                            size: 75,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 5,
                            ),
                            child: Text(
                              "품의작성",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

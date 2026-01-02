import 'package:customer_app/config.dart' as config;
import 'package:customer_app/model/name.dart';
import 'package:customer_app/model/product.dart';
import 'package:customer_app/model/product_image.dart';
import 'package:customer_app/model/purchase.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PurchaseList extends StatefulWidget {
  const PurchaseList({super.key});

  @override
  State<PurchaseList> createState() => _PurchaseListState();
}

class _PurchaseListState extends State<PurchaseList> {
  //  Property
  late List<Purchase> totalPurchases = [];
  late List<dynamic> totalProducts = [];
  late List<dynamic> totalImages = [];
  late List<dynamic> totalNames = [];

  @override
  void initState() {
    super.initState();
    setPurchaseList();
  }

  void setPurchaseList() async {
    try {
      final List<Purchase> data = await config.getJSONData('purchase') as List<Purchase>;
      List<int> searchIds = data.map((e) => e.pid).toList();

      final List<Product>data2 = await config.getJSONData('product') as List<Product>;
      final List<Name>data3 = await config.getJSONData('productname') as List<Name>;
      final List<ProductImage>data4 = await config.getJSONData('productimage') as List<ProductImage>;

      if (!mounted) {
        debugPrint('ERROR: widget already disposed');

        return;
      }
      setState(() {
        totalPurchases = data;
        totalProducts = data2;
      });
    } catch (e, stack) {
      debugPrint('setPurchaseList error: $e');
      debugPrint('$stack');

      if (!mounted) {
        debugPrint('ERROR: widget already disposed');
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("구매 목록", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade300),
        ),
      ),
      body: totalPurchases.isEmpty
          ? Center(child: CircularProgressIndicator(),)
          : ListView.builder(
              itemCount: totalPurchases.length,
              itemBuilder: (context, index) {
                final purchase = totalPurchases[index];
                final product = totalProducts[index];
                final pName = totalNames[index];
                return SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 180,
                  child: Card(
                    color: Colors.white,
                    child: Row(
                      children: [
                        Image.asset(
                          config.rlogoImage,
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  10,
                                  30,
                                  0,
                                  0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      '\$상품 이름',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    Text('${config.formatter.format(purchase.quantity)}개', style: TextStyle(fontSize: 15)),
                                    Text(
                                      '총 구매액: ${config.formatter.format(purchase.finalprice)}',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    '구매 날짜: ${DateFormat(config.dateFormat).format(totalPurchases[index].purchasedate)}',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 100,
                                      height: 35,
                                      child: ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          elevation: 1,
                                        ),
                                        child: Text(
                                          '반품 신청',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    '수령 날짜: ${DateFormat(config.dateFormat).format(totalPurchases[index].pickupdate)}',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 100,
                                      height: 35,
                                      child: ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          elevation: 1,
                                        ),
                                        child: Text(
                                          '리뷰 하기',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

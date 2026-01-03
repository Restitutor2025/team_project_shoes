import 'package:customer_app/ip/ipaddress.dart';
import 'package:customer_app/model/product.dart';
import 'package:customer_app/view/product/detail.dart';
import 'package:flutter/material.dart';
import 'package:customer_app/util/pcolor.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  PageController _pageController = PageController(
    viewportFraction: 0.82,
  );
  int _currentPage = 0; //추천상품 슬라이더 페이지

  List<Product> data = [];
  //<<<<<<<<<나중에 DB에 채워질 최근 본 상품
  //<<<<<<<<<<<<

  @override
  void initState() {
    super.initState();
    getJSONdata();
  }

  Future<void> getJSONdata() async {
    var url = Uri.parse(
      '${IpAddress.baseUrl}/product/select',
    );
    try {
      var response = await http.post(url);
      if (response.statusCode == 200) {
        var dataConvertedJSON = json.decode(
          utf8.decode(response.bodyBytes),
        );
        data.clear();
        setState(() {});

        if (dataConvertedJSON is List) {
          data = dataConvertedJSON
              .map((json) => Product.fromJson(json))
              .toList();
        }
      }
    } catch (e) {
      print('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pcolor.basebackgroundColor,
      appBar: AppBar(
        backgroundColor: Pcolor.appBarBackgroundColor,
        foregroundColor: Pcolor.appBarForegroundColor,
        elevation: 0,
        leadingWidth: 100,
        leading: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
          child: Image.asset(
            'images/logo.png',
            width: 10,
            fit: BoxFit.contain,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                30,
                20,
                0,
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: '상품을 검색해보세요',
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                '추천상품 🔥',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 240,
              child: PageView.builder(
                controller: _pageController,
                itemCount: data.isEmpty ? 0 : data.length,

                onPageChanged: (value) {
                  _currentPage = value;
                  setState(() {});
                },
                itemBuilder: (context, index) {
                  final bool isActive =
                      index == _currentPage;

                  ///슬라이드 바 디자인 코드
                  return AnimatedScale(
                    scale: isActive ? 1.0 : 0.9,
                    duration: const Duration(
                      milliseconds: 300,
                    ),

                    curve: Curves.easeOut,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius:
                              BorderRadius.circular(24),
                        ),
                        child: _ProductCard(
                          product: data[index],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 슬라이더 인디케이터
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final bool isActive = index == _currentPage;

                return AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 300,
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                  ),
                  width: isActive ? 10 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.black
                        : Colors.grey[400],
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),

            const SizedBox(height: 24),

            // 신상상품 섹션
            ProductSection(title: '신상상품', product: data),

            const SizedBox(height: 32),

            // 인기상품 섹션
            ProductSection(
              title: '오늘의 인기상품',
              product: data,
            ),

            // >>>>>>>>👇 나중에 DB 붙이면 최근 본 상품 조건부
            if (data.isNotEmpty) ...[
              const SizedBox(height: 32),
              ProductSection(
                title: '최근 본 상품',
                product: data,
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product; //  >>>>>>>>>>>모델 연결

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(Detail(), arguments: product);
      },
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Image.network(
                  '${IpAddress.baseUrl}/productimage/view?pid=${product.id}&position=main', //상품이미지
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.ename, //>>>>>>>>>>상품name
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              '${product.price}', //>>>>>>>>>>상품price
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 상품 카드 섹션
class ProductSection extends StatelessWidget {
  final String title;
  final List<Product> product;

  const ProductSection({
    super.key,
    required this.title,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            itemCount: product.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _ProductCard(product: product[index]);
            },
          ),
        ),
      ],
    );
  }

  ///

  ///
}

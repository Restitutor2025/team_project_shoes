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
  final PageController _pageController = PageController(viewportFraction: 0.82);
  int _currentPage = 0;
  List<Product> data = [];
  Map<int, String> koreanNames = {}; 

  @override
  void initState() {
    super.initState();
    getJSONdata();
  }

  Future<void> getJSONdata() async {
    var url = Uri.parse('${IpAddress.baseUrl}/product/select');
    try {
      var response = await http.post(url);
      if (response.statusCode == 200) {
        var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
        if (dataConvertedJSON is List) {
          List<Product> fetchedData = dataConvertedJSON.map((json) => Product.fromJson(json)).toList();
          
          // 중복 제거 (이름 기준)
          final Map<String, Product> uniqueMap = {};
          for (var item in fetchedData) {
            if (!uniqueMap.containsKey(item.ename)) uniqueMap[item.ename] = item;
          }
          
          data = uniqueMap.values.toList();
          setState(() {});
          // 각 상품의 한글 이름 가져오기
          for (var item in data) { fetchKoreanName(item); }
        }
      }
    } catch (e) { debugPrint('Error: $e'); }
  }

  Future<void> fetchKoreanName(Product product) async {
    final int targetPid = (product.mid != null && product.mid != 0) ? product.mid! : product.id!;
    var url = Uri.parse('${IpAddress.baseUrl}/productname/select?pid=$targetPid');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        List results = jsonResponse['results'];
        if (results.isNotEmpty) {
          setState(() { koreanNames[product.id!] = results[0]['name']; });
        }
      }
    } catch (e) { debugPrint('Name Fetch Error: $e'); }
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
          padding: const EdgeInsets.only(left: 20),
          child: Image.asset('images/logo.png', fit: BoxFit.contain),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchField(),
            _buildSectionTitle('추천상품 🔥'),
            _buildSlider(),
            _buildIndicator(),
            const SizedBox(height: 24),
            ProductSection(title: '신상상품', product: data, koreanNames: koreanNames),
            const SizedBox(height: 32),
            ProductSection(title: '오늘의 인기상품', product: data, koreanNames: koreanNames),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // 1) 검색창 디자인 복구
  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
      child: TextField(
        decoration: InputDecoration(
          hintText: '상품을 검색해보세요',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.all(20.0),
    child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  );

  // 2) 슬라이더 디자인 복구
  Widget _buildSlider() {
    return SizedBox(
      height: 240,
      child: PageView.builder(
        controller: _pageController,
        itemCount: data.length,
        onPageChanged: (v) => setState(() => _currentPage = v),
        itemBuilder: (context, index) {
          return AnimatedScale(
            scale: index == _currentPage ? 1.0 : 0.9,
            duration: const Duration(milliseconds: 300),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: _ProductCard(product: data[index], koreanName: koreanNames[data[index].id]),
            ),
          );
        },
      ),
    );
  }

  // 3) 인디케이터 디자인 복구
  Widget _buildIndicator() {
    int count = data.length > 5 ? 5 : data.length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == _currentPage ? 10 : 6, height: 6,
          decoration: BoxDecoration(color: index == _currentPage ? Colors.black : Colors.grey[400], borderRadius: BorderRadius.circular(3)),
        );
      }),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final String? koreanName;

  const _ProductCard({required this.product, this.koreanName});

  @override
  Widget build(BuildContext context) {
    final int imageId = (product.mid != null && product.mid != 0) ? product.mid! : product.id!;

    return GestureDetector(
      onTap: () => Get.to(
        () => const Detail(), 
        arguments: {'product': product, 'koreanName': koreanName} 
      ),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Image.network(
                  '${IpAddress.baseUrl}/productimage/view?pid=$imageId&position=main',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              koreanName ?? product.ename, 
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text('${product.price} 원', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class ProductSection extends StatelessWidget {
  final String title;
  final List<Product> product;
  final Map<int, String> koreanNames;

  const ProductSection({super.key, required this.title, required this.product, required this.koreanNames});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: product.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = product[index];
              return _ProductCard(product: item, koreanName: koreanNames[item.id]);
            },
          ),
        ),
      ],
    );
  }
}
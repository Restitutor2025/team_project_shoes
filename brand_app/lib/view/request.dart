import 'dart:convert';

import 'package:brand_app/ip/ipaddress.dart';
import 'package:brand_app/util/pcolor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class Request extends StatefulWidget {
  const Request({super.key});

  @override
  State<Request> createState() => _RequestState();
}

class _RequestState extends State<Request> {
  final TextEditingController _nameController =
      TextEditingController();
  // 수량 관리는 컨트롤러 하나로 통합 (초기값 1)
  final TextEditingController _quantityController =
      TextEditingController(text: '1');

  String? _selectedMaker;
  String? _selectedProduct;
  String? _selectedSize;
  String? _selectedColor;

  // 더미 데이터
  final List<String> _makers = [
    '나이키',
    '퓨마',
    '아디다스',
    '스니커즈',
    '뉴발란스',
  ];
  List<String> _products = [];
  bool _isLoadingProducts = false; // 로딩 상태 확인용

  @override
  void initState() {
    super.initState();
    _fetchProducts(); // 페이지 시작 시 데이터를 가져옵니다.
  }

  // API 호출 함수
  Future<void> _fetchProducts() async {
    setState(() => _isLoadingProducts = true);

    try {
      final response = await http.get(
        Uri.parse('${IpAddress.baseUrl}/product/select'),
      );

      if (response.statusCode == 200) {
        // 서버 응답이 [ {"pname": "에어맥스"}, {"pname": "574"} ] 형태라고 가정
        final List<dynamic> data = json.decode(
          utf8.decode(response.bodyBytes),
        );

        setState(() {
          // 서버 데이터에서 'pname' 혹은 'name' 컬럼만 추출하여 리스트화
          _products = data
              .map((item) => item['ename'].toString())
              .toList();
          _isLoadingProducts = false;
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print("상품 목록 로드 에러: $e");
      setState(() => _isLoadingProducts = false);
    }
  }

  final List<String> _colors = ['화이트', '레드', '블랙', '브라운'];
  final List<String> _sizes = List.generate(
    13,
    (i) => (230 + (i * 5)).toString(),
  );

  // 수량 변경 로직 통합
  void _updateQuantity(int amount) {
    int current =
        int.tryParse(_quantityController.text) ?? 0;
    int newValue = current + amount;
    if (newValue < 1) newValue = 1; // 최소 수량 1 유지
    setState(() {
      _quantityController.text = newValue.toString();
    });
  }

  //1. 상품 품의 등록
  Future<int?> insertAction() async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${IpAddress.baseUrl}/imployee/uproad'),
      );
      request.fields['ename'] = _nameController.text;
      request.fields['pid'] = _selectedMaker.toString();
      request.fields['ename'] = _selectedProduct.toString();
      request.fields['size'] = _selectedSize.toString();
      request.fields['color'] = _selectedColor.toString();
      request.fields['quantity'] = _quantityController.text;

      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        var data = json.decode(respStr);
        return int.tryParse(data['pid'].toString());
      }
    } catch (e) {
      debugPrint("insertAction 에러: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('품의서'),
        centerTitle: true,
        backgroundColor: Pcolor.appBarBackgroundColor,
        foregroundColor: Pcolor.appBarForegroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('직원 이름'),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: '이름을 입력하세요',
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            _buildLabel('제조사명'),
            _buildDropdown(_makers, _selectedMaker, (val) {
              setState(() {
                _selectedMaker = val;
                _selectedProduct = null;
                _selectedSize = null;
                _selectedColor = null;
              });
            }),
            const SizedBox(height: 20),

            _buildLabel('상품명'),
            _isLoadingProducts
                ? const LinearProgressIndicator() // 로딩 중일 때 표시
                : _buildDropdown(
                    _products,
                    _selectedProduct,
                    _selectedMaker == null
                        ? null // 제조사를 먼저 선택해야 활성화
                        : (val) => setState(
                            () => _selectedProduct = val,
                          ),
                  ),
            const SizedBox(height: 20),

            _buildLabel('사이즈'),
            _buildDropdown(
              _sizes,
              _selectedSize,
              _selectedProduct == null
                  ? null
                  : (val) {
                      setState(() => _selectedSize = val);
                    },
              suffix: '(mm)단위',
            ),
            const SizedBox(height: 20),

            _buildLabel('컬러'),
            _buildDropdown(
              _colors,
              _selectedColor,
              _selectedSize == null
                  ? null
                  : (val) {
                      setState(() => _selectedColor = val);
                    },
            ),
            const SizedBox(height: 24),

            _buildLabel('발주수량'),
            // Wrap을 사용하여 버튼들이 화면 너비를 넘어가면 자동으로 줄바꿈되게 처리
            Wrap(
              spacing: 8,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 45,
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      FilteringTextInputFormatter
                          .digitsOnly,
                    ],
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          8,
                        ),
                      ),
                    ),
                  ),
                ),
                _quantityButton(1),
                _quantityButton(10),
                _quantityButton(100),
              ],
            ),
            const SizedBox(height: 40),

            Center(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _selectedColor != null
                      ? _showResultSheet
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF333333,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        8,
                      ),
                    ),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 수량 조절 버튼 위젯
  Widget _quantityButton(int unit) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => _updateQuantity(-unit),
            icon: const Icon(Icons.remove, size: 18),
            constraints: const BoxConstraints(minWidth: 35),
          ),
          Text(
            '$unit',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () => _updateQuantity(unit),
            icon: const Icon(Icons.add, size: 18),
            constraints: const BoxConstraints(minWidth: 35),
          ),
        ],
      ),
    );
  }

  // 공통 라벨 위젯
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          text: '* ',
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          children: [
            TextSpan(
              text: text,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 공통 드롭다운 위젯
  Widget _buildDropdown(
    List<String> items,
    String? value,
    ValueChanged<String?>? onChanged, {
    String? suffix,
  }) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: value,
            items: items
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  ),
                )
                .toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              hintText: '선택해주세요',
            ),
          ),
        ),
        if (suffix != null)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              suffix,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
      ],
    );
  }

  // 결과 확인 창
  void _showResultSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F7),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$_selectedMaker $_selectedProduct',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '직원: ${_nameController.text}\n사이즈: $_selectedSize / 컬러: $_selectedColor / 수량: ${_quantityController.text}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF333333,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    '제출하기',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

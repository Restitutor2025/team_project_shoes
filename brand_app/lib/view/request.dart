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
  final TextEditingController _quantityController =
      TextEditingController(text: '1');

  String? _selectedMaker;
  String? _selectedProduct;
  String? _selectedSize;
  String? _selectedColor;

  List<String> manufacturers = [];
  List<String> _products = [];
  bool _isLoadingProducts = false;
  bool _isLoadingmakers = false;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _fetchMakers();
  }

  // API 호출 함수
  Future<void> _fetchProducts() async {
    setState(() => _isLoadingProducts = true);
    print("데이터 요청 시작: ${IpAddress.baseUrl}/product/select");

    try {
      final response = await http.post(
        Uri.parse('${IpAddress.baseUrl}/product/select'),
        headers: {"Content-Type": "application/json"},
      );

      print("응답 상태 코드: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(
          utf8.decode(response.bodyBytes),
        );
        print("가져온 데이터 원본: $data");

        setState(() {
          // 1. 전체 데이터에서 ename만 추출
          List<String> rawNames = data
              .map((item) => item['ename'].toString())
              .toList();

          // 2. toSet()을 사용하여 중복 제거 후 다시 리스트로 변환
          _products = rawNames.toSet().toList();

          // 3. (선택) 보기 좋게 정렬
          _products.sort();

          _isLoadingProducts = false;
        });
        print("파싱된 상품 리스트: $_products");
      } else {
        print("서버 에러 응답: ${response.body}");
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print("상품 목록 로드 에러 발생: $e");
      setState(() => _isLoadingProducts = false);
    }
  }

  Future<void> _fetchMakers() async {
    setState(() => _isLoadingmakers = true);

    try {
      // 서버의 /all 또는 전체 조회 API 호출 (없을 경우를 대비해 예외처리 포함)
      final mRes = await http.get(
        Uri.parse(
          '${IpAddress.baseUrl}/manufacturername/all',
        ),
      );
      final cRes = await http.get(
        Uri.parse('${IpAddress.baseUrl}/productcolor/all'),
      );

      if (mRes.statusCode == 200 &&
          cRes.statusCode == 200) {
        setState(() {
          manufacturers = List<String>.from(
            json.decode(
              utf8.decode(mRes.bodyBytes),
            )['results'],
          );
          colorlist = List<String>.from(
            json.decode(
              utf8.decode(cRes.bodyBytes),
            )['results'],
          );
        });
      }
    } catch (e) {
      debugPrint("데이터 로드 실패: $e");
      // 서버 API가 아직 준비되지 않았을 경우를 위한 기본값 유지
      setState(() {
        manufacturers = [
          '나이키',
          '퓨마',
          '아디다스',
          '스니커즈',
          '뉴발란스',
        ];
        colorlist = ['화이트', '레드', '블랙', '브라운'];
      });
    }
  }

  List<String> colorlist = ['화이트', '레드', '블랙', '브라운'];
  final List<String> _sizes = List.generate(
    13,
    (i) => (230 + (i * 5)).toString(),
  );

  void _updateQuantity(int amount) {
    int current =
        int.tryParse(_quantityController.text) ?? 0;
    int newValue = current + amount;
    if (newValue < 1) newValue = 1;
    setState(() {
      _quantityController.text = newValue.toString();
    });
  }

  // 품의 등록 액션
  Future<int?> insertAction() async {
    try {
      print(
        "제출 데이터 확인: ${_nameController.text}, $_selectedMaker, $_selectedProduct, $_selectedSize, $_selectedColor, ${_quantityController.text}",
      );

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${IpAddress.baseUrl}/imployee/uproad'),
      );
      request.fields['ename'] = _nameController.text;
      request.fields['maker'] =
          _selectedMaker ?? ""; // 키값 확인 필요 (기존 pid에서 변경)
      request.fields['pname'] = _selectedProduct ?? "";
      request.fields['size'] = _selectedSize ?? "";
      request.fields['color'] = _selectedColor ?? "";
      request.fields['quantity'] = _quantityController.text;

      var response = await request.send();
      var respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print("등록 성공: $respStr");
        return 1;
      } else {
        print("등록 실패 (${response.statusCode}): $respStr");
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
            _buildDropdown(manufacturers, _selectedMaker, (
              val,
            ) {
              setState(() => _selectedMaker = val);
            }),
            const SizedBox(height: 20),

            _buildLabel('상품명'),
            _isLoadingProducts
                ? const LinearProgressIndicator()
                : _buildDropdown(
                    _products,
                    _selectedProduct,
                    (val) {
                      setState(
                        () => _selectedProduct = val,
                      );
                    },
                  ),
            const SizedBox(height: 20),

            _buildLabel('사이즈'),
            _buildDropdown(_sizes, _selectedSize, (val) {
              setState(() => _selectedSize = val);
            }, suffix: '(mm)단위'),
            const SizedBox(height: 20),

            _buildLabel('컬러'),
            _buildDropdown(colorlist, _selectedColor, (
              val,
            ) {
              setState(() => _selectedColor = val);
            }),
            const SizedBox(height: 24),

            _buildLabel('발주수량'),
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
                  onPressed:
                      _showResultSheet, // 조건 없이 항상 실행 가능하게 변경
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

  // --- 기존 위젯 함수들 (_quantityButton, _buildLabel, _buildDropdown, _showResultSheet 동일하게 유지) ---

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
          ),
        ],
      ),
    );
  }

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

  void _showResultSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
            Text(
              '입력된 정보 확인',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Text('상품명: ${_selectedProduct ?? "미선택"}'),
            Text('직원: ${_nameController.text}'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await insertAction();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF333333),
                ),
                child: const Text(
                  '제출하기',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:brand_app/util/pcolor.dart';
import 'package:flutter/material.dart';

class Request extends StatefulWidget {
  const Request({super.key});

  @override
  State<Request> createState() => _RequestState();
}

class _RequestState extends State<Request> {
  // 입력 제어를 위한 컨트롤러 및 변수
  final TextEditingController _nameController =
      TextEditingController();
  String? _selectedMaker;
  String? _selectedProduct;
  String? _selectedSize;
  String? _selectedColor;
  int _quantity = 1;

  // 더미 데이터
  final List<String> _makers = ['아디다스', '나이키', '뉴발란스'];
  final List<String> _products = [
    '퍼피켓',
    '에어맥스',
    '574 Classic',
  ];
  final List<String> _colors = ['블랙', '화이트', '그레이'];
  final List<String> _sizes = List.generate(
    13,
    (index) => (230 + (index * 5)).toString(),
  );

  // 수량 조절 함수
  void _updateQuantity(int amount) {
    setState(() {
      if (_quantity + amount >= 1) {
        _quantity += amount;
      }
    });
  }

  // 결과 확인 창 (BottomSheet)
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
                              '$_selectedMaker $_selectedProduct ($_selectedColor)',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '직원이름 : ${_nameController.text}  /  제조사 : $_selectedMaker  /  사이즈 : $_selectedSize  /  컬러 : $_selectedColor  /  수량 : $_quantity',
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
                  onPressed: () {
                    // 데이터베이스 저장 로직이 들어갈 곳
                    Navigator.pop(context);
                  },
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
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
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
              ),
            ),
            const SizedBox(height: 20),

            _buildLabel('제조사명'),
            _buildDropdown(
              _makers,
              _selectedMaker,
              (val) => setState(() {
                _selectedMaker = val;
                _selectedProduct = null;
              }),
            ),
            const SizedBox(height: 20),

            _buildLabel('상품명'),
            _buildDropdown(
              _products,
              _selectedProduct,
              _selectedMaker == null
                  ? null
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
                  : (val) =>
                        setState(() => _selectedSize = val),
              suffix: '(mm)단위',
            ),
            const SizedBox(height: 20),

            _buildLabel('컬러'),
            _buildDropdown(
              _colors,
              _selectedColor,
              _selectedSize == null
                  ? null
                  : (val) => setState(
                      () => _selectedColor = val,
                    ),
            ),
            const SizedBox(height: 20),

            _buildLabel('발주수량'),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[300]!,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    '$_quantity',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 10),
                _quantityBtn(1, '+1'),
                _quantityBtn(10, '+10'),
                _quantityBtn(100, '+100'),
              ],
            ),
            const SizedBox(height: 40),

            Center(
              child: SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: _selectedColor != null
                      ? _showResultSheet
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF333333,
                    ),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 공통 라벨 위젯
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Text(
            '*',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
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
              enabled:
                  onChanged != null, // 이전 단계 미선택 시 비활성화
            ),
            hint: const Text('선택해주세요'),
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

  // 수량 증가 버튼 위젯
  Widget _quantityBtn(int amount, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: OutlinedButton(
        onPressed: () => _updateQuantity(amount),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(60, 40),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.black54),
        ),
      ),
    );
  }
}

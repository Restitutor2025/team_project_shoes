import 'package:brand_app/util/pcolor.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageAppPage extends StatefulWidget {
  const ImageAppPage({super.key});

  @override
  State<ImageAppPage> createState() => _ImageAppPageState();
}

class _ImageAppPageState extends State<ImageAppPage> {
  final ImagePicker _picker = ImagePicker(); // 이미지

  // 이미지를 담을 변수 (DB 저장 전 단계)
  XFile? _mainImage;
  XFile? _detailImage;

  // 이미지 선택함수
  Future<void> _pickImage(bool isMain) async {
    final XFile? selected = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (selected != null) {
      if (isMain)
        _mainImage = selected;
      else
        _detailImage = selected;
      setState(() {});
    }
  }

  String? selectedCategory; // 카테고리
  String? selectedPrice; // 가격
  String? selectedColor; // 색깔
  String? selectedSize; // 사이즈
  String? selectedBrand; // 제조사

  // 더미데이터(나중에 DB로 교제함)
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  final List<String> categoryList = ['운동화', '슬리퍼', '구두'];

  final List<String> priceList = [
    '50,000',
    '100,000',
    '150,000',
  ];

  final List<String> colorList = ['블랙', '화이트', '그레이'];

  final List<String> sizeList = [
    '230',
    '240',
    '250',
    '260',
  ];

  final List<String> brandList = ['나이키', '아디다스', '푸마'];
  /////////>>>>>>>>>>>>>>>>>>>>>
  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('상품등록'),
        backgroundColor: Pcolor.appBarBackgroundColor,
        foregroundColor: Pcolor.appBarForegroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: SizedBox(
          width: 500,
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //
                _dropdown(
                  label: '제품명',
                  value: selectedCategory, //카테고리 선택
                  items: categoryList, // 상품 카테고리
                  onChanged: (value) {
                    //
                    selectedCategory = value;
                    setState(() {});
                  },
                ),
                _dropdown(
                  label: '가격',
                  value: selectedPrice, //가격 선택
                  items: priceList, // 가격 카테고리
                  onChanged: (value) {
                    //
                    selectedPrice = value;
                    setState(() {});
                  },
                ),
                _dropdown(
                  label: '컬러',
                  value: selectedColor, //드랍다운 선택
                  items: colorList, // 상품 카테고리
                  onChanged: (value) {
                    //
                    selectedColor = value;
                    setState(() {});
                  },
                ),
                _dropdown(
                  label: '사이즈',
                  value: selectedSize, //드랍다운 선택
                  items: sizeList, // 상품 카테고리
                  onChanged: (value) {
                    //
                    selectedSize = value;
                    setState(() {});
                  },
                ),
                _dropdown(
                  label: '제조사',
                  value: selectedBrand, //드랍다운 선택
                  items: brandList, // 상품 카테고리
                  onChanged: (value) {
                    //
                    selectedBrand = value;
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //
  /// 🔹 공통 드롭다운 위젯
  Widget _dropdown({
    required String label, //드랍다운 타이틀
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        value: value,
        hint: Text(label),
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ),
            )
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  //
}

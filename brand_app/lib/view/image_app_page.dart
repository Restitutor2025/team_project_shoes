import 'dart:io';

import 'package:brand_app/util/pcolor.dart';
import 'package:brand_app/util/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  // 이미지 선택 함수
  Future<void> _pickImage(bool isMain) async {
    final XFile? selected = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (selected != null) {
      setState(() {
        if (isMain)
          _mainImage = selected;
        else
          _detailImage = selected;
      });
      CustomSnackbar().okSnackBar(
        "알림",
        "${isMain ? '대표' : '상세'} 이미지가 선택되었습니다.",
      );
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
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 500,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
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
                  SizedBox(height: 30),
                  Center(
                    child: Text(
                      '이미지 가져오기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _buildImagePreview(
                          true,
                          _mainImage,
                          "대표 이미지 가져오기",
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildImagePreview(
                          false,
                          _detailImage,
                          "상세 이미지 가져오기",
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                  const SizedBox(height: 50),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        // DB 저장 전 밸리데이션 체크
                        if (selectedBrand == null ||
                            _mainImage == null) {
                          CustomSnackbar().errorSnackBar(
                            "입력 오류",
                            "제조사 및 대표 이미지는 필수입니다.",
                          );
                        } else {
                          CustomSnackbar().okSnackBar(
                            "완료",
                            "상품이 성공적으로 등록되었습니다.",
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF333333,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "상품 등록",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //
  /// 🔹 이미지 프리뷰 및 버튼 위젯
  Widget _buildImagePreview(
    bool isMain,
    XFile? imageFile,
    String btnText,
  ) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: imageFile == null
                  ? Icon(
                      Icons.camera_alt_outlined,
                      size: 40,
                      color: Colors.grey[400],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                      child: Image.file(
                        File(imageFile.path),
                        fit: BoxFit.cover,
                      ),
                    ),
            ),

            // 이미지가 있을 때만 X 버튼 표시
            if (imageFile != null)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    _confirmDelete(isMain);
                    Get.back();
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cancel,
                      color: Colors.black87,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ///////////////////
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _pickImage(isMain),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF333333),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              btnText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  //
  // 삭제 로직 실행
  void _confirmDelete(bool isMain) {
    CustomSnackbar().showDialog(
      "이미지 수정",
      "이미지를 삭제하시겠습니까?",
      onConfirm: () {
        // 다이얼로그에서 'OK'를 눌렀을 때만 실제 데이터 삭제
        setState(() {
          if (isMain) {
            _mainImage = null;
          } else {
            _detailImage = null;
          }
        });

        setState(() {});
      },
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

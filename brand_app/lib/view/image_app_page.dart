import 'dart:io';

import 'package:brand_app/util/pcolor.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageAppPage extends StatefulWidget {
  const ImageAppPage({super.key});

  @override
  State<ImageAppPage> createState() => _ImageAppPageState();
}

class _ImageAppPageState extends State<ImageAppPage> {
  final ImagePicker _picker = ImagePicker();

  File? mainImage;
  File? topImage;
  File? sideImage;
  File? backImage;

  ///
  ///// 제조사 테스트 데이터 (나중에 DB로 교체)
  final List<String> manufacturers = [
    '삼성',
    'LG',
    'Apple',
    'Sony',
  ];

  String? selectedManufacturer;

  // 상품명 컨트롤러
  final TextEditingController productNameController =
      TextEditingController();

  ///////////////
  Future<void> _pickImage(Function(File) onSelected) async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      // 이미지 안정화 버전
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (picked != null) {
      onSelected(File(picked.path));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('상품등록'),
        centerTitle: true,
        backgroundColor: Pcolor.appBarBackgroundColor,
        foregroundColor: Pcolor.appBarForegroundColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '*  ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.red,
                  ),
                ),
                Text(
                  '상품이미지',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),

                Text(
                  '  권장크기 300 * 300 / 용량 : 10MB 이하 / 파일 형식 : PNG,JPG,GIF',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const SizedBox(height: 16),
                _imageBox(
                  title: '대표 이미지',
                  image: mainImage,
                  onTap: () =>
                      _pickImage((f) => mainImage = f),
                ),
                const SizedBox(width: 16),
                _imageBox(
                  title: 'Top 이미지',
                  image: topImage,
                  onTap: () =>
                      _pickImage((f) => topImage = f),
                ),
                const SizedBox(width: 16),
                _imageBox(
                  title: 'Side 이미지',
                  image: sideImage,
                  onTap: () =>
                      _pickImage((f) => sideImage = f),
                ),
                const SizedBox(width: 16),
                _imageBox(
                  title: 'Back 이미지',
                  image: backImage,
                  onTap: () =>
                      _pickImage((f) => backImage = f),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  '*  ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.red,
                  ),
                ),
                Text(
                  '제조사명',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            DropdownButtonFormField<String>(
              value: selectedManufacturer,
              hint: const Text('제조사를 선택하세요'),
              items: manufacturers
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedManufacturer = value;
                });
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 30),

            Row(
              children: [
                Text(
                  '*  ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.red,
                  ),
                ),
                Text(
                  '상품명',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            TextField(
              controller: productNameController,
              maxLength: 40,
              decoration: InputDecoration(
                hintText: '상품명을 입력하세요.',
                counterText:
                    '${productNameController.text.length}/40',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {}); // 글자 수 갱신
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// 이미지 박스 위젯
Widget _imageBox({
  required String title,
  required File? image,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Stack(
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Expanded(
                child: image == null
                    ? const Icon(
                        Icons.camera_alt,
                        size: 40,
                        color: Colors.white,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                        child: Image.file(
                          image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
              ),
              Container(
                height: 36,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ❌ 아이콘 (이미지 있을 때만)
        if (image != null)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
      ],
    ),
  );
}

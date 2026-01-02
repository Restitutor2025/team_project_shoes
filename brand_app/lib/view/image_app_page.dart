import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:brand_app/util/pcolor.dart';
import 'package:brand_app/util/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;

final snack = CustomSnackbar();

class ImageAppPage extends StatefulWidget {
  const ImageAppPage({super.key});

  @override
  State<ImageAppPage> createState() => _ImageAppPageState();
}

class _ImageAppPageState extends State<ImageAppPage> {
  // 가격 설정
  final TextEditingController priceController =
      TextEditingController(text: '0');

  // 사이즈 드랍다운용 리스트
  final List<int> sizeList = List.generate(
    21,
    (index) => 230 + index * 3,
  ); // 230 ~ 290

  int? startSize;
  int? endSize;

  List<int> selectedSizes = [];

  final ImagePicker _picker = ImagePicker();

  File? mainImage;
  File? topImage;
  File? sideImage;
  File? backImage;

  final List<String> manufacturers = [
    '나이키',
    '퓨마',
    '아디다스',
    '스니커즈',
    '뉴발란스',
  ];

  final List<String> colorlist = ['화이트', '레드', '블랙', '브라운'];

  String? selectedManufacturer; // 제조사 드랍다운
  String? selectedColorlist; // 칼라값 드랍다운

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

  Future<void> insertAction() async {
    if (selectedManufacturer == null) {
      //errorSnackBar("제조사를 선택해주세요.");
      return;
    }
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(
        'http://172.16.250.183:8008/product/insert',
      ),
    );
    request.fields['ename'] =
        productNameController.text; //상품명
    request.fields['color'] = selectedColorlist!; // 칼라
    request.fields['size'] = selectedSizes.join(',');
    String price = priceController.text.replaceAll(',', '');
    request.fields['price'] = price; // 상품가격
    request.fields['manufacturer'] =
        selectedManufacturer!; //제조사

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var respStr = await response.stream.bytesToString();
        var data = json.decode(respStr);
        int newpid = data['pid'];
        await uploadImages(newpid);

        snack.okSnackBar('등록성공', '상품이 성공적으로 등록되었습니다.');

        return data['pid'];
      } else {
        snack.errorSnackBar('등록실패', '등록 중 에러가 발생했습니다: $e');
      }
    } catch (e) {
      print("insert error: $e");
    }
  }

  Future<void> uploadImages(int newPid) async {
    List<Map<String, dynamic>> imageTasks = [
      {'pos': 'main', 'file': mainImage},
      {'pos': 'top', 'file': topImage},
      {'pos': 'side', 'file': sideImage},
      {'pos': 'back', 'file': backImage},
    ];

    for (var task in imageTasks) {
      if (task['file'] == null) continue;

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          'http://172.16.250.183:8008/productimage/upload',
        ),
      );
      request.fields['pid'] = newPid.toString();
      request.fields['position'] = task['pos'];
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          task['file'].path,
        ),
      );

      await request.send();
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
      body: SingleChildScrollView(
        child: Padding(
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
                  contentPadding:
                      const EdgeInsets.symmetric(
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
                  contentPadding:
                      const EdgeInsets.symmetric(
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
                    '칼라',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedColorlist,
                hint: const Text('칼라를 선택하세요'),
                items: colorlist
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedColorlist = value;
                  });
                },
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(
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
                    '사이즈',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  // 시작 사이즈
                  SizedBox(
                    width: 120,
                    child: DropdownButtonFormField<int>(
                      value: startSize,
                      hint: const Text('시작'),
                      items: sizeList
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text('$e'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          startSize = value;
                          _updateSelectedSizes();
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(8),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                      ),
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                    child: Text('~'),
                  ),

                  // 끝 사이즈
                  SizedBox(
                    width: 120,
                    child: DropdownButtonFormField<int>(
                      value: endSize,
                      hint: const Text('끝'),
                      items: sizeList
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text('$e'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          endSize = value;
                          _updateSelectedSizes();
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(8),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),
                  const Text('(mm 단위)'),
                ],
              ),
              if (selectedSizes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  selectedSizes.join(', '),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
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
                    '상품가격',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Text(
                      '판매가',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          CurrencyInputFormatter(),
                        ],
                        textAlign: TextAlign.right,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),
                    const Text('원'),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                    ),
                  ),
                  onPressed: () {
                    // 콤마 제거 후 실제 숫자값
                    if (productNameController
                            .text
                            .isEmpty ||
                        selectedManufacturer == null ||
                        selectedColorlist == null) {
                      snack.errorSnackBar(
                        "입력 오류",
                        "모든 필수 항목을 입력해주세요.",
                      );
                      return;
                    }

                    //

                    CustomSnackbar.showConfirmDialog(
                      title: '상품등록',
                      message: '입력하신 정보로 상품등록 하시겠습니까?',
                      onConfirm: () async {
                        await insertAction();
                      },
                    );
                    final price = int.parse(
                      priceController.text.replaceAll(
                        ',',
                        '',
                      ),
                    );

                    debugPrint('상품가격: $price');
                  },
                  child: const Text(
                    '상품 등록',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //
  void _updateSelectedSizes() {
    if (startSize != null &&
        endSize != null &&
        startSize! <= endSize!) {
      selectedSizes = [];

      for (int i = startSize!; i <= endSize!; i += 5) {
        selectedSizes.add(i);
      }
    } else {
      selectedSizes = [];
    }
  }

  //
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
  //

  //
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return const TextEditingValue(text: '0');
    }

    // 숫자만 남기기
    String digits = newValue.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    // 앞에 0만 있는 경우 방지
    digits = digits.replaceFirst(RegExp(r'^0+'), '');
    if (digits.isEmpty) digits = '0';

    // 콤마 찍기
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      int indexFromEnd = digits.length - i;
      buffer.write(digits[i]);
      if (indexFromEnd > 1 && indexFromEnd % 3 == 1) {
        buffer.write(',');
      }
    }

    final formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: formatted.length,
      ),
    );
  }
}

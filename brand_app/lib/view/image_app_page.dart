import 'dart:convert';
import 'dart:io';

import 'package:brand_app/ip/ipaddress.dart';
import 'package:brand_app/util/pcolor.dart';
import 'package:brand_app/util/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class ImageAppPage extends StatefulWidget {
  const ImageAppPage({super.key});

  @override
  State<ImageAppPage> createState() => _ImageAppPageState();
}

class _ImageAppPageState extends State<ImageAppPage> {
  // --- 컨트롤러 및 설정 값 ---
  final TextEditingController priceController = TextEditingController(text: '0');
  final TextEditingController productNameController = TextEditingController(); 
  final TextEditingController enameController = TextEditingController();       
  
  final List<int> sizeList = List.generate(21, (index) => 230 + index * 5);
  int? startSize;
  int? endSize;
  List<int> selectedSizes = [];

  final ImagePicker _picker = ImagePicker();
  File? mainImage, topImage, sideImage, backImage;

  final List<String> manufacturers = ['나이키', '퓨마', '아디다스', '스니커즈', '뉴발란스'];
  final List<String> colorlist = ['화이트', '레드', '블랙', '브라운'];

  String? selectedManufacturer; 
  String? selectedColorlist; 

  // --- 이미지 피커 ---
  Future<void> _pickImage(Function(File) onSelected) async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked != null) {
      onSelected(File(picked.path));
      setState(() {});
    }
  }

  // --- [1] 상품 기본 등록 (Product 테이블) ---
  Future<int?> insertAction() async {
    try {
      String fullUrl = '${IpAddress.baseUrl}/product/insert';
      var request = http.MultipartRequest('POST', Uri.parse(fullUrl));
      request.fields['ename'] = enameController.text;
      request.fields['price'] = priceController.text.replaceAll(',', '');
      request.fields['quantity'] = '100'; 
      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        var data = json.decode(respStr);
        if (data['pid'] != null) return int.tryParse(data['pid'].toString());
      }
    } catch (e) { debugPrint("insertAction 에러: $e"); }
    return null;
  }

  // --- [2] 상품명 등록 ---
  Future<void> uploadProductName(int newPid) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('${IpAddress.baseUrl}/productname/upload'));
      request.fields['pid'] = newPid.toString();
      request.fields['name'] = productNameController.text;
      await request.send();
    } catch (e) { debugPrint("상품명 등록 에러: $e"); }
  }

  // --- [3] 제조사 등록 ---
  Future<void> uploadManufacturerName(int newPid) async {
    if (selectedManufacturer == null) return;
    try {
      var request = http.MultipartRequest('POST', Uri.parse('${IpAddress.baseUrl}/manufacturername/upload'));
      request.fields['pid'] = newPid.toString();
      request.fields['name'] = selectedManufacturer!;
      await request.send();
    } catch (e) { debugPrint("제조사 등록 에러: $e"); }
  }

  // --- [4] 이미지 업로드 ---
  Future<void> uploadImages(int newPid) async {
    List<Map<String, dynamic>> imageTasks = [
      {'pos': 'main', 'file': mainImage},
      {'pos': 'top', 'file': topImage},
      {'pos': 'side', 'file': sideImage},
      {'pos': 'back', 'file': backImage},
    ];
    for (var task in imageTasks) {
      if (task['file'] == null) continue;
      try {
        var request = http.MultipartRequest('POST', Uri.parse('${IpAddress.baseUrl}/productimage/upload'));
        request.fields['pid'] = newPid.toString();
        request.fields['position'] = task['pos'];
        request.files.add(await http.MultipartFile.fromPath('file', task['file'].path));
        await request.send();
      } catch (e) { debugPrint("이미지 업로드 에러: $e"); }
    }
  }

  // --- [5] 색상 등록 ---
  Future<void> uploadColor(int newPid) async {
    if (selectedColorlist == null) return;
    try {
      var request = http.MultipartRequest('POST', Uri.parse('${IpAddress.baseUrl}/productcolor/uproad'));
      request.fields['pid'] = newPid.toString();
      request.fields['color'] = selectedColorlist!;
      await request.send();
    } catch (e) { debugPrint("색상 등록 에러: $e"); }
  }

  // --- [6] 단일 사이즈 등록 (개별 PID용) ---
  Future<void> uploadSingleSize(int newPid, int sizeValue) async {
    try {
      await http.post(
        Uri.parse('${IpAddress.baseUrl}/productsize/insert?pid=$newPid'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"inputsize": [sizeValue]}), 
      );
    } catch (e) { debugPrint("사이즈($sizeValue) 등록 에러: $e"); }
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
              _sectionTitle('상품이미지', subTitle: '권장크기 300 * 300'),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _imageBox(title: '대표 이미지', image: mainImage, onTap: () => _pickImage((f) => mainImage = f)),
                    const SizedBox(width: 16),
                    _imageBox(title: 'Top 이미지', image: topImage, onTap: () => _pickImage((f) => topImage = f)),
                    const SizedBox(width: 16),
                    _imageBox(title: 'Side 이미지', image: sideImage, onTap: () => _pickImage((f) => sideImage = f)),
                    const SizedBox(width: 16),
                    _imageBox(title: 'Back 이미지', image: backImage, onTap: () => _pickImage((f) => backImage = f)),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              _sectionTitle('제조사명'),
              DropdownButtonFormField<String>(
                value: selectedManufacturer,
                hint: const Text('제조사를 선택하세요'),
                items: manufacturers.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (value) => setState(() => selectedManufacturer = value),
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
              ),
              const SizedBox(height: 30),

              _sectionTitle('상품명'),
              TextField(
                controller: productNameController,
                maxLength: 40,
                decoration: InputDecoration(hintText: '상품명을 입력하세요.', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 30),

              _sectionTitle('상품 영문명'),
              TextField(
                controller: enameController,
                maxLength: 40,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
                decoration: InputDecoration(hintText: '영문 상품명을 입력하세요.', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 30),

              _sectionTitle('칼라'),
              DropdownButtonFormField<String>(
                value: selectedColorlist,
                hint: const Text('칼라를 선택하세요'),
                items: colorlist.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (value) => setState(() => selectedColorlist = value),
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
              ),
              const SizedBox(height: 30),

              _sectionTitle('사이즈'),
              Row(
                children: [
                  _sizeDropDown(value: startSize, hint: '시작', onChanged: (v) {
                    setState(() { startSize = v; _updateSelectedSizes(); });
                  }),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('~')),
                  _sizeDropDown(value: endSize, hint: '끝', onChanged: (v) {
                    setState(() { endSize = v; _updateSelectedSizes(); });
                  }),
                  const SizedBox(width: 8),
                  const Text('(mm 단위)'),
                ],
              ),
              const SizedBox(height: 30),

              _sectionTitle('상품가격'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                height: 56,
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const Text('판매가', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [CurrencyInputFormatter()],
                        textAlign: TextAlign.right,
                        decoration: const InputDecoration(border: InputBorder.none),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    if (productNameController.text.isEmpty || enameController.text.isEmpty || selectedManufacturer == null || selectedColorlist == null || selectedSizes.isEmpty) {
                      Get.snackbar("입력 오류", "모든 필수 항목과 최소 하나 이상의 사이즈를 선택해주세요.");
                      return;
                    }

                    CustomSnackbar.showConfirmDialog(
                      title: '상품등록',
                      message: '선택한 ${selectedSizes.length}개 사이즈를 각각 개별 상품으로 등록하시겠습니까?',
                      onConfirm: () async {
                        Get.back();
                        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

                        try {
                          // 🔥 선택한 사이즈만큼 반복 실행
                          for (int size in selectedSizes) {
                            int? newPid = await insertAction();
                            if (newPid != null && newPid > 0) {
                              await Future.wait([
                                uploadProductName(newPid),
                                uploadManufacturerName(newPid),
                                uploadImages(newPid),
                                uploadColor(newPid),
                                uploadSingleSize(newPid, size), // 현재 루프의 사이즈만 등록
                              ]);
                            }
                          }
                          Get.back();
                          Get.snackbar("성공", "${selectedSizes.length}개의 상품이 사이즈별로 등록되었습니다.");
                        } catch (e) {
                          Get.back();
                          Get.snackbar("에러", "등록 중 오류가 발생했습니다.");
                        }
                      },
                    );
                  },
                  child: const Text('상품 등록', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 유틸리티 함수들 (디자인 유지) ---
  Widget _sectionTitle(String title, {String? subTitle}) {
    return Column(children: [
      Row(children: [
        const Text('* ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.red)),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        if (subTitle != null) Text('  $subTitle', style: const TextStyle(fontSize: 10, color: Colors.blueGrey)),
      ]),
      const SizedBox(height: 12),
    ]);
  }

  Widget _sizeDropDown({int? value, required String hint, required ValueChanged<int?> onChanged}) {
    return SizedBox(
      width: 120,
      child: DropdownButtonFormField<int>(
        value: value,
        hint: Text(hint),
        items: sizeList.map((e) => DropdownMenuItem(value: e, child: Text('$e'))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 12)),
      ),
    );
  }

  void _updateSelectedSizes() {
    if (startSize != null && endSize != null && startSize! <= endSize!) {
      setState(() {
        selectedSizes = [for (int i = startSize!; i <= endSize!; i += 5) i];
      });
    } else {
      setState(() { selectedSizes = []; });
    }
  }

  Widget _imageBox({required String title, required File? image, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(children: [
        Container(
          width: 140, height: 140,
          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(12)),
          child: Column(children: [
            Expanded(child: image == null ? const Icon(Icons.camera_alt, size: 40, color: Colors.white) : ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(image, fit: BoxFit.cover, width: double.infinity))),
            Container(height: 36, width: double.infinity, alignment: Alignment.center, decoration: const BoxDecoration(color: Colors.black, borderRadius: BorderRadius.vertical(bottom: Radius.circular(12))), child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 12))),
          ]),
        ),
        if (image != null) Positioned(top: 6, right: 6, child: Container(decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.close, size: 18, color: Colors.white))),
      ]),
    );
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return const TextEditingValue(text: '0');
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    digits = digits.replaceFirst(RegExp(r'^0+'), '');
    if (digits.isEmpty) digits = '0';
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      int indexFromEnd = digits.length - i;
      buffer.write(digits[i]);
      if (indexFromEnd > 1 && indexFromEnd % 3 == 1) buffer.write(',');
    }
    final formatted = buffer.toString();
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}
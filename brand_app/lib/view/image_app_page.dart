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
  final TextEditingController priceController = TextEditingController(text: '0');
  final TextEditingController productNameController = TextEditingController(); 
  final TextEditingController enameController = TextEditingController();       
  
  final List<int> sizeList = List.generate(21, (index) => 230 + index * 5);
  int? startSize;
  int? endSize;
  List<int> selectedSizes = [];

  final ImagePicker _picker = ImagePicker();
  File? mainImage, topImage, sideImage, backImage;

  // 서버에서 받아올 동적 리스트
  List<String> manufacturers = [];
  List<String> colorlist = [];

  String? selectedManufacturer; 
  String? selectedColorlist; 

  @override
  void initState() {
    super.initState();
    // 페이지 로드 시 서버에서 제조사 및 색상 리스트를 가져옴
    fetchDropdownData();
  }

  // --- 서버 데이터 로드 로직 ---
  Future<void> fetchDropdownData() async {
    try {
      // 서버의 /all 또는 전체 조회 API 호출 (없을 경우를 대비해 예외처리 포함)
      final mRes = await http.get(Uri.parse('${IpAddress.baseUrl}/manufacturername/all'));
      final cRes = await http.get(Uri.parse('${IpAddress.baseUrl}/productcolor/all'));

      if (mRes.statusCode == 200 && cRes.statusCode == 200) {
        setState(() {
          manufacturers = List<String>.from(json.decode(utf8.decode(mRes.bodyBytes))['results']);
          colorlist = List<String>.from(json.decode(utf8.decode(cRes.bodyBytes))['results']);
        });
      }
    } catch (e) {
      debugPrint("데이터 로드 실패: $e");
      // 서버 API가 아직 준비되지 않았을 경우를 위한 기본값 유지
      setState(() {
        manufacturers = ['나이키', '퓨마', '아디다스', '스니커즈', '뉴발란스'];
        colorlist = ['화이트', '레드', '블랙', '브라운'];
      });
    }
  }

  Future<void> _pickImage(Function(File) onSelected) async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
    if (picked != null) setState(() => onSelected(File(picked.path)));
  }

  // --- 기존 서버 통신 로직 (유지) ---
  Future<int?> getExistingMid(String ename) async {
    try {
      var response = await http.get(Uri.parse('${IpAddress.baseUrl}/product/get_mid?ename=$ename'));
      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        if (data['mid'] != null && data['mid'].toString() != "0") {
          return int.tryParse(data['mid'].toString());
        }
      }
    } catch (e) { debugPrint("MID 조회 실패: $e"); }
    return null; 
  }

  Future<int?> insertAction() async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('${IpAddress.baseUrl}/product/insert'));
      request.fields['ename'] = enameController.text.trim();
      request.fields['price'] = priceController.text.replaceAll(',', '');
      request.fields['quantity'] = '100';
      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      if (response.statusCode == 200) return int.tryParse(json.decode(respStr)['pid'].toString());
    } catch (e) { debugPrint("Insert 에러: $e"); }
    return null;
  }

  Future<void> updateMid(int pid, int mid) async => await http.post(Uri.parse('${IpAddress.baseUrl}/product/updateMid'), body: {'pid': pid.toString(), 'mid': mid.toString()});
  Future<void> uploadProductName(int pid) async => await http.post(Uri.parse('${IpAddress.baseUrl}/productname/upload'), body: {'pid': pid.toString(), 'name': productNameController.text});
  Future<void> uploadManufacturerName(int pid) async => await http.post(Uri.parse('${IpAddress.baseUrl}/manufacturername/upload'), body: {'pid': pid.toString(), 'name': selectedManufacturer ?? ''});
  Future<void> uploadColor(int pid) async => await http.post(Uri.parse('${IpAddress.baseUrl}/productcolor/uproad'), body: {'pid': pid.toString(), 'color': selectedColorlist ?? ''});
  Future<void> uploadSingleSize(int pid, int size) async => await http.post(Uri.parse('${IpAddress.baseUrl}/productsize/insert?pid=$pid'), headers: {"Content-Type": "application/json"}, body: jsonEncode({"inputsize": [size]}));

  Future<void> uploadImages(int pid) async {
    final url = '${IpAddress.baseUrl}/productimage/upload';
    if (mainImage != null) await _sendImg(url, pid, 'main', mainImage!);
    if (topImage != null) await _sendImg(url, pid, 'top', topImage!);
    if (sideImage != null) await _sendImg(url, pid, 'side', sideImage!);
    if (backImage != null) await _sendImg(url, pid, 'back', backImage!);
  }

  Future<void> _sendImg(String url, int pid, String pos, File file) async {
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields['pid'] = pid.toString();
    request.fields['position'] = pos;
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    await request.send();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('상품등록'), centerTitle: true, backgroundColor: Pcolor.appBarBackgroundColor, foregroundColor: Pcolor.appBarForegroundColor, elevation: 0),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('* 상품이미지 (최초 등록 시 필수)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 15),
              _buildImagePickers(), 
              const SizedBox(height: 30),
              _buildDropdown('제조사명', manufacturers, selectedManufacturer, (v) => setState(() => selectedManufacturer = v)),
              const SizedBox(height: 30),
              _buildTextField('한글 상품명', productNameController, hint: '상품명을 입력하세요.'),
              const SizedBox(height: 30),
              _buildTextField('영문 모델명', enameController, hint: '예: AIR_MAX_01', isEnglish: true),
              const SizedBox(height: 30),
              _buildDropdown('칼라', colorlist, selectedColorlist, (v) => setState(() => selectedColorlist = v)),
              const SizedBox(height: 30),
              const Text('* 사이즈', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              _buildSizeRangePicker(),
              const SizedBox(height: 40),
              _buildPriceInput(),
              const SizedBox(height: 40),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI 컴포넌트 ---

  Widget _buildImagePickers() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _imageBox(title: '대표', image: mainImage, onTap: () => _pickImage((f) => mainImage = f)),
          const SizedBox(width: 12),
          _imageBox(title: 'Top', image: topImage, onTap: () => _pickImage((f) => topImage = f)),
          const SizedBox(width: 12),
          _imageBox(title: 'Side', image: sideImage, onTap: () => _pickImage((f) => sideImage = f)),
          const SizedBox(width: 12),
          _imageBox(title: 'Back', image: backImage, onTap: () => _pickImage((f) => backImage = f)),
        ]
      )
    );
  }

  Widget _imageBox({required String title, File? image, required VoidCallback onTap}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[400]!, width: 1),
            ),
            child: image == null
                ? const Icon(Icons.add_a_photo_outlined, color: Colors.grey, size: 30)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(image, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildDropdown(String title, List<String> items, String? value, ValueChanged<String?> onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 10),
      DropdownButtonFormField<String>(
        value: value, 
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), 
        onChanged: onChanged, 
        decoration: const InputDecoration(border: OutlineInputBorder())
      ),
    ]);
  }

  Widget _buildTextField(String title, TextEditingController controller, {String? hint, bool isEnglish = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 10),
      TextField(
        controller: controller, 
        inputFormatters: isEnglish ? [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s_]'))] : [], 
        decoration: InputDecoration(hintText: hint, border: const OutlineInputBorder())
      ),
    ]);
  }

  Widget _buildSizeRangePicker() {
    return Row(children: [
      _sizeDropDown(value: startSize, hint: '시작', onChanged: (v) { setState(() { startSize = v; _updateSelectedSizes(); }); }),
      const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('~')),
      _sizeDropDown(value: endSize, hint: '끝', onChanged: (v) { setState(() { endSize = v; _updateSelectedSizes(); }); }),
    ]);
  }

  Widget _sizeDropDown({int? value, required String hint, required ValueChanged<int?> onChanged}) => SizedBox(width: 100, child: DropdownButtonFormField<int>(value: value, hint: Text(hint), items: sizeList.map((e) => DropdownMenuItem(value: e, child: Text('$e'))).toList(), onChanged: onChanged, decoration: const InputDecoration(border: OutlineInputBorder())));

  void _updateSelectedSizes() { if (startSize != null && endSize != null && startSize! <= endSize!) setState(() => selectedSizes = [for (int i = startSize!; i <= endSize!; i += 5) i]); }

  Widget _buildPriceInput() => Container(padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)), child: Row(children: [const Text('판매가'), Expanded(child: TextField(controller: priceController, keyboardType: TextInputType.number, inputFormatters: [CurrencyInputFormatter()], textAlign: TextAlign.right, decoration: const InputDecoration(border: InputBorder.none))), const Text('원')]));

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity, height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.black87, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        onPressed: () {
          if (productNameController.text.isEmpty || enameController.text.isEmpty || selectedSizes.isEmpty) {
            Get.snackbar("알림", "정보를 모두 입력해주세요."); return;
          }
          CustomSnackbar.showConfirmDialog(
            title: '상품등록', message: '${selectedSizes.length}개의 사이즈 상품을 등록하시겠습니까?',
            onConfirm: () async {
              Get.back();
              Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
              try {
                int? sharedMid = await getExistingMid(enameController.text.trim());
                bool isNewGroup = (sharedMid == null);
                for (int i = 0; i < selectedSizes.length; i++) {
                  int? newPid = await insertAction();
                  if (newPid == null) throw Exception("PID 생성 실패");
                  if (isNewGroup && i == 0) {
                    sharedMid = newPid;
                    await uploadImages(newPid);
                    await uploadProductName(newPid);
                    await uploadManufacturerName(newPid);
                  }
                  await Future.wait([
                    uploadColor(newPid),
                    uploadSingleSize(newPid, selectedSizes[i]),
                    updateMid(newPid, sharedMid!),
                  ]);
                }
                Get.back();
                Get.snackbar("성공", "MID: $sharedMid 그룹 등록 완료");
              } catch (e) { Get.back(); Get.snackbar("에러", "실패: $e"); }
            },
          );
        },
        child: const Text('상품 등록', style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return const TextEditingValue(text: '0');
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '').replaceFirst(RegExp(r'^0+'), '');
    final formatted = digits.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}
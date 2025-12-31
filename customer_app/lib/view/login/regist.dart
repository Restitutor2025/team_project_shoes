import 'dart:convert';
import 'package:customer_app/model/customer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class Regist extends StatefulWidget {
  const Regist({super.key});

  @override
  State<Regist> createState() => _RegistState();
}

class _RegistState extends State<Regist> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController pwController = TextEditingController();
  TextEditingController pwcheckController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      // 키보드 올라올 때 화면 깨짐 방지를 위해 SingleChildScrollView 추천
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Image.asset('images/logo_non.png', width: 250),
                const SizedBox(height: 15),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: '이름', hintText: '이름을 입력하세요'),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: '이메일', hintText: 'EX)dsss@email.com'),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () { /* 중복확인 */ },
                  child: const Text('중복확인'),
                ),
                const SizedBox(height: 15),
                TextField(
                  obscureText: true,
                  controller: pwController,
                  decoration: const InputDecoration(labelText: '비밀번호'),
                ),
                const SizedBox(height: 15),
                TextField(
                  obscureText: true,
                  controller: pwcheckController,
                  decoration: const InputDecoration(labelText: '비밀번호 확인'),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: '전화번호'),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: '주소'),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () => registCustomer(),
                  child: const Text('회원가입'),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Functions (모두 _RegistState 클래스 블록 { } 안에 있어야 합니다) ---

  Future<void> registCustomer() async {
    try {
      final customer = Customer(
        email: emailController.text.trim(),
        password: pwController.text.trim(),
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
      );

      final url = Uri.parse('http://172.16.250.193:8008/customer/idregist');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(customer.toJson()),
      );

      final data = json.decode(utf8.decode(response.bodyBytes));
      final result = data['results'];

      if (result == 'OK') {
        _showDialog();
      } else {
        errorSnackBar();
      }
    } catch (e) {
      errorSnackBar();
    }
  }

  void _showDialog() {
    Get.defaultDialog(
      title: '회원가입',
      middleText: '회원가입이 완료 되었습니다.',
      barrierDismissible: false,
      actions: [
        TextButton(
          onPressed: () {
            Get.back(); // 다이얼로그 닫기
            Get.back(); // 가입 화면 나가기
          },
          child: const Text('OK'),
        )
      ],
    );
  }

  void errorSnackBar() {
    Get.snackbar(
      '경고',
      '제대로 입력하세요',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
} // <--- 클래스 닫는 괄호는 맨 마지막에 딱 하나만 있어야 합니다.
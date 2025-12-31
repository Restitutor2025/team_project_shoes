import 'dart:convert';
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

  bool isEmailChecked = false; // 중복확인 여부
  bool isPasswordMatch = true; // 비밀번호 일치 여부

  @override
  void initState() {
    super.initState();
    pwcheckController.addListener(() {
      setState(() {
        isPasswordMatch = pwController.text == pwcheckController.text;
      });
    });
    pwController.addListener(() {
      setState(() {
        isPasswordMatch = pwController.text == pwcheckController.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
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
                  onChanged: (value) => isEmailChecked = false, // 이메일 수정시 중복확인 리셋
                  decoration: const InputDecoration(labelText: '이메일', hintText: 'EX)dsss@email.com'),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () => checkDuplicate(),
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
                  decoration: InputDecoration(
                    labelText: '비밀번호 확인',
                    // 실시간으로 비밀번호가 다르면 에러 텍스트 표시
                    errorText: isPasswordMatch ? null : '비밀번호가 일치하지 않습니다.',
                  ),
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
                  onPressed: () {
                    if (!isEmailChecked) {
                      Get.snackbar('경고', '이메일 중복확인을 먼저 해주세요.');
                    } else if (!isPasswordMatch || pwcheckController.text.isEmpty) {
                      Get.snackbar('경고', '비밀번호가 일치하지 않습니다.');
                    } else {
                      registCustomer();
                    }
                  },
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

  // 중복 확인 함수
  Future<void> checkDuplicate() async {
    if (emailController.text.trim().isEmpty) {
      Get.snackbar('경고', '이메일을 입력하세요.');
      return;
    }

    try {
      var url = Uri.parse('http://172.16.250.193:8008/customer/check_email');
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': emailController.text.trim()}),
      );

      var data = json.decode(utf8.decode(response.bodyBytes));
      if (data['results'] == 'OK') {
        isEmailChecked = true;
        Get.snackbar('확인', '사용 가능한 이메일입니다.',backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        isEmailChecked = false;
        Get.snackbar('경고', '이미 등록된 이메일입니다.',backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('에러', '서버 연결에 실패했습니다.',backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> registCustomer() async {
    try {
      final url = Uri.parse('http://172.16.250.193:8008/customer/idregist');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': emailController.text.trim(),
          'password': pwController.text.trim(),
          'name': nameController.text.trim(),
          'phone': phoneController.text.trim(),
          'address': addressController.text.trim(),
        }),
      );

      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data['results'] == 'OK') {
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
            Get.back();
            Get.back();
          },
          child: const Text('OK'),
        )
      ],
    );
  }

  void errorSnackBar() {
    Get.snackbar('경고', '회원가입에 실패했습니다.',backgroundColor: Colors.red, colorText: Colors.white);
  }
}
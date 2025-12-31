import 'dart:convert';
import 'package:customer_app/view/home/tabbar.dart';
import 'package:customer_app/view/login/find_id_pw.dart';
import 'package:customer_app/view/login/regist.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController pwController = TextEditingController();

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        print('로그인 성공: ${googleUser.email}');
      }
    } catch (error) {
      print('구글 로그인 실패: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('images/logo_non.png', width: 250),
              const SizedBox(height: 100),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: '이메일',
                  hintText: 'EX)dsss@email.com'
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                obscureText: true,
                controller: pwController,
                decoration: const InputDecoration(labelText: '비밀번호'),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () => loginAction(), // 수정된 부분: 검증 로직 실행
                child: const Text('로그인')
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                  icon: const Icon(Icons.g_mobiledata, size: 45),
                  label: const Text('Google로 계속하기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  onPressed: _handleGoogleSignIn,
                ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(145, 50),
                    ),
                    onPressed: () => Get.to(() => const Regist()),
                    child: const Text('회원가입')
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(145, 50),
                    ),
                    onPressed: () {
                      Get.to(FindIdPw());
                    },
                    child: const Text('ID / Pw 찾기')
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> loginAction() async {
    if (emailController.text.trim().isEmpty || pwController.text.trim().isEmpty) {
      _errorSnackBar('아이디와 비밀번호를 입력해주세요.');
      return;
    }

    try {
      final url = Uri.parse('http://172.16.250.193:8008/customer/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': emailController.text.trim(),
          'password': pwController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['results'] == 'OK') {
          Get.offAll(() => const Tabbar()); // 로그인 성공 시 이동
        } else {
          _errorSnackBar('이메일 또는 비밀번호가 일치하지 않습니다.');
        }
      } else {
        _errorSnackBar('서버 연결 실패');
      }
    } catch (e) {
      _errorSnackBar('네트워크 에러가 발생했습니다.');
    }
  }

  void _errorSnackBar(String message) {
    Get.snackbar(
      '경고',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[400],
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
}
import 'dart:convert';

import 'package:customer_app/view/home/tabbar.dart';
import 'package:customer_app/view/login/regist.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
// 구글 로그인 : cd customer_app <<<<< 이거 진행하고 ///// flutter pub add google_sign_in <<<<<< 이거 설치해야됨

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController emailController = TextEditingController();
  TextEditingController pwController = TextEditingController();
  // 이 부분이 정확한지 확인하세요

  final GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [
    'email'
    ],
  );


  // 3. 구글 로그인 실행 함수
  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        print('로그인 성공: ${googleUser.email}');
        // 여기서 성공 후 페이지 이동 로직 등을 구현하세요.
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
              Image.asset(
                'images/logo_non.png',
                width: 250,
                ),// 로고
              SizedBox(
                height: 100,
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: '이메일',
                  hintText: 'EX)dsss@email.com'
                ),
              ),// 이메일 입력창
              SizedBox(
                height: 30,
              ),
              TextField(
                obscureText: true,
                controller: pwController,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                ),
              ),// 비밀번호 입력창
              SizedBox(
                height: 50,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: (){
                  Get.to(Tabbar());
                },
                child: Text('로그인')
              ),
              SizedBox(height: 10,),
              ElevatedButton.icon(
                  icon: Icon(Icons.g_mobiledata,size: 45,),
                  label: const Text('Google로 계속하기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: Colors.grey), // 구글 버튼 느낌을 위해 테두리 추가
                  ),
                  onPressed: _handleGoogleSignIn, // 위에서 만든 함수 연결
                ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(145, 50),
                ),
                onPressed: (){
                  Get.to(Regist());
                },
                child: Text('회원가입')
              ),
                  SizedBox(width: 10,),
                  ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(145, 50),
                ),
                onPressed: (){
                  loginAction();
                },
                child: Text('ID / Pw 찾기')
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }// build
  //Function
  Future<void> loginAction() async {
    // 1. 입력값 검사
    if (emailController.text.trim().isEmpty || pwController.text.trim().isEmpty) {
      _errorSnackBar('아이디와 비밀번호를 입력해주세요.');
      return;
    }

    try {
      // 2. 서버 주소 설정 (FastAPI 서버 주소)
      final url = Uri.parse('http://172.16.250.193:8008/customer/login');

      // 3. 서버에 POST 요청 보내기
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': emailController.text.trim(),
          'password': pwController.text.trim(),
        }),
      );

      // 4. 응답 해석
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        
        if (data['results'] == 'OK') {
          Get.offAll(() => const Tabbar());
        } else {
          // 로그인 실패 (이메일/비번 불일치)
          _errorSnackBar('이메일 또는 비밀번호가 일치하지 않습니다.');
        }
      } else {
        _errorSnackBar('서버 연결 실패 (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Error: $e');
      _errorSnackBar('네트워크 에러가 발생했습니다.');
    }
  }

  // 에러 메시지용 스낵바
  void _errorSnackBar(String message) {
    Get.snackbar(
      '경고',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[400],
      colorText: Colors.white,
    );
  }
}
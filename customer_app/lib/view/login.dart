import 'package:customer_app/view/find_id_pw.dart';
import 'package:customer_app/view/regist.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
                  // 로그인 기능
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
                  Get.to(FindIdPw());
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
  }
}
import 'package:flutter/material.dart';

class Regist extends StatefulWidget {
  const Regist({super.key});

  @override
  State<Regist> createState() => _RegistState();
}

class _RegistState extends State<Regist> {

  TextEditingController nameController = TextEditingController(); // 이름
  TextEditingController emailController = TextEditingController(); // 이메일
  TextEditingController pwController = TextEditingController(); // 비밀번호
  TextEditingController pwcheckController = TextEditingController(); // 비밀번호 확인
  TextEditingController phoneController = TextEditingController(); // 전화번호
  TextEditingController addressController = TextEditingController(); // 주소

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입'),
      ),
      body: Center(
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 40,),
              Image.asset(
                'images/logo_non.png',
                width: 250,
                ),// 로고
              SizedBox(
                height: 15,
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: '이름',
                  hintText: '이름을 입력하세요'
                ),
              ),// 이름 입력창
              SizedBox(
                height: 15,
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
                            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: (){
                  // 중복확인
                },
                child: Text('중복확인')
              ),
              SizedBox(height: 15,),
              TextField(
                obscureText: true,
                controller: pwController,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                ),
              ),// 비밀번호 입력창
              SizedBox(height: 15,),
              TextField(
                obscureText: true,
                controller: pwcheckController,
                decoration: InputDecoration(
                  labelText: '비밀번호 확인',
                ),
              ),// 비밀번호 확인 입력창
              SizedBox(height: 15,),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: '전화번호',
                ),
              ),// 전화번호 입력창
              SizedBox(
                height: 15,
              ),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: '주소',
                ),
              ),// 주소 입력창
              SizedBox(
                height: 30,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: (){
                  // 회원가입
                },
                child: Text('회원가입')
              ),
              SizedBox(height: 10,),
            ],
          ),
        ),
      ),
    );
  }
}
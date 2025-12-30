import 'package:flutter/material.dart';

class FindIdPw extends StatefulWidget {
  const FindIdPw({super.key});

  @override
  State<FindIdPw> createState() => _FindIdPwState();
}

class _FindIdPwState extends State<FindIdPw> {

  TextEditingController idNameController = TextEditingController(); // 아이디 찾기 이름
  TextEditingController idPhoneController = TextEditingController(); // 아이디 찾기 이메일
  TextEditingController pwNameController = TextEditingController(); // 비밀번호 찾기 이름
  TextEditingController pwEmailController = TextEditingController(); // 비밀번호 찾기 이메일
  TextEditingController pwPhoneController = TextEditingController(); // 비밀번호 찾기 전화번호

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ID / PW 찾기'),
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
                controller: idNameController,
                decoration: InputDecoration(
                  labelText: '이름',
                  hintText: '이름을 입력하세요'
                ),
              ),// 이름 입력창
              SizedBox(
                height: 15,
              ),
              TextField(
                controller: idPhoneController,
                decoration: InputDecoration(
                  labelText: '전화번호',
                  hintText: '전화번호를 입력하세요'
                ),
              ),// 전화번호 입력창
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
                  // 아이디 찾기
                },
                child: Text('아이디 찾기')
              ),
              SizedBox(height: 15,),
              TextField(
                obscureText: true,
                controller: pwNameController,
                decoration: InputDecoration(
                  labelText: '이름',
                ),
              ),// 비밀번호 찾기 이름 입력창
              SizedBox(height: 15,),
              TextField(
                obscureText: true,
                controller: pwEmailController,
                decoration: InputDecoration(
                  labelText: '이메일',
                ),
              ),// 비밀번호 찾기 이메일 입력창
              SizedBox(height: 15,),
              TextField(
                controller: pwPhoneController,
                decoration: InputDecoration(
                  labelText: '전화번호',
                ),
              ),// 비밀번호 찾기 전화번호 입력창
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
                  // 비밀번호 찾기
                },
                child: Text('비밀번호 찾기')
              ),
              SizedBox(height: 10,),
            ],
          ),
        ),
      ),
    );
  }
}
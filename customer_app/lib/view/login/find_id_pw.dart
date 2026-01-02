import 'package:customer_app/ip/ipaddress.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FindIdPw extends StatefulWidget {
  const FindIdPw({super.key});

  @override
  State<FindIdPw> createState() => _FindIdPwState();
}

class _FindIdPwState extends State<FindIdPw> {
  // 아이디 찾기 컨트롤러
  TextEditingController idNameController = TextEditingController();
  TextEditingController idPhoneController = TextEditingController();
  
  // 비밀번호 찾기 컨트롤러
  TextEditingController pwNameController = TextEditingController();
  TextEditingController pwEmailController = TextEditingController();
  TextEditingController pwPhoneController = TextEditingController();

  final String baseUrl = "${IpAddress.baseUrl}";

  // 스낵바 표시 함수
  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // 성공 다이얼로그 (정보를 찾았을 때만 사용)
  void _showResultDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  // 아이디 찾기 통신
  Future<void> _findId() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/customer/find_id'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'name': idNameController.text,
          'phone': idPhoneController.text,
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['results'] == 'OK') {
          _showResultDialog('아이디 찾기 성공', '이메일: ${data['email']}');
        } else {
          // 서버에서 Fail이 넘어온 경우 스낵바
          _showSnackBar('일치하는 회원 정보가 없습니다.');
        }
      }
    } catch (e) {
      _showSnackBar('서버 연결에 실패했습니다.');
    }
  }

  // 비밀번호 찾기 통신
  Future<void> _findPw() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/customer/find_pw'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'name': pwNameController.text,
          'email': pwEmailController.text,
          'phone': pwPhoneController.text,
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['results'] == 'OK') {
          _showResultDialog('임시 비밀번호 발송', '등록된 번호로 문자를 발송했습니다.');
        } else {
          _showSnackBar('입력하신 정보가 일치하지 않습니다.');
        }
      }
    } catch (e) {
      _showSnackBar('서버 연결에 실패했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ID / PW 찾기'), centerTitle: true),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 300,
            child: Column(
              children: [
                const SizedBox(height: 40),
                Image.asset('images/logo_non.png', width: 200, errorBuilder: (c, e, s) => const Icon(Icons.lock, size: 100)),
                const SizedBox(height: 30),
                
                // --- 아이디 찾기 ---
                const Text("아이디 찾기", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextField(controller: idNameController, decoration: const InputDecoration(labelText: '이름')),
                TextField(controller: idPhoneController, decoration: const InputDecoration(labelText: '전화번호')),
                const SizedBox(height: 15),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
                  onPressed: () {
                    if (idNameController.text.isEmpty || idPhoneController.text.isEmpty) {
                      _showSnackBar('아이디 찾기 정보를 모두 입력해주세요.');
                    } else {
                      _findId();
                    }
                  },
                  child: const Text('아이디 찾기'),
                ),

                const SizedBox(height: 40),
                const Divider(),
                const SizedBox(height: 20),

                // --- 비밀번호 찾기 ---
                const Text("비밀번호 찾기", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextField(controller: pwNameController, decoration: const InputDecoration(labelText: '이름')),
                TextField(controller: pwEmailController, decoration: const InputDecoration(labelText: '이메일')),
                TextField(controller: pwPhoneController, decoration: const InputDecoration(labelText: '전화번호')),
                const SizedBox(height: 15),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
                  onPressed: () {
                    if (pwNameController.text.isEmpty || pwEmailController.text.isEmpty || pwPhoneController.text.isEmpty) {
                      _showSnackBar('비밀번호 찾기 정보를 모두 입력해주세요.');
                    } else {
                      _findPw();
                    }
                  },
                  child: const Text('비밀번호 찾기'),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
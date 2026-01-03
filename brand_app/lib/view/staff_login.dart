import 'dart:convert';

import 'package:brand_app/ip/ipaddress.dart';
import 'package:brand_app/model/employee.dart';
import 'package:brand_app/model/login.dart';
import 'package:brand_app/view/staff_main_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart'as http;
class StaffLogin extends StatefulWidget {
  const StaffLogin({super.key});

  @override
  State<StaffLogin> createState() => _StaffLoginState();
}

class _StaffLoginState extends State<StaffLogin> {
  final EmployeeController employeeController=Get.put(EmployeeController());
  late TextEditingController staffcode;
  late TextEditingController staffpassword;

  @override
  void initState() {
    super.initState();
    staffcode=TextEditingController();
    staffpassword=TextEditingController();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
   
   body: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset("images/logo_non.png",
        width: 300,
        height: 300,),
        Container(
          width: 300,
          height:300,
          decoration: BoxDecoration(
            border: Border.all(
              color:Colors.black
            )
          ),
          child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("images/logo_non.png",
              width: 100,
              height: 100,),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: 250,
                  child: TextField(
                    controller: staffcode,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                           
                            borderSide: BorderSide(
                              
                              color: Colors.black
                            )
                          ),
                        labelText: "직원코드"
                      
                      ),
                  ),
                ),
              ),
              SizedBox(
                width: 250,
                child: TextField(
                  controller: staffpassword,
                    decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                         
                          borderSide: BorderSide(
                            
                            color: Colors.black
                          )
                        ),
                      labelText: "비밀번호",
                    ),
                ),
                
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    loginAction();
                  },
                  child: Text("로그인")),
              )
            ],
          
          ),
        ),
      ],
    ),
   ),
    );
  }//build

  Future<void> loginAction() async {
    if (staffcode.text.trim().isEmpty || staffpassword.text.trim().isEmpty) {
      _errorSnackBar('아이디와 비밀번호를 입력해주세요.');
      return;
    }

    try {
      final url = Uri.parse('${IpAddress.baseUrl}/employee/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': staffcode.text.trim(),
          'password': staffpassword.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['results'] == 'OK') {
        Employee loggedInEmployee = Employee.fromJson(data['employee_data']); 
        employeeController.login(loggedInEmployee);
        Get.offAll(() => const StaffMainpage());
       
        
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
}//class
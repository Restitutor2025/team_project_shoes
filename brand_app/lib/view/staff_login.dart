import 'package:brand_app/util/pcolor.dart';
import 'package:flutter/material.dart';

class StaffLogin extends StatefulWidget {
  const StaffLogin({super.key});

  @override
  State<StaffLogin> createState() => _StaffLoginState();
}

class _StaffLoginState extends State<StaffLogin> {
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
        Image.asset("images/puma.png",
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
              Image.asset("images/puma2.png",
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
            ],
          ) ,
        ),
      ],
    ),
   ),
    );
  }
}
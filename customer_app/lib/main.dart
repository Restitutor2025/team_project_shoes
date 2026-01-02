import 'package:customer_app/firebase_options.dart';
import 'package:customer_app/view/login/login.dart';
import 'package:customer_app/view/mypage/chatting.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async{  //  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );  //  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Chatting(),// 본인이 하는 페이지로 바꿔서 진행하시면 됩니다
    );
  }
}

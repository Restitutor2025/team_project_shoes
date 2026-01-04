import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/firebase_options.dart';
import 'package:customer_app/view/login/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  //  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); //  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  print("Firebase apps = ${Firebase.apps.map((e) => e.name).toList()}");
  try {
    final cred = await FirebaseAuth.instance.signInAnonymously();
    print("ANON OK uid=${cred.user?.uid}");
  } catch (e) {
    print("ANON FAIL $e");
  }

  // Anonymouse Login(NIF in actual release)
  if (FirebaseAuth.instance.currentUser == null) {
    await FirebaseAuth.instance.signInAnonymously();
  }

  final user = FirebaseAuth.instance.currentUser;
  print("AUTH UID = ${user?.uid}, isAnon=${user?.isAnonymous}");

  FirebaseFirestore.instance
      .collection('ask')
      .limit(1)
      .get()
      .then((v) => print("FIRESTORE OK ${v.docs.length}"))
      .catchError((e) => print("FIRESTORE FAIL $e"));

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
      home: const Login(),// 본인이 하는 페이지로 바꿔서 진행하시면 됩니다
    );
  }
}

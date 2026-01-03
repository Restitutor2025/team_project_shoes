import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Snackbar {
  // 실패 했을때 스낵바
  void errorSnackBar(String title, String message ){
    Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.TOP,
    duration: Duration(seconds: 2),
    colorText: Colors.white,
    backgroundColor: Colors.red,
    );
  }
  // 성공했을때 스낵바
  void okSnackBar(String title, String message ){
    Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.TOP,
    duration: Duration(seconds: 2),
    colorText: Colors.white,
    backgroundColor: Colors.green,
    );
  }
  // Dialog
  void showDialog(String title, String message) {
    Get.defaultDialog(
      title: title,
      middleText: message,
      backgroundColor: const Color.fromARGB(255, 193, 197, 201),
      barrierDismissible: false,
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
            Get.back();
          },
          style: TextButton.styleFrom(
              foregroundColor: Colors.black,
          ),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
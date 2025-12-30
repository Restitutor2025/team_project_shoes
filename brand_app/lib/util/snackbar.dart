import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSnackbar {
  // 실패 했을때 스낵바
  dynamic errorSnackBar(String title, String message) {
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
  dynamic okSnackBar(String title, String message) {
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
  dynamic showDialog(String title, String message) {
    Get.defaultDialog(
      title: title,
      middleText: message,
      backgroundColor: const Color.fromARGB(
        255,
        193,
        197,
        201,
      ),
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

  // 삭제 확인용 다이얼로그 (Confirm 콜백 추가)
  static void showConfirmDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    Get.defaultDialog(
      title: title,
      middleText: message,
      backgroundColor: const Color.fromARGB(
        255,
        230,
        230,
        230,
      ),
      barrierDismissible: false,
      textConfirm: "확인",
      textCancel: "취소",
      confirmTextColor: Colors.white,
      buttonColor: Colors.black,
      onConfirm: () {
        onConfirm(); // 전달받은 삭제 로직 실행
        Get.back(); // 다이얼로그 닫기
      },
      onCancel: () => Get.back(),
    );
  }
}

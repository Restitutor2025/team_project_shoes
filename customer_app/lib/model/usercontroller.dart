import 'package:get/get.dart';
import 'package:customer_app/model/customer.dart'; 

class UserController extends GetxController {
  Customer? user;

  void login(Customer loggedInUser) {
    user = loggedInUser;
    update();
  }

  void logout() {
    user = null;
    update();
  }
}
import 'package:brand_app/model/employee.dart';
import 'package:get/get.dart';


class EmployeeController extends GetxController {
  Employee? employee;

  void login(Employee loggedInEmployee) {
    employee = loggedInEmployee;
    update();
  }

  void logout() {
    employee = null;
    update();
  }
}
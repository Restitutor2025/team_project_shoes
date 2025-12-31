//  Employee Model
/*
  Create: 31/12/2025 14:18, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: 
  Desc: Employee Model

  DateTime MUST converted using value.toIso8601String()
  DateTime MUST converted using value: (json['value'] as num).toDouble()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class Employee {
  //  Property
  int? id;
  int sid;  //  FK From Store
  String role;
  String name;
  String email;
  String password;
  String storenumber;
  String phone;

  //  Constructor
  Employee({
    this.id, 
    required this.sid, 
    required this.role,
    required this.name,
    required this.email,
    required this.password,
    required this.storenumber,
    required this.phone
    });

  //  Decode from Json type
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      sid: json['sid'],
      role: json['role'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      storenumber: json['storenumber'],
      phone: json['phone']
    );
  }

  //  Encode to Json type
  Map<String, dynamic> toJson(){
    return {
      'id':id,
      'sid':sid,
      'role':role,
      'name':name,
      'email':email,
      'password':password,
      'storenumber':storenumber,
      'phone':phone
    };
  }
}
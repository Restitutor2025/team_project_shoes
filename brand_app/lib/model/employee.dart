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
  int? sid;  // 🔥 sid가 서버 응답에 없을 수 있으므로 ?를 붙여 null 허용으로 변경
  String role;
  String name;
  String email;
  String? password;
  String storenumber;
  String phone;

  //  Constructor
  Employee({
    this.id, 
    this.sid, // 🔥 sid는 required를 제거하고 선택 사항으로 변경
    required this.role,
    required this.name,
    required this.email,
    this.password,
    required this.storenumber,
    required this.phone
  });

  //  Decode from Json type
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as int?,
      sid: json['sid'] as int?, // 🔥 데이터가 없어도 에러가 나지 않음
      role: json['role'] ?? "", // 혹시 몰라 기본값 "" 추가
      name: json['name'] ?? "",
      email: json['email'] ?? "",
      password: json['password'],
      storenumber: json['storenumber'] ?? "",
      phone: json['phone'] ?? "",
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
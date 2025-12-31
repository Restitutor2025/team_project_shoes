//  Customer Model
/*
  Create: 31/12/2025 14:15, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: 
  Desc: Customer Model

  DateTime MUST converted using value.toIso8601String()
  DateTime MUST converted using value: (json['value'] as num).toDouble()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class Customer {
  //  Property
  int? id;
  String email;
  String password;
  String name;
  String phone;
  DateTime date;
  String address;

  //  Constructor
  Customer({
    this.id, 
    required this.email, 
    required this.password,
    required this.name,
    required this.phone,
    required this.date,
    required this.address
    });

  //  Decode from Json type
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      email: json['email'],
      password: json['password'],
      name: json['name'],
      phone: json['phone'],
      date: DateTime.parse(json['date']),
      address: json['address']
    );
  }

  //  Encode to Json type
  Map<String, dynamic> toJson(){
    return {
      'id':id,
      'email':email,
      'password':password,
      'name':name,
      'phone':phone,
      'date':date.toIso8601String(),
      'address':address,
    };
  }
}
class Customer {
  int? id;
  String email;
  String password;
  String name;
  String phone;
  String? date;
  String address;

  Customer({
    this.id,
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
    this.date,
    required this.address,
  });

  Map<String, dynamic> toJson(){
    return{
      'email' : email,
      'password' : password,
      'name' : name,
      'phone' : phone,
      'address' : address,
    };
  }
}
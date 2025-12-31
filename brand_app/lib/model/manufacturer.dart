//  manufacturer Model
/*
  Create: 31/12/2025 12:46, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: 
  Desc: manufacturer Model

  DateTime MUST converted using value.toIso8601String()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class Manufacturer {
  //  Property
  int? id;
  String name;
  String email;

  //  Constructor
  Manufacturer({
    this.id, 
    required this.name, 
    required this.email
    });

  //  Decode from Json type
  factory Manufacturer.fromJson(Map<String, dynamic> json) {
    return Manufacturer(
      id: json['id'],
      name: json['name'],
      email: json['email']
    );
  }

  //  Encode to Json type
  Map<String, dynamic> toJson(){
    return {
      'id':id,
      'name':name,
      'email':email,
    };
  }
}

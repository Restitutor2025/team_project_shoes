//  name Model
/*
  Create: 31/12/2025 12:56, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: 
  Desc: name Model

  DateTime MUST converted using value.toIso8601String()
  DateTime MUST converted using value: (json['value'] as num).toDouble()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class Name {
  //  Property
  int pid;  //  FK from Product
  String name;

  //  Constructor
  Name({
    required this.pid, 
    required this.name
    });

  //  Decode from Json type
  factory Name.fromJson(Map<String, dynamic> json) {
    return Name(
      pid: json['pid'],
      name: json['name'],
    );
  }

  //  Encode to Json type
  Map<String, dynamic> toJson(){
    return {
      'pid':pid,
      'name':name
    };
  }
}
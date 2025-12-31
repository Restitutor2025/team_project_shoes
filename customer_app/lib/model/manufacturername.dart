//  Manufacturername Model
/*
  Create: 31/12/2025 14:12, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: 
  Desc: Manufacturername Model

  DateTime MUST converted using value.toIso8601String()
  DateTime MUST converted using value: (json['value'] as num).toDouble()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class Manufacturername {
  //  Property
  int pid;  //  FK from Product as PK
  String name;

  //  Constructor
  Manufacturername({
    required this.pid, 
    required this.name
    });

  //  Decode from Json type
  factory Manufacturername.fromJson(Map<String, dynamic> json) {
    return Manufacturername(
      pid: json['pid'],
      name: json['name']
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
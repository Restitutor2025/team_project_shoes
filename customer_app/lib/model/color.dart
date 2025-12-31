//  color Model
/*
  Create: 31/12/2025 12:07, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: 
  Desc: color Model

  DateTime MUST converted using value.toIso8601String()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class Color {
  //  Property
  int pid; //  FK from Product
  String color;

  //  Constructor
  Color({required this.pid, required this.color});

  //  Decode from Json type
  factory Color.fromJson(Map<String, dynamic> json) {
    return Color(
      pid: json['pid'],
      color: json['color'],
    );
  }

  //  Encode to Json type
  Map<String, dynamic> toJson(){
    return {
      'pid':pid,
      'color':color,
    };
  }
}
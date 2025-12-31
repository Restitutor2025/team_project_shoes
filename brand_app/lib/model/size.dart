//  size Model
/*
  Create: 31/12/2025 12:30, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: 
  Desc: size Model

  DateTime MUST converted using value.toIso8601String()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class Size {
  //  Property
  int pid;  //  FK from Product
  int size;

  //  Constructor
  Size({required this.pid, required this.size});

  //  Decode from Json type
  factory Size.fromJson(Map<String, dynamic> json) {
    return Size(
      pid: json['pid'],
      size: json['size'],
    );
  }

  //  Encode to Json type
  Map<String, dynamic> toJson(){
    return {
      'pid':pid,
      'size':size,
    };
  }
}
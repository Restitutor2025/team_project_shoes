//  Property Model
/*
  Create: 31/12/2025 12:30, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
    02/01/2026 11:03, 'Point 1, Changed name from Size to ProductSize', Creator: Chansol, Park
  Version: 1.0
  Dependency: 
  Desc: Property Model

  DateTime MUST converted using value.toIso8601String()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class ProductSize {
  //  Property
  int pid;  //  FK from Product
  int size;

  //  Constructor
  ProductSize({required this.pid, required this.size});

  //  Decode from Json type
  factory ProductSize.fromJson(Map<String, dynamic> json) {
    return ProductSize(
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
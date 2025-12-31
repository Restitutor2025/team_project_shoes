//  ProductColor Model
/*
  Create: 31/12/2025 12:07, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
    31/12/2025 18:09, 'Point 1, Changed model name to ProductColor', Creator: Chansol Park
  Version: 1.0
  Dependency: 
  Desc: ProductColor Model

  DateTime MUST converted using value.toIso8601String()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class ProductColor {
  //  Property
  int pid; //  FK from Product
  String color;

  //  Constructor
  ProductColor({required this.pid, required this.color});

  //  Decode from Json type
  factory ProductColor.fromJson(Map<String, dynamic> json) {
    return ProductColor(
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
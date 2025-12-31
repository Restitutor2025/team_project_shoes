//  ProductImage Model
/*
  Create: 31/12/2025 12:53, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
    31/12/2025 18:10, 'Point 1, Changed model name to ProductImage', Creator: Chansol, Park
  Version: 1.0
  Dependency: 
  Desc: ProductImage Model

  DateTime MUST converted using value.toIso8601String()
  DateTime MUST converted using value: (json['value'] as num).toDouble()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class ProductImage {
  //  Property
  int pid;  //  FK from Product
  String path;
  String position;

  //  Constructor
  ProductImage({
    required this.pid, 
    required this.path, 
    required this.position
    });

  //  Decode from Json type
  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      pid: json['pid'],
      path: json['path'],
      position: json['position']
    );
  }

  //  Encode to Json type
  Map<String, dynamic> toJson(){
    return {
      'pid':pid,
      'path':path,
      'position':position
    };
  }
}

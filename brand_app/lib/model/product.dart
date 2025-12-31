//  product Model
/*
  Create: 31/12/2025 12:46, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: 
  Desc: product Model

  DateTime MUST converted using value.toIso8601String()
  DateTime MUST converted using value: (json['value'] as num).toDouble()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class Product {
  //  Property
  int? id;
  int mid;  //  FK from Product
  int quantity;
  int price;
  DateTime date;  //  Register date?
  String ename; //  English name

  //  Constructor
  Product({
    this.id, 
    required this.mid, 
    required this.quantity,
    required this.price,
    required this.date,
    required this.ename
    });

  //  Decode from Json type
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      mid: json['mid'],
      quantity: json['quantity'],
      price: json['price'],
      date: DateTime.parse(json['date']),
      ename: json['ename']
    );
  }

  //  Encode to Json type
  Map<String, dynamic> toJson(){
    return {
      'id':id,
      'mid':mid,
      'quantity':quantity,
      'price':price,
      'date':date.toIso8601String(),
      'ename':ename
    };
  }
}
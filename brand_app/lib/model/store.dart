//  store Model
/*
  Create: 31/12/2025 12:33, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: SQFlite, Path, collection
  Desc: store Model

  DateTime MUST converted using value.toIso8601String()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class Store {
  //  Property
  int? id;
  double lat; //  latitude
  double long;  //  longtitude
  String name;
  String address;
  String phone;

  //  Constructor
  Store({
    this.id, 
    required this.lat, 
    required this.long,
    required this.name,
    required this.address,
    required this.phone
    });

  //  Decode from Json type
  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'],
      lat: (json['lat'] as num).toDouble(),
      long: (json['long'] as num).toDouble(),
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
    );
  }

  //  Encode to Json type
  Map<String, dynamic> toJson(){
    return {
      'id':id,
      'lat':lat,
      'long':long,
      'name':name,
      'address':address,
      'phone':phone
    };
  }
}
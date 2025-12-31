//  receive Model
/*
  Create: 31/12/2025 13:59, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: 
  Desc: receive Model

  DateTime MUST converted using value.toIso8601String()
  DateTime MUST converted using value: (json['value'] as num).toDouble()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class Receive {
  //  Property
  int? id;
  int pid;  //  FK from Product
  int eid;  //  FK from Employee
  int mid;  //  FK from Manufacturer
  DateTime timestamp;
  int quantity;

  //  Constructor
  Receive({
    this.id, 
    required this.pid, 
    required this.eid, 
    required this.mid, 
    required this.timestamp,
    required this.quantity
    });

  //  Decode from Json type
  factory Receive.fromJson(Map<String, dynamic> json) {
    return Receive(
      id: json['id'],
      pid: json['pid'],
      eid: json['eid'],
      mid: json['mid'],
      timestamp: DateTime.parse(json['timestamp']),
      quantity: json['quantity'],
    );
  }

  //  Encode to Json type
  Map<String, dynamic> toJson(){
    return {
      'id':id,
      'pid':pid,
      'eid':eid,
      'mid':mid,
      'timestamp':timestamp.toIso8601String(),
      'quantity':quantity
    };
  }
}
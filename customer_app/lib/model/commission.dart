//  commission Model
/*
  Create: 31/12/2025 12:11, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: 
  Desc: commission Model

  DateTime MUST converted using value.toIso8601String()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class Commission {
  //  Property
  int? id;
  int eid;  //  FK from Employee
  int mid;  //  FK from Manufacturer
  int pid;  //  FK from Product
  DateTime timestamp;
  int quantity;

  //  Constructor
  Commission({
    this.id, 
    required this.eid, 
    required this.mid, 
    required this.pid, 
    required this.timestamp, 
    required this.quantity, 
    });

  //  Decode from Json type
  factory Commission.fromJson(Map<String, dynamic> json) {
    return Commission(
      id: json['id'],
      eid: json['eid'],
      mid: json['mid'],
      pid: json['pid'],
      timestamp: DateTime.parse(json['timestamp']),
      quantity: json['quantity'],
    );
  }

  //  Encode to Json type
  Map<String, dynamic> toJson(){
    return {
      'id':id,
      'eid':eid,
      'mid':mid,
      'pid':pid,
      'timestamp':timestamp.toIso8601String(),
      'quantity':quantity,
    };
  }
}
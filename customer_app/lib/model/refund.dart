//  refund Model
/*
  Create: 31/12/2025 14:03, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: 
  Desc: refund Model

  DateTime MUST converted using value.toIso8601String()
  DateTime MUST converted using value: (json['value'] as num).toDouble()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class Refund {
  //  Property
  int? id;
  int pcid; //  FK from Purchase
  int eid;  //  FK from Employee
  int cid;  //  FK from Customer
  DateTime refunddate;
  int quantity;

  //  Constructor
  Refund({
    this.id, 
    required this.pcid, //  FK from Purchase
    required this.eid,  //  FK from Employee
    required this.cid,  //  FK from Customer
    required this.refunddate,
    required this.quantity,
    });

  //  Decode from Json type
  factory Refund.fromJson(Map<String, dynamic> json) {
    return Refund(
      id: json['id'],
      pcid: json['pcid'],
      eid: json['eid'],
      cid: json['cid'],
      refunddate: DateTime.parse(json['refunddate']),
      quantity: json['quantity'],
    );
  }

  //  Encode to Json type
  Map<String, dynamic> toJson(){
    return {
      'id':id,
      'pcid':pcid,
      'eid':eid,
      'cid':cid,
      'refunddate':refunddate.toIso8601String(),
      'quantity':quantity
    };
  }
}
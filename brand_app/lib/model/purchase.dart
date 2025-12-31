//  purchase Model
/*
  Create: 31/12/2025 13:53, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: 
  Desc: purchase Model

  DateTime MUST converted using value.toIso8601String()
  DateTime MUST converted using value: (json['value'] as num).toDouble()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class Purchase {
  //  Property
  int? id;
  int pid;  //  FK from Product
  int cid;  //  FK from Customer
  int eid;  //  FK Employee
  int quantity;
  int finalprice;
  DateTime pickupdate;
  DateTime purchasedate;

  //  Constructor
  Purchase({
    this.id, 
    required this.pid, 
    required this.cid,
    required this.eid,
    required this.quantity,
    required this.finalprice,
    required this.pickupdate,
    required this.purchasedate,
    });

  //  Decode from Json type
  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'],
      pid: json['pid'],
      cid: json['cid'],
      eid: json['eid'],
      quantity: json['quantity'],
      finalprice: json['finalprice'],
      pickupdate: DateTime.parse(json['pickupdate']),
      purchasedate: DateTime.parse(json['purchasedate'])
    );
  }

  //  Encode to Json type
  Map<String, dynamic> toJson(){
    return {
      'id':id,
      'pid':pid,
      'cid':cid,
      'eid':eid,
      'quantity':quantity,
      'finalprice':finalprice,
      'pickupdate':pickupdate.toIso8601String(),
      'purchasedate':purchasedate.toIso8601String()
    };
  }
}
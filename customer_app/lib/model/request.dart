//  request Model
/*
  Create: 31/12/2025 14:08, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: 
  Desc: request Model

  DateTime MUST converted using value.toIso8601String()
  DateTime MUST converted using value: (json['value'] as num).toDouble()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class Request {
  //  Property
  int? id;
  int eid;  //  FK from Employee
  DateTime date;
  DateTime okdate;
  String contents;

  //  Constructor
  Request({
    this.id, 
    required this.eid, 
    required this.date,
    required this.okdate,
    required this.contents
    });

  //  Decode from Json type
  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      id: json['id'],
      eid: json['eid'],
      date: DateTime.parse(json['date']),
      okdate: DateTime.parse(json['okdate']),
      contents: json['contents']
    );
  }

  //  Encode to Json type
  Map<String, dynamic> toJson(){
    return {
      'id':id,
      'eid':eid,
      'date':date.toIso8601String(),
      'okdate':okdate.toIso8601String(),
      'contents':contents
    };
  }
}
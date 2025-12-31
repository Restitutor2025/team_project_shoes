//  EX web Model
/*
  Create: 26/12/2025 16:05, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: 
  Desc: EX web Model

  DateTime MUST converted using value.toIso8601String()
  DateTime MUST converted using value: (json['value'] as num).toDouble()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class ModelWeb {
  //  Property
  int? seq;
  String value1;
  double value2;
  DateTime value3;

  //  Constructor
  ModelWeb({
    this.seq, 
    required this.value1, 
    required this.value2,
    required this.value3
    });

  //  Decode from Json type
  factory ModelWeb.fromJson(Map<String, dynamic> json) {
    return ModelWeb(
      seq: json['seq'],
      value1: json['value1'],
      value2: (json['value2'] as num).toDouble(),
      value3: DateTime.parse(json['value3'])
    );
  }

  //  Encode to Json type
  Map<String, dynamic> toJson(){
    return {
      'seq':seq,
      'value1':value1,
      'value2':value2,
      'value3':value3.toIso8601String()
    };
  }
}

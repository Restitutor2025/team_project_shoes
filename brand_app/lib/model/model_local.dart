//  EX Model Local
/*
  Create: 10/12/2025 12:42, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: SQFlite, Path, collection
  Desc: EX Model Local

  DateTime MUST converted using value.toIso8601String()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class ModelEx {
  // Properties
  int? id;
  final String value1;
  final double value2;

  // Constructor
  ModelEx({this.id, required this.value1, required this.value2});

  ModelEx.fromMap(Map<String, Object?> map)
    : id = map['id'] as int?,
      value1 = map['value1'] as String,
      value2 = (map['value2'] as num).toDouble();

  Map<String, Object?> toMap({bool includeId = false}) {
    final map = <String, Object?>{'value1': value1, 'value2': value2};

    if (includeId) {
      map['id'] = id;
    }

    return map;
  }

  static const List<String> keys = ['id', 'value1', 'value2'];
  static const List<String> values = ['primary key integer autoincreament', 'text', 'REAL'];
}

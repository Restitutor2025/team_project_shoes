//  EX firebase Model
/*
  Create: 26/12/2025 16:13, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: firebase_core, cloud_firestore, firebase_storage, firebase_auth
  Desc: EX firebase Model

  DateTime MUST converted using value.toIso8601String()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class ModelFirebase {
  //  Property
  //  No auto-increment Primary key
  String value1;
  String value2;
  //  Constructor
  ModelFirebase({
    required this.value1,
    required this.value2,
  });
}
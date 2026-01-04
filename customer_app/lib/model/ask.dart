import 'package:cloud_firestore/cloud_firestore.dart';
//  Ask Model(for Chatting)
/*
  Create: 2/1/2026 10:17, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: firebase_core, cloud_firestore, firebase_storage, firebase_auth
  Desc: Ask Model(for Chatting)

  DateTime MUST converted using value.toIso8601String()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class Ask {
  final String? id; // Firestore doc id
  final String? cid; // FK from Customer
  final String? eid; // FK from Employee
  final String? pcid; // FK from Purchase
  final DateTime timestamp;
  final String contents;
  final String title;

  Ask({
    this.id,
    this.cid,
    this.eid,
    this.pcid,
    required this.timestamp,
    required this.contents,
    required this.title,
  });

  factory Ask.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw StateError('Ask document ${doc.id} has no data');
    }

    final ts = data['timestamp'];
    final DateTime time = ts is Timestamp
        ? ts.toDate()
        : DateTime.parse(ts as String);

    return Ask(
      id: doc.id,
      cid: data['cid'] as String?,
      eid: data['eid'] as String?,
      pcid: data['pcid'] as String?,
      timestamp: time,
      contents: data['contents'] as String,
      title: data['title'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cid': cid,
      'eid': eid,
      'pcid': pcid,
      'timestamp': Timestamp.fromDate(timestamp),
      'contents': contents,
      'title': title,
    };
  }
}

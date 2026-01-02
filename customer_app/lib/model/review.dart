import 'package:cloud_firestore/cloud_firestore.dart';

//  Review Model(for Chatting)
/*
  Create: 2/1/2026 11:27, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: cloud_firestore
  Desc: Review Model(for Chatting)

  DateTime MUST converted using value.toIso8601String()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class Review {
  final String? id; // Firestore doc id
  final String? cid; // FK from Customer
  final String? eid; // FK from Employee
  final int pcid; //  FK from Purchase
  final DateTime timestamp;
  final String contents;
  final double star;

  Review({
    this.id,
    this.cid,
    this.eid,
    required this.pcid,
    required this.timestamp,
    required this.contents,
    required this.star,
  });

  factory Review.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw StateError('Review document ${doc.id} has no data');
    }

    final ts = data['timestamp'];
    final DateTime time = ts is Timestamp
        ? ts.toDate()
        : DateTime.parse(ts as String);

    return Review(
      id: doc.id,
      cid: data['cid'] as String?,
      eid: data['eid'] as String?,
      pcid: (data['pcid'] as num).toInt(),
      timestamp: time,
      contents: data['contents'] as String,
      star: (data['star'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'pcid': pcid,
      'timestamp': FieldValue.serverTimestamp(),
      'contents': contents,
      'star': star,
    };
    if (eid != null) {
      map['eid'] = eid!;
    }
    if (cid != null) {
      map['cid'] = cid!;
    }
    return map;
  }
}

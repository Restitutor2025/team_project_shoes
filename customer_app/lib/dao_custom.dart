import 'package:customer_app/config.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

//  Custom DB DAOs
/*
  Create: 8/12/2025, Creator: Chansol, Park
  Update log: 
    9/29/2025 09:53, 'Point 1, CRUD table using keys', Creator: Chansol, Park
    9/29/2025 11:17, 'Delete OBSOLETE Functions', Creator: Chansol, Park
    9/29/2025 11:28, 'Point 2, Total class refactored by GPT', Creator: Chansol, Park
    12/12/2025 17:08, 'Point 3, Created Insert multyple datas from multiple/single Table, TableBatch Class', Creator: Chansol, Park
    14/12/2025 17:12, 'Total delete of created Batch/multibatchs', Creator: Chansol Park
    15/12/2025 17:12, 'Validation of columns attributes moved to db_validator.dart', Creator: Chansol Park
  Version: 1.0
  Dependency: SQFlite, Path, collection
  Desc: DB DAO presets
*/

//  Version, db preset
final String dbName = '$rDBName$rDBFileExt';
final int dVersion = rVersion;

//  AppDatabase onCreate
class RDB {
  static Database? _db;

  static Future<Database> instance(String dbName, int dVersion) async {
    if (_db != null) return _db!;

    final path = join(await getDatabasesPath(), dbName);

    _db = await openDatabase(path, version: dVersion);
    if (_db == null) {
      throw Exception('Database is EMPTY');
    }

    return _db!;
  }
}


//  zzimproduct = RDAO<Tablename>
class RDAO<T> {
  final String dbName;
  final String tableName;
  final int dVersion;
  final T Function(Map<String, Object?>) fromMap;

  RDAO({
    required this.dbName,
    required this.tableName,
    required this.dVersion,
    required this.fromMap,
  });

  Future<List<T>> queryAll() async {
    final db = await RDB.instance(dbName, dVersion);
    final sql = 'SELECT * FROM $tableName';
    final results = await db.rawQuery(sql);
    return results.map((e) => fromMap(e)).toList();
  }

  //  DBHandler.queryK({'Key': value})
  Future<List<T>> queryK(Map<String, Object?> keyList) async {
    if (keyList.isEmpty) {
      throw ArgumentError('keyList must NOT be empty');
    }
    final db = await RDB.instance(dbName, dVersion);
    final keyClause = keyList.keys.map((key) => '$key = ?').join(' AND ');
    final values = keyList.values.toList();
    final sql = 'SELECT * FROM $tableName WHERE $keyClause';

    final results = await db.rawQuery(sql, values);
    if (results.isEmpty) {
      throw Exception('EMPTY');
    }
    return results.map((e) => fromMap(e)).toList();
  }

  //  DBHandler.insertK(Tablename.toMap());
  Future<int> insertK(Map<String, Object?> data) async {
    try {
      final db = await RDB.instance(dbName, dVersion);

      final keys = data.keys.join(', ');
      final placeholders = List.filled(data.length, '?').join(', ');
      final sql = 'INSERT INTO $tableName ($keys) VALUES ($placeholders)';

      final result = await db.rawInsert(sql, data.values.toList());

      return result;
    } on DatabaseException catch (e) {
      print('INSERT DB Error in $tableName → $e');
      return -1;
    } catch (e) {
      print('UNKNOWN INSERT Error in $tableName → $e');
      return -1;
    }
  }

  // DBHandler.updateK(Tablename.toMap(), KeyListTable.toMap())
  Future<int> updateK(
    Map<String, Object?> data,
    Map<String, Object?> keyList,
  ) async {
    if (data.isEmpty) {
      throw ArgumentError('data must NOT be empty');
    }
    if (keyList.isEmpty) {
      throw ArgumentError('keyList must NOT be empty');
    }
    final db = await RDB.instance(dbName, dVersion);

    final setClause = data.keys.map((k) => '$k = ?').join(', ');
    final keyClause = keyList.keys.map((k) => '$k = ?').join(' AND ');

    final sql = 'UPDATE $tableName SET $setClause WHERE $keyClause';
    final values = [...data.values, ...keyList.values];
    return db.rawUpdate(sql, values);
  }
}

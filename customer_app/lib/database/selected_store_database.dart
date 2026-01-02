import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SelectedStoreDatabase {

  Future<Database> initializeDB() async {
    final dbPath = await getDatabasesPath();

    return openDatabase(
      join(dbPath, 'selected_store.db'),
      onCreate: (db, version) async {
        await db.execute(
          """
            create table selected_store (
              id integer primary key autoincrement,
              sid integer
            )
          """
        );
      },
      version: 1,
    );
  }

  // Query
  Future<int?> queryStoreId() async {
    final db = await initializeDB();

    final result = await db.rawQuery("select sid from selected_store");

    if (result.isEmpty) {return null;}
    
    final row = result.first;
    final value = row['sid'];

    if (value == null) {return null;}

    return value as int;
  }

  // Insert
  Future<int> insertStoreId(int storeId) async {
    final db = await initializeDB();

    await db.rawDelete("delete from selected_store");

    final result = await db.rawInsert(
      """
        insert into selected_store (sid)
        values (?)
      """,
      [storeId]
    );

    return result;
  }

  // Delete
  Future<void> deleteStoreId() async {

    final db = await initializeDB();

    await db.rawDelete("delete from selected_store");
  }
}

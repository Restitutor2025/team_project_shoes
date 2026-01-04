import 'package:customer_app/model/cart.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Cartdatabasehandler {
  Future<Database> initalizeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'cart.db'),
      onCreate: (db, version) async {
        await db.execute(
          '''
          CREATE TABLE cart (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cid INTEGER,
            cartid INTEGER
          )
          ''',
        );
      },
      version: 1,
    );
  }

  Future<int> insertCart(Cart cart) async {
    final Database db = await initalizeDB();
    return await db.insert(
      'cart',
      {
        'cid': cart.cid,
        'cartid': cart.cartid,
      },
    );
  }

  Future<List<Cart>> queryCart() async {
    final Database db = await initalizeDB();
    final List<Map<String, dynamic>> queryResult = await db.query('cart');
    return queryResult.map((e) => Cart.fromMap(e)).toList();
  }

  Future<int> deleteCart(int id) async {
    final Database db = await initalizeDB();
    return await db.delete('cart', where: 'id = ?', whereArgs: [id]);
  }
}
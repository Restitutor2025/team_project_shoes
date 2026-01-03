import 'package:customer_app/model/cart.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Cartdatabasehandler {
  // ================= DB 생성 =================
  Future<Database> initalizeDB() async {
    String path = await getDatabasesPath();

    return openDatabase(
      join(path, 'cart.db'),
      onCreate: (db, version) async {
        await db.execute(
          '''
          CREATE TABLE cart (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cartid INTEGER
          )
          ''',
        );
      },
      version: 1,
    );
  }

  // ================= 장바구니 전체 조회 =================
  Future<List<Cart>> queryCart() async {
    final Database db = await initalizeDB();

    final List<Map<String, dynamic>> queryResult =
        await db.query('cart');

    return queryResult.map((e) => Cart.fromMap(e)).toList();
  }

  // ================= 장바구니 추가 =================
  Future<int> insertCart(Cart cart) async {
    final Database db = await initalizeDB();

    return await db.insert(
      'cart',
      {
        'cartid': cart.cartid,
      },
    );
  }

  // ================= 장바구니 삭제 (row 단위) =================
  Future<int> deleteCart(int id) async {
    final Database db = await initalizeDB();

    return await db.delete(
      'cart',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ================= 전체 삭제 (선택) =================
  Future<void> clearCart() async {
    final Database db = await initalizeDB();
    await db.delete('cart');
  }
}

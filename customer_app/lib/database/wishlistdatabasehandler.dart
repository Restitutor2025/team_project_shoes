import 'package:customer_app/model/wishlist.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


class Wishlistdatabasehandler {

  Future<Database>initalizeDB() async{
    String path =await getDatabasesPath();

    return openDatabase(
      join(path,'cart.db'),
      onCreate: (db, version) async{
        await db.execute(
          """
        create table wishlist
        (
        id integer primary key autoincrement,
        pid integer,
        cid integer,
        cartid integer
        )
          """
        );
      },
      version: 1,
    );

  }
Future<List<Wishlist>> queryWishlist() async{
  final Database db= await initalizeDB();
  final List<Map<String,Object?>> queryResult=
  await db.rawQuery(
    """
  select *from wishlist
  where cartid is notnull
    """
  );
  return queryResult.map((e) => Wishlist.fromMap(e)).toList();
}


}
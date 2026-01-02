
import 'package:customer_app/model/cart.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class Cartdatabasehandler {


  Future<Database>initalizeDB() async{
    String path =await getDatabasesPath();

    return openDatabase(
    join(path,'cart.db'),
    onCreate: (db, version) async{
      await db.execute(
        """
create table address
    (
    id integer primary key autoincrement,
    cartid integer

    )
      """ 
      );
    },
    version: 1,
    );  
  }
Future<List<Cart>> queryCart() async{
  final Database db =await initalizeDB();
  final List<Map<String,Object?>> queryResult =
  await db.rawQuery(
    """
  select *from where cartid is not null
    """
  );
  return queryResult.map((e) => Cart.fromMap(e)).toList();
}

Future<int> insertCart(Cart cart) async{
  int result=0;
  final Database db =await initalizeDB();
  result =await db.rawInsert(
    """
   

    """
  );
  return result;
}

}
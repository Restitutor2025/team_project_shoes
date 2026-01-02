class Wishlist {

  int? id;
  int pid;
  int cid;
  int cartid;

  Wishlist({
  this.id,
  required this.pid,
  required this.cid,
  required this.cartid
  
  });

  Wishlist.fromMap(Map<String,dynamic>res)
  :id =res['id'],
  pid=res['pid'],
  cid=res['cid'],
  cartid=res['cartid'];

}

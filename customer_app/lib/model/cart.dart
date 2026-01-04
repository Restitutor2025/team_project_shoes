class Cart {

  int? id;
  int cid;
  int cartid;



  Cart({
    this.id,
    required this.cid,
    required this.cartid
  });

  Cart.fromMap(Map<String,dynamic> res)
    :id =res['id'],
    cid=res['cid'],
    cartid=res['cartid'];
  
}
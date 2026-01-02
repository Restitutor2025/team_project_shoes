class Cart {

  int? id;
  int cartid;



  Cart({
    this.id,
    required this.cartid
  });

  Cart.fromMap(Map<String,dynamic> res)
    :id =res['id'],
    cartid=res['cartid'];
  
}
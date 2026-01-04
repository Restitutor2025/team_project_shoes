class Cart {
  int? id;
  int cid;    // DB에 추가할 필드
  int cartid; // 상품 상세 ID

  Cart({
    this.id,
    required this.cid,
    required this.cartid,
  });

  // DB 데이터를 객체로 변환
  Cart.fromMap(Map<String, dynamic> res)
      : id = res['id'],
        cid = res['cid'],
        cartid = res['cartid'];

  // 객체 데이터를 DB 전송용 Map으로 변환 (insert 시 편리함)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cid': cid,
      'cartid': cartid,
    };
  }
}
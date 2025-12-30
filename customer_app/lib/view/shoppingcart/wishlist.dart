import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Wishlist extends StatefulWidget {
  const Wishlist({super.key});

  @override
  State<Wishlist> createState() => _WishlistState();
}

class _WishlistState extends State<Wishlist> {
  late bool check;
  late int count;


  @override
  void initState() {
    super.initState();
    check=false;
    count=0;
  
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("찜목록",
        style: TextStyle(
          fontWeight: FontWeight.bold
        ),
      
        ),
        centerTitle: true,
      ),
      body:Center(
        child: Column(
          
          children: [
             ListTile(
             
             leading: Image.asset("images/logo.png",
             width: 100,
             height: 100,
             fit: BoxFit.cover,),
             title: Text("나이키",
             style: TextStyle(fontWeight: FontWeight.bold),),
             subtitle:Column(
              children: [
                Text("나이키 에어포스"),
                Text("92000원"),
               
                
              ],
             
             ) ,
             trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(value: check,
                 onChanged: (value) {
                
                   check=value!;
                   setState(() {
                     
                   });
                 },),
               
              ],
             ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: ElevatedButton(
        onPressed: () {
          deletedialog();
        },
        child: Text("삭제하기"),
         style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(4),
                ),
              ),),
    );
  }//class

  deletedialog(){
    Get.defaultDialog(
      title: "찜 목록 삭제",
      middleText: "찜 목록에서 삭제하시겠습니까?",
      actions:[
        TextButton(onPressed:  () {
          Get.back();
        },
         child: Text("삭제")),
        TextButton(onPressed:  () {
          Get.back();
        },
         child: Text("취소")),
      ] 
    );
  }

shoppingcartmove(){
  Get.bottomSheet(
    Container(
      width: 500,
      height: 500,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text("사이즈"),
          // DropdownButton(items: items, onChanged: onChanged),
          Text("지점"),
          // DropdownButton(items: items, onChanged: onChanged),
          Text("수량"),
          Row(
                  children: [
                    TextButton(onPressed: () {
                      count--;
                      setState(() {
                        
                      });
                    }, child: Text("-")),
                    Text("$count"),
                    TextButton(onPressed: () {
                      count++;
                      setState(() {
                        
                      });
                    }, child: Text("+")),

                  ],
                ),
        ],
      ),
    )
  );
}
  
}//build
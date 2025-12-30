import 'package:customer_app/util/pcolor.dart';
import 'package:flutter/material.dart';

class Shoppingcart extends StatefulWidget {
  const Shoppingcart({super.key});

  @override
  State<Shoppingcart> createState() => _ShoppingcartState();
}

class _ShoppingcartState extends State<Shoppingcart> {
  late int count;

  @override
  void initState() {
    super.initState();
    count=0;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("장바구니",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold
        ),),
        centerTitle: true,
      ),
      body: Center(
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

             ) ,
             trailing: Column(
              children: [
                Text("X\n",
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),),
                Text("92000원")
              ],
             ),
              ),
              
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("총결제금액:"),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(onPressed: () {
              
            }, child: Text("구매하기"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                 shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(4)
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
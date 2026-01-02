import 'package:flutter/material.dart';

class ExecutiveMainpage extends StatefulWidget {
  const ExecutiveMainpage({super.key});

  @override
  State<ExecutiveMainpage> createState() => _ExecutiveMainpageState();
}

class _ExecutiveMainpageState extends State<ExecutiveMainpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: ElevatedButton(
                  
                  style: ElevatedButton.styleFrom(
                   
                    minimumSize:Size(400,400),
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                     shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadiusGeometry.circular(
                                  4,
                                ),
                          ),
                    
                  ),
                  onPressed: () {
                    
                  },
                  child: Text("판매 및 매출 현황")),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize:Size(400,400),
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                     shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadiusGeometry.circular(
                                  4,
                                ),
                          ),
                  ),
                  onPressed: () {
                    
                  },
                  child: Text("결제 승인")),
              ),

          ],
        ),
      ),
    );
  }
}
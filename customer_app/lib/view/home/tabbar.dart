import 'package:customer_app/database/selected_store_database.dart';
import 'package:customer_app/view/home/home.dart';
import 'package:customer_app/view/map/map_select.dart';
import 'package:customer_app/view/mypage/mypage.dart';
import 'package:customer_app/view/shoppingcart/shoppingcart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:customer_app/ip/ipaddress.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// 1. StoreController 정의 (파일 상단 혹은 별도 파일)
class StoreController extends GetxController {
  var selectedStoreName = "지점을 선택해주세요".obs;
  void updateStoreName(String name) => selectedStoreName.value = name;
}

class Tabbar extends StatefulWidget {
  const Tabbar({super.key});

  @override
  State<Tabbar> createState() => _TabbarState();
}

class _TabbarState extends State<Tabbar> {
  final StoreController storeController = Get.put(StoreController());
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Home(),
    const MapSelect(),
    const Shoppingcart(),
    const Mypage()
  ];

  @override
  void initState() {
    super.initState();
    _initialLoad();
  }

  // 앱 켜질 때 SQLite에서 기존 sid 읽어서 이름 가져오기
  Future<void> _initialLoad() async {
    final db = SelectedStoreDatabase();
    int? sid = await db.queryStoreId();
    if (sid != null) {
      try {
        var url = Uri.parse('${IpAddress.baseUrl}/store/select_one?id=$sid');
        var response = await http.get(url);
        if (response.statusCode == 200) {
          var data = json.decode(utf8.decode(response.bodyBytes));
          if (data['results'].isNotEmpty) {
            String name = data['results'][0]['name'];
            storeController.updateStoreName(name); // 컨트롤러 값 업데이트
          }
        }
      } catch (e) {
        debugPrint("초기 로드 에러: $e");
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- 지점 정보 표시줄 (Obx로 감싸서 실시간 반영) ---
          Obx(() => GestureDetector(
            onTap: () => _onItemTapped(1), // 클릭 시 지도 페이지로
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              color: const Color(0xFF1E1E1E), 
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.redAccent, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    storeController.selectedStoreName.value,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  const Icon(Icons.refresh, color: Colors.grey, size: 14),
                ],
              ),
            ),
          )),
          // --- 하단 탭바 ---
          BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: const Color(0xFF121212),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.location_on_outlined), activeIcon: Icon(Icons.location_on), label: 'Location'),
              BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), activeIcon: Icon(Icons.shopping_bag), label: 'Shop'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ],
      ),
    );
  }
}
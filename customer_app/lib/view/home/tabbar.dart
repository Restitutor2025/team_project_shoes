import 'package:customer_app/view/home/home.dart';
import 'package:customer_app/view/map/map_select.dart';
import 'package:customer_app/view/mypage/mypage.dart';
import 'package:customer_app/view/shoppingcart/shoppingcart.dart';
import 'package:flutter/material.dart';

class Tabbar extends StatefulWidget {
  const Tabbar({super.key});

  @override
  State<Tabbar> createState() => _TabbarState();
}

class _TabbarState extends State<Tabbar> {
  // 현재 선택된 탭의 인덱스
  int _selectedIndex = 0;

  // 1. 여기에 각 탭을 눌렀을 때 보여줄 페이지들을 넣으세요.
  final List<Widget> _pages = [
    Home(),
    MapSelect(),
    Shoppingcart(),
    Mypage()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 현재 선택된 인덱스의 페이지를 보여줌
      body: _pages[_selectedIndex],
      
      // 하단 탭바 설정
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // 아이템이 4개 이상일 때도 고정
        backgroundColor: const Color(0xFF121212), // 사진과 같은 진한 검정색
        selectedItemColor: Colors.white, // 선택된 아이콘 색상
        unselectedItemColor: Colors.grey, // 선택되지 않은 아이콘 색상
        showSelectedLabels: false, // 선택된 라벨 숨김 (사진처럼 아이콘만 표시)
        showUnselectedLabels: false, // 선택되지 않은 라벨 숨김
        currentIndex: _selectedIndex, // 현재 인덱스
        onTap: _onItemTapped, // 터치 이벤트
        
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            activeIcon: Icon(Icons.location_on),
            label: 'Location',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
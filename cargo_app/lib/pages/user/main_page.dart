import 'package:flutter/material.dart';

import 'car_list_page.dart';
import 'booking_history_page.dart';
import 'profile_page.dart';
import 'home_page.dart';

class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;

  void changeTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  late final List<Widget> pages = [
    HomePage(onTabChange: changeTab),
    CarListPage(),
    BookingHistoryPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: pages[currentIndex]),

      /// 🔥 MODERN BOTTOM NAVBAR
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          onTap: changeTab,

          /// 🔥 WARNA CONSISTENT
          selectedItemColor: const Color(0xFF667EEA),
          unselectedItemColor: Colors.grey,

          /// 🔥 STYLE LABEL
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),

          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_car),
              label: "Cars",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: "History",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}

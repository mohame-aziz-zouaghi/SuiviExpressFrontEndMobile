import 'package:flutter/material.dart';
import 'package:suiviexpress_app/presentation/pages/mainpages/User/UserProfilePage.dart';
import 'package:suiviexpress_app/presentation/pages/mainpages/home/home_page.dart';
import 'package:suiviexpress_app/presentation/pages/mainpages/product/products_page.dart';
import 'package:suiviexpress_app/presentation/widgets/buttom_nav_bar.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  int selectedIndex = 0;


  late final List<Widget> pages = [
    const HomeLandingPage(), // 👈 this is the new landing page
    const Center(child: Text("🔔 Notifications", style: TextStyle(fontSize: 22))),
    const ProductsPage(), // 👈 Products page
    const Center(child: Text("🛒 Cart", style: TextStyle(fontSize: 22))),
    const UserProfilePage(), // 👈 Products page
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: pages[selectedIndex],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: selectedIndex,
        onItemTapped: onItemTapped,
      ),
    );
  }
}

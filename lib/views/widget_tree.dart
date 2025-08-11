import 'package:flows/views/pages/search_page.dart';
import 'package:flutter/material.dart';
import 'package:flows/views/pages/home_page.dart'; // Your HomePage
import 'package:flows/views/pages/profile_page.dart'; // Your ProfilePage
import 'package:flows/views/widgets/custom_bottom_navbar.dart'; // Your CustomBottomNavBar

final List<Widget> pages = [
  const HomePage(),
  const SearchPage(),
  const Center(child: Text("Add/Create Page", style: TextStyle(color: Colors.white))), // Placeholder
  const Center(child: Text("Library Page", style: TextStyle(color: Colors.white))), // Placeholder
  const ProfilePage(),
];

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: pages[_selectedIndex], 

      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
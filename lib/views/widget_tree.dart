import 'package:flutter/material.dart';
import 'package:flows/views/pages/home_page.dart'; // Your HomePage
import 'package:flows/views/widgets/custom_bottom_navbar.dart'; // Your CustomBottomNavBar

// Define your list of pages
// Each page should be a Widget (e.g., HomePage, SearchPage, etc.)
final List<Widget> pages = [
  const HomePage(), // Your existing HomePage
  const Center(child: Text("Search Page", style: TextStyle(color: Colors.white))), // Placeholder
  const Center(child: Text("Add/Create Page", style: TextStyle(color: Colors.white))), // Placeholder
  const Center(child: Text("Books Page", style: TextStyle(color: Colors.white))), // Placeholder
  const Center(child: Text("Profile Page", style: TextStyle(color: Colors.white))), // Placeholder
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
      backgroundColor: Colors.black, // Background for the Scaffold
      body: pages[_selectedIndex], // Display the selected page from the list

      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
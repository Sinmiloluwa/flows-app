import 'package:flows/views/pages/home_page.dart';
import 'package:flutter/material.dart';

List<Widget> pages = [
  HomePage()
];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: pages[0],
    );
  }
}

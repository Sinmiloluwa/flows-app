import 'package:flows/views/pages/home_page.dart';
import 'package:flows/views/widget_tree.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:flows/views/pages/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.black
        ),
        child: Center(
          child: Lottie.asset(
            'assets/images/splash.json',
            width: 300,
            height: 300,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}

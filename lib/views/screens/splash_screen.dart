import 'package:flows/views/widget_tree.dart';
import 'package:flows/services/session_service.dart';
import 'package:flutter/material.dart';
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
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for the splash animation
    await Future.delayed(Duration(seconds: 2));
    
    // Check if user is already logged in
    bool isLoggedIn = await SessionService.isLoggedIn();
    
    if (isLoggedIn) {
      // User has a valid session, navigate to main app
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WidgetTree()),
      );
    } else {
      // No valid session, navigate to login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
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

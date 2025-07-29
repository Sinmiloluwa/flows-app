import 'package:flutter/material.dart';
import 'package:flows/data/texts.dart';
import 'package:flows/views/pages/signup_page.dart';
import 'package:flows/views/widgets/build_input_text.dart';
import 'package:flows/views/widgets/button.dart';
import 'package:flows/views/pages/home_page.dart';
import 'package:flows/views/widget_tree.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flows/views/widgets/loading_dots.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isObscure = true;
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.arrow_back),
      ),
      body: Padding(
          padding: EdgeInsets.all(20.0),
              child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Login to your account',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20.0
            ),
          ),
          SizedBox(height: 20,),
          Form(
              key: _formKey,
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email', style: kTextStyle.titleText),
              BuildInputText(
                controller: _emailController,
                hintText: 'hello@company.com',
                isObscure: false,
                isPasswordField: false,
              ),
              const SizedBox(height: 20),
              Text('Password', style: kTextStyle.titleText),
              BuildInputText(
                controller: _passwordController,
                hintText: 'password',
                isObscure: _isObscure,
                isPasswordField: true,
              ),
              const SizedBox(height: 20.0,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Forgot Password?', style: TextStyle(
                      color: Colors.green,
                      fontSize: 16.0
                  ),),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupPage()),
                      );
                    },
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 16.0,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20.0,),
              Button(
                text: 'Log in',
                onPressed: login,
              ),
            ],
          )),
          const SizedBox(height: 30.0,),
          Row(
            children: <Widget>[
              Expanded(
                child: Divider(
                  color: Colors.grey[700], // adjust to match the image's darkness
                  thickness: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  "OR",
                  style: TextStyle(color: Colors.grey[400]), // light grey text
                ),
              ),
              Expanded(
                child: Divider(
                  color: Colors.grey[700],
                  thickness: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0,),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                    side: BorderSide(color: Colors.grey[700]!, width: 0.3),
                  ),
                ),
              ),
              onPressed: () {},
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      'assets/images/apple.png',
                      height: 24,
                      width: 24,
                    ),
                  ),
                  Center(
                    child: Text(
                      'Continue with Apple',
                      style: TextStyle(
                          color: Colors.white,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20.0,),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                    side: BorderSide(color: Colors.grey[700]!, width: 0.3), // white border
                  ),
                ),
              ),
              onPressed: () {},
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      'assets/images/google-logo.png',
                      height: 24,
                      width: 24,
                    ),
                  ),
                  Center(
                    child: Text(
                      'Continue with Google',
                      style: TextStyle(
                          color: Colors.white,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  void login() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Please fill in all fields', style: TextStyle(color: Colors.white),),
        ),
      );
      return;
    }
    print('Api called');
    final url = Uri.parse('https://flows-backend.onrender.com/api/auth/login');
    print(_emailController.text);
    FocusScope.of(context).unfocus(); // Dismiss keyboard

    setState(() {
      _isLoading = true;
    });

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator(backgroundColor: Colors.green,)),
    );
    try {
      final response = await http.post(
        url,
        body: {
          'email': _emailController.text,
          'password': _passwordController.text,
        },
      );
      Navigator.of(context, rootNavigator: true).pop();

      setState(() {
        _isLoading = false;
      });
      if (response.statusCode == 201) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WidgetTree()),
        );
      } else {
        final responseBody = json.decode(response.body);
        final errorMsg = responseBody['message'] ?? 'Login failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.red,
              content: Text(errorMsg, style: TextStyle(color: Colors.white),),
          ),
        );
      }
    } catch (error) {
      Navigator.of(context, rootNavigator: true).pop();

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Network error', style: TextStyle(color: Colors.white),),
        ),
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flows/data/texts.dart';
import 'package:flows/views/pages/signup_page.dart';
import 'package:flows/views/widgets/build_input_text.dart';
import 'package:flows/views/widgets/button.dart';
import 'package:flows/views/pages/home_page.dart';
import 'package:flows/views/widget_tree.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isObscure = true;
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
          Text('Email', style: kTextStyle.titleText),
          BuildInputText(
            hintText: 'hello@company.com',
            isObscure: false,
            isPasswordField: false,
          ),
          const SizedBox(height: 20),
          Text('Password', style: kTextStyle.titleText),
          BuildInputText(
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
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => WidgetTree()),
              );
            },
          ),
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

  // Widget _buildInputText({
  //   required String hintText,
  //   required bool isObscure,
  //   required bool isPasswordField,
  // }) {
  //   return TextField(
  //     obscureText: isPasswordField ? isObscure : false,
  //     style: const TextStyle(color: Colors.white),
  //     decoration: InputDecoration(
  //       suffixIcon: isPasswordField
  //           ? IconButton(
  //         icon: Icon(
  //           isObscure ? Icons.visibility_off : Icons.visibility,
  //           color: isObscure ? Colors.grey : Colors.white,
  //         ),
  //         onPressed: () {
  //           setState(() {
  //             _isObscure = !_isObscure;
  //           });
  //         },
  //       )
  //           : null,
  //       hintText: hintText,
  //       hintStyle: const TextStyle(color: Colors.white54),
  //       prefixIcon: Icon(
  //         isPasswordField ? Icons.lock : Icons.mail,
  //         color: Colors.white,
  //       ),
  //       border: const OutlineInputBorder(),
  //       focusedBorder: OutlineInputBorder(
  //         borderSide: BorderSide(color: Colors.green, width: 2.0),
  //       ),
  //     ),
  //     maxLength: 50,
  //     onChanged: (text) {
  //       print('Entered value: $text');
  //     },
  //   );
  // }
}

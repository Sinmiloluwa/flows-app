import 'package:flutter/material.dart';
import 'package:flows/views/widgets/build_input_text.dart';
import 'package:flows/views/widgets/button.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool _isObscure = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          width: 10.0,
          decoration: BoxDecoration(
            color: Colors.grey[900], // Set your desired background color
            borderRadius: BorderRadius.circular(50), // Adjust radius as needed
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            iconSize: 20.0,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        title: const Text('Sign Up'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.0,),
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
              const SizedBox(height: 40.0,),
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
              BuildInputText(
                hintText: 'email',
                isObscure: false,
                isPasswordField: false,
              ),
              const SizedBox(height: 20.0,),
              BuildInputText(
                hintText: 'password',
                isObscure: _isObscure,
                isPasswordField: true,
              ),
              const SizedBox(height: 20.0,),
              Button(text: 'Sign up', onPressed: () {}),
            ]
        ),
      ),
    );
  }
}

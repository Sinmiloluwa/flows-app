import 'package:flutter/material.dart';
import 'package:flows/views/widgets/loading_dots.dart';

class Button extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const Button({
    Key? key,
    required this.text,
    required this.onPressed,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
        onPressed: onPressed,
        child: Text(text, style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold
        )),
      ),
    );
  }
}

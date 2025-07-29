import 'package:flutter/material.dart';

class BuildInputText extends StatelessWidget {
  final String hintText;
  final bool isObscure;
  final bool isPasswordField;
  final ValueChanged<String>? onChanged;

  const BuildInputText({
    Key? key,
    required this.hintText,
    required this.isObscure,
    required this.isPasswordField,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: isPasswordField ? isObscure : false,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        suffixIcon: isPasswordField
            ? Icon(
          isObscure ? Icons.visibility_off : Icons.visibility,
          color: isObscure ? Colors.grey : Colors.white,
        )
            : null,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(
          isPasswordField ? Icons.lock : Icons.mail,
          color: Colors.white,
        ),
        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green, width: 2.0),
        ),
      ),
      maxLength: 50,
      onChanged: onChanged,
    );
  }
}
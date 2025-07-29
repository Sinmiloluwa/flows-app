import 'package:flutter/material.dart';

class BuildInputText extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final bool isObscure;
  final bool isPasswordField;
  final ValueChanged<String>? onChanged;

  const BuildInputText({
    Key? key,
    this.controller,
    required this.hintText,
    required this.isObscure,
    required this.isPasswordField,
    this.onChanged,
  }) : super(key: key);

  @override
  State<BuildInputText> createState() => _BuildInputTextState();
}

class _BuildInputTextState extends State<BuildInputText> {
  late bool _isObscure;

  @override
  void initState() {
    super.initState();
    _isObscure = widget.isObscure;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPasswordField ? _isObscure : false,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        suffixIcon: widget.isPasswordField
            ? IconButton(
          icon: Icon(
            _isObscure ? Icons.visibility_off : Icons.visibility,
            color: _isObscure ? Colors.grey : Colors.white,
          ),
          onPressed: () {
            setState(() {
              _isObscure = !_isObscure;
            });
          },
        )
            : null,
        hintText: widget.hintText,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(
          widget.isPasswordField ? Icons.lock : Icons.mail,
          color: Colors.white,
        ),
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green, width: 2.0),
        ),
      ),
      maxLength: 50,
      onChanged: widget.onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Field is required';
        }
        if (widget.isPasswordField && value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }
}
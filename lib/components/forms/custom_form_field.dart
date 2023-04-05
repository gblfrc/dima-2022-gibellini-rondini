import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  final String text;
  final double width;

  final TextEditingController controller;
  bool? obscure = false;

  CustomFormField({
    super.key,
    required this.text,
    required this.width,
    required this.controller,
    this.obscure,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure ?? false,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: EdgeInsets.all(width / 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        hintText: text,
      ),
    );
  }
}

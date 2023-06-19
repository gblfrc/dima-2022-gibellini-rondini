import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  final String text;

  final TextEditingController controller;
  bool? obscure;
  bool? numericOnly;
  String? Function(String?)? validator;

  CustomFormField({
    super.key,
    required this.text,
    required this.controller,
    this.obscure,
    this.numericOnly,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      return TextFormField(
        controller: controller,
        obscureText: obscure ?? false,
        keyboardType: numericOnly ?? false ? TextInputType.number : null,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: EdgeInsets.all(constraint.maxWidth / 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          hintText: text,
        ),
        validator: validator,
      );
    });
  }
}

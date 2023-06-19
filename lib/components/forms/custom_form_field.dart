import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  final String text;

  final TextEditingController controller;
  final bool obscure;
  final bool numericOnly;
  final String? Function(String?)? validator;

  const CustomFormField({
    super.key,
    required this.text,
    required this.controller,
    this.obscure = false,
    this.numericOnly = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      return TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: numericOnly ? TextInputType.number : null,
        decoration: InputDecoration(
          suffixIcon: IconButton(
            onPressed: () {
              controller.text = "";
            },
            icon: const Icon(Icons.close),
          ),
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

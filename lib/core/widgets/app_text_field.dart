import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.hint,
    super.key,
    this.controller,
    this.obscureText = false,
    this.validator,
    this.prefixIcon,
    this.keyboardType,
  });

  final String hint;
  final TextEditingController? controller;
  final bool obscureText;
  final String? Function(String)? validator;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator == null ? null : (value) => validator!(value ?? ''),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
      ),
    );
  }
}

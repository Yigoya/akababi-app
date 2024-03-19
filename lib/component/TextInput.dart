import 'package:flutter/material.dart';

class TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool isPass;
  const TextInput(
      {super.key,
      required this.controller,
      required this.hint,
      required this.isPass});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              offset: Offset(0, 1),
              blurRadius: 1,
            )
          ],
          border: Border.all(color: Colors.black.withOpacity(0.7), width: 1),
          borderRadius: BorderRadius.circular(10)),
      child: TextField(
        obscureText: isPass,
        controller: controller,
        decoration: InputDecoration(
            hintText: hint,
            border: InputBorder.none,
            hintStyle: TextStyle(fontSize: 15)),
      ),
    );
  }
}

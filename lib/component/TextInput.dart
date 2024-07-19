import 'package:flutter/material.dart';

class TextInput extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool isPass;
  const TextInput(
      {super.key,
      required this.controller,
      required this.hint,
      required this.isPass});

  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  bool obscureText = true;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              offset: const Offset(0, 1),
              blurRadius: 1,
            )
          ],
          border: Border.all(color: Colors.black.withOpacity(0.7), width: 1),
          borderRadius: BorderRadius.circular(10)),
      child: TextField(
        obscureText: widget.isPass && obscureText,
        controller: widget.controller,
        decoration: InputDecoration(
          hintText: widget.hint,
          border: InputBorder.none,
          hintStyle: const TextStyle(fontSize: 15),
          suffixIcon: widget.isPass
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => setState(() => obscureText = !obscureText),
                )
              : null,
        ),
      ),
    );
  }
}

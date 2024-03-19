import 'package:flutter/material.dart';

class OptionText extends StatelessWidget {
  final void Function() func;
  final String text;
  const OptionText({super.key, required this.func, required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: func,
      child: Container(
        child: Text(
          text,
          style: TextStyle(color: Colors.cyan, fontSize: 15),
        ),
      ),
    );
  }
}

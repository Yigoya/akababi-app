import 'package:flutter/material.dart';

class CommonButton extends StatelessWidget {
  final bool active;
  final String buttonText;
  final VoidCallback onPressed;

  const CommonButton(
      {super.key,
      required this.buttonText,
      required this.onPressed,
      required this.active});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: active ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: active ? Colors.red : Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
      child: Text(
        buttonText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    );
  }
}

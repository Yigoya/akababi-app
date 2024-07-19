import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final void Function() func;
  final String text;
  final bool isEnabled;
  const Button(
      {super.key,
      required this.func,
      required this.text,
      this.isEnabled = true});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? func : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(35),
            color: isEnabled
                ? const Color.fromARGB(255, 247, 114, 25)
                : Colors.black.withOpacity(0.3)),
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
    );
  }
}

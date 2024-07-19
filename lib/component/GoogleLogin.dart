import 'package:flutter/material.dart';

class GoogleLogin extends StatelessWidget {
  final String text;
  final Future<dynamic> Function() func;
  const GoogleLogin({super.key, required this.func, required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await func();
      },
      child: Container(
        width: 300,
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(35),
            border: Border.all(color: const Color.fromARGB(255, 243, 137, 51))),
        child: Row(
          children: [
            Image.asset(
              "assets/image/google.png",
              width: 40,
            ),
            const SizedBox(
              width: 25,
            ),
            Text(
              text,
              style: const TextStyle(
                  color: Color.fromARGB(255, 243, 137, 51),
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}

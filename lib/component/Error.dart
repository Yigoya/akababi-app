import 'package:flutter/material.dart';

class ErrorItem extends StatelessWidget {
  final String? error;
  final bool? isLoading;
  const ErrorItem({super.key, required this.error, this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading == true) {
      print("object");
      return const CircularProgressIndicator.adaptive();
    } else if (error != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.red, width: 1),
            borderRadius: BorderRadius.circular(10),
            color: Colors.black.withOpacity(0.1)),
        child: Text(error!),
      );
    } else {
      return Container();
    }
  }
}

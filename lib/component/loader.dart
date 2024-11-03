import 'package:flutter/material.dart';

class BeautifulLoader extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final Widget child;

  const BeautifulLoader({
    super.key,
    required this.isLoading,
    this.errorMessage,
    this.child = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
              Colors.deepPurple), // Custom color for loader
          strokeWidth: 5, // Custom thickness
        ),
      );
    } else if (errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.red[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error,
              color: Colors.red,
            ),
            const SizedBox(width: 10),
            Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      );
    } else {
      return child;
    }
  }
}

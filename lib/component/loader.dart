import 'package:flutter/material.dart';

class BeautifulLoader extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final Widget child;

  BeautifulLoader({
    required this.isLoading,
    this.errorMessage,
    this.child = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
              Colors.deepPurple), // Custom color for loader
          strokeWidth: 5, // Custom thickness
        ),
      );
    } else if (errorMessage != null) {
      return Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 32, // Larger icon for better visibility
            ),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                softWrap: true,
                errorMessage!,
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 18, // Larger font size for readability
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
      );
    } else {
      return child;
    }
  }
}

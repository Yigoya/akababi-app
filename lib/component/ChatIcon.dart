import 'package:flutter/material.dart';

class ChatIcon extends StatelessWidget {
  final bool isOnline;
  final String imageUrl;
  final String username; // Added username field

  const ChatIcon({
    Key? key,
    required this.isOnline,
    required this.imageUrl,
    required this.username, // Added username parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(imageUrl),
              radius: 28,
            ),
            if (isOnline)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        Text(
          '@$username', // Display username with '@' prefix
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

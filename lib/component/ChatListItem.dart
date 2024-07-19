import 'package:flutter/material.dart';

class ChatListItem extends StatelessWidget {
  final String fullName;
  final String lastMessage;
  final bool isDelivered;

  const ChatListItem({super.key, 
    required this.fullName,
    required this.lastMessage,
    required this.isDelivered,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ChatIcon(
        isOnline: true,
        imageUrl: "https://picsum.photos/200",
      ),
      title: Text(fullName),
      subtitle: Row(
        children: [
          Text(
            lastMessage,
            style: TextStyle(
              color: isDelivered ? Colors.black : Colors.grey,
              fontWeight: isDelivered ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(
              width:
                  8), // Add some spacing between the message and delivery status
          if (isDelivered)
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 16,
            ),
          if (!isDelivered)
            const Icon(
              Icons.check_circle_outline,
              color: Colors.grey,
              size: 16,
            ),
        ],
      ),
    );
  }

  Widget ChatIcon({required bool isOnline, required String imageUrl}) {
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
      ],
    );
  }
}

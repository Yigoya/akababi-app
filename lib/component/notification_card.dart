import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;

  const NotificationCard({Key? key, required this.notification})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract data from the notification map
    String message = notification['message'];
    String fullName = notification['full_name'];
    String timeAgo = notification['timeAge'];
    bool isRead = notification['is_read'];
    String? profilePicture = notification['profile_picture'];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Picture
          CircleAvatar(
            radius: 25,
            backgroundImage: profilePicture != null
                ? NetworkImage('${AuthRepo.SERVER}/$profilePicture')
                : const AssetImage('assets/image/defaultprofile.png')
                    as ImageProvider,
            backgroundColor: Colors.grey.shade200,
          ),
          const SizedBox(width: 12),
          // Notification Message and Time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      TextSpan(
                        text: ' $message',
                        style: const TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  timeAgo,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Read Indicator
          if (!isRead)
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}

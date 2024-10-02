import 'package:akababi/component/follow_button.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:flutter/material.dart';

class ProfileWithDistance extends StatelessWidget {
  final Map<String, dynamic> people;

  ProfileWithDistance({
    required this.people,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Image part
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: NetworkImage(
                people['profile_picture'] != null
                    ? '${AuthRepo.SERVER}/${people['profile_picture']}'
                    : 'https://images.pexels.com/photos/771742/pexels-photo-771742.jpeg?auto=compress&cs=tinysrgb&w=600',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Distance in top right corner
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            color: Colors.grey.withOpacity(0.7),
            child: Text(
              people['distance'] != 0
                  ? '${people['distance']} km'
                  : 'Right Here',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        // Bottom information (Name + Follow)
        Positioned(
          bottom: 8,
          left: 8,
          right: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Name
              Text(
                people['full_name'],
                style: TextStyle(color: Colors.white),
              ),
              // Follow Button
              FollowButton(
                id: people['id'],
                friendshipStatus: people['friendshipStatus'],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

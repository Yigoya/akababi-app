import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:flutter/material.dart';

class UserFriendsPage extends StatelessWidget {
  final List<Map<String, dynamic>> friends;

  const UserFriendsPage({super.key, required this.friends});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Friends'),
      ),
      body: ListView.builder(
        itemCount: friends.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> friend = friends[index];
          return GestureDetector(
            onTap: () {
              Navigator.of(rootNavigator: true, context)
                  .pushNamed('/userProfile', arguments: friend["id"]);
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: friend["profile_picture"] != null
                    ? NetworkImage(
                        '${AuthRepo.SERVER}/' + friend["profile_picture"])
                    : const NetworkImage('https://source.unsplash.com/random'),
              ),
              title: Text(friend["full_name"]),
              subtitle: Text(friend["username"]),
            ),
          );
        },
      ),
    );
  }
}

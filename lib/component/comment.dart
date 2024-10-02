import 'package:flutter/material.dart';

class PostHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage:
                NetworkImage('https://example.com/user-profile.jpg'),
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'John Joe',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Today is a great day look the sun shine'),
            ],
          ),
          Spacer(),
          ElevatedButton(
            onPressed: () {},
            child: Text('Follow'),
          ),
        ],
      ),
    );
  }
}

class CommentInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Write a comment',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              // Handle send comment
            },
          ),
        ],
      ),
    );
  }
}

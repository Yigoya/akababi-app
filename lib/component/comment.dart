import 'package:flutter/material.dart';

class PostHeader extends StatelessWidget {
  const PostHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundImage:
                NetworkImage('https://example.com/user-profile.jpg'),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'John Joe',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Today is a great day look the sun shine'),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Follow'),
          ),
        ],
      ),
    );
  }
}

class CommentInput extends StatelessWidget {
  const CommentInput({super.key});

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
            icon: const Icon(Icons.send),
            onPressed: () {
              // Handle send comment
            },
          ),
        ],
      ),
    );
  }
}

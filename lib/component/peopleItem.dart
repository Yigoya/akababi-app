import 'dart:ffi';

import 'package:akababi/pages/profile/UserProfile.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class PeopleItem extends StatefulWidget {
  final Map<String, dynamic> data;
  const PeopleItem({super.key, required this.data});

  @override
  State<PeopleItem> createState() => _PeopleItemState();
}

class _PeopleItemState extends State<PeopleItem> {
  final logger = Logger();
  @override
  Widget build(BuildContext context) {
    var imageUrl = widget.data['profile_picture'] ??
        'uploads/image/183be109c77b089a72a693d8fd9e91ef-1000033241.jpg';
    return GestureDetector(
      onTap: () {
        logger.d(widget.data);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UserProfile(
                      id: widget.data['id'],
                    )));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey),
        ),
        child: Column(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage('${AuthRepo.SERVER}/${imageUrl}'),
                      onError: (exception, stackTrace) {
                        setState(() {
                          imageUrl =
                              'uploads/image/183be109c77b089a72a693d8fd9e91ef-1000033241.jpg';
                        });
                      })),
            ),
            Column(
              children: [
                Text(widget.data['first_name']),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('@${widget.data['username']}'),
                    SizedBox(
                      width: 10,
                    ),
                    Text("data")
                  ],
                )
              ],
            ),
            GestureDetector(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4), color: Colors.red),
                child: Text(
                  'Follow',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

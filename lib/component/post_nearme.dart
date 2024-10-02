import 'package:akababi/component/follow_button.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:flutter/material.dart';

class PostNearMe extends StatelessWidget {
  final Map<String, dynamic> post;

  PostNearMe({
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Image part
        post['media'] != null
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: NetworkImage(
                      '${AuthRepo.SERVER}/${post['media']}',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey,
                ),
              ),
        // Distance in top right corner
        if (post['media_type'] == 'video')
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
          )
        else
          Container(),
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
                post['full_name'],
                style: TextStyle(color: Colors.white),
              ),
              // Follow Button
              Text(
                post['distance'] != 0 ? '${post['distance']} km' : 'Right Here',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

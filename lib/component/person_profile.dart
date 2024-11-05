import 'package:akababi/bloc/cubit/person_cubit.dart';
import 'package:akababi/bloc/cubit/post_cubit.dart';
import 'package:akababi/component/follow_button.dart';
import 'package:akababi/component/post_follow_button.dart';
import 'package:akababi/pages/profile/PersonProfile.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileWithFollow extends StatelessWidget {
  final Map<String, dynamic> person;
  final bool? fromProfile;

  const ProfileWithFollow({super.key, required this.person, this.fromProfile});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PersonPage(id: person['id'])));
      },
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[300]),
            width: 250,
            height: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Profile image
                ClipOval(
                  child: Image.network(
                    '${AuthRepo.SERVER}/${person["profile_picture"]}',
                    width: 180, // Circle size
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/image/defaultprofile.png',
                        width: 180, // Circle size
                        height: 180,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  person['full_name'],
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w500),
                ),
                Text(
                  '@${person['username']}',
                  style: TextStyle(fontSize: 18, color: Colors.grey[800]),
                ),
                const SizedBox(height: 4),
                PostFollowButton(
                    friendshipStatus: person['friendshipStatus'],
                    id: person['id'])
                // Follow Button
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                if (fromProfile == true) {
                  BlocProvider.of<PersonCubit>(context)
                      .removeRecommendedPeople(person['id']);
                } else {
                  BlocProvider.of<PostCubit>(context)
                      .removePersonFromList(person['id']);
                }
              },
              child: Icon(
                Icons.close,
                color: Colors.black,
              ),
            ),
          )
        ],
      ),
    );
  }
}

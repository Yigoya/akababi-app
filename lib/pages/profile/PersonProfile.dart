import 'package:akababi/bloc/cubit/person_cubit.dart';
import 'package:akababi/component/PostItem.dart';
import 'package:akababi/component/follow_button.dart';
import 'package:akababi/component/person_profile.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:logger/logger.dart';

class PersonPage extends StatefulWidget {
  final int id;

  const PersonPage({super.key, required this.id});

  @override
  State<PersonPage> createState() => _PersonPageState();
}

class _PersonPageState extends State<PersonPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<PersonCubit>(context).getPepoleById(widget.id);
    return Scaffold(
      body: SingleChildScrollView(
        child: BlocBuilder<PersonCubit, PersonState>(
          builder: (context, state) {
            if (state is PersonLoading) {
              return const SizedBox(
                height: 600,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (state is PersonLoaded) {
              final userProfile = state.person;
              Logger().d(userProfile);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  Stack(
                    children: [
                      Image.network(
                        '${AuthRepo.SERVER}/${userProfile["profile_picture"]}',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 400,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 400,
                            color: Colors.grey,
                            child: Center(
                              child: Text(
                                "no profile image",
                                style: TextStyle(
                                    color: Colors.grey[800], fontSize: 24),
                              ),
                            ),
                          );
                        },
                      ),
                      Positioned(
                          top: 0,
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                  Colors.black.withOpacity(0.4),
                                  Colors.transparent,
                                  Colors.transparent,
                                  Colors.transparent,
                                ])),
                          )),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${userProfile["full_name"]}',
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            Text(
                              '@${userProfile["username"]}',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey[100]),
                            )
                          ],
                        ),
                      ),
                      userProfile['distance'] != null
                          ? Positioned(
                              bottom: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  userProfile['distance'] == 0
                                      ? 'Right Here'
                                      : '${userProfile["distance"]} km',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            '${userProfile["followers"]} followers • ${userProfile["following"]} following',
                            style: const TextStyle(fontSize: 16)),
                        userProfile["bio"] != null
                            ? const SizedBox(height: 10)
                            : const SizedBox.shrink(),
                        Text(userProfile["bio"] ?? ''),
                        userProfile["location_name"] != null
                            ? const SizedBox(height: 10)
                            : const SizedBox.shrink(),
                        Text(userProfile['location_name'] ?? ''),
                        Row(
                          children: [
                            FollowButton(
                                id: userProfile['id'],
                                friendshipStatus:
                                    userProfile["friendshipStatus"]),
                            IconButton(
                              icon: const Icon(FeatherIcons.link2),
                              onPressed: () {},
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  // Suggested People Section
                  state.recommendedPeople.length != 0
                      ? Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Suggested people for you'),
                                  TextButton(
                                      onPressed: () {},
                                      child: const Text('See all')),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 300,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: state.recommendedPeople.length,
                                itemBuilder: (context, index) {
                                  final person = state.recommendedPeople[index];
                                  return ProfileWithFollow(
                                      person: person, fromProfile: true);
                                },
                              ),
                            ),
                            const Divider(),
                          ],
                        )
                      : const SizedBox.shrink(),

                  // Posts Section
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: userProfile["posts"].length,
                    itemBuilder: (context, index) {
                      final post = userProfile["posts"][index];
                      return PostItem(post: post);
                    },
                  ),
                ],
              );
            } else {
              return const Center(
                child: Text('Failed to fetch user profile'),
              );
            }
          },
        ),
      ),
    );
  }
}

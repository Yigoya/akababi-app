import 'dart:math';

import 'package:akababi/bloc/auth/auth_bloc.dart';
import 'package:akababi/bloc/auth/auth_event.dart';
import 'package:akababi/bloc/cubit/notification_cubit.dart';
import 'package:akababi/bloc/cubit/post_cubit.dart';
import 'package:akababi/component/comment.dart';
import 'package:akababi/component/person_profile.dart';
import 'package:akababi/pages/search/SearchPage.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:akababi/skeleton/postItemSkeleton.dart';
import 'package:akababi/utility.dart';
import 'package:flutter/material.dart';
import 'package:akababi/component/PostItem.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final bool _showAppBar = true;

  final authRepo = AuthRepo();
  String userFullName = '';
  Future<void> checkExist() async {
    final authRepo = AuthRepo();
    final user = await authRepo.user;
    if (user == null) {
      Navigator.of(context, rootNavigator: true).pushNamed('/login');
    }
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollListener);
    init();
  }

  void init() async {
    await BlocProvider.of<PostCubit>(context).getFeed(context);

    BlocProvider.of<NotificationCubit>(context).getNotifications();
  }

  void scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 100) {
      // Trigger your function when near the end
      print('Near the end of the scroll');
      BlocProvider.of<PostCubit>(context).getScrollFeed(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[400],
      appBar: AppBar(
        title: Text(
          "Akababi",
          style: GoogleFonts.kodchasan(
            textStyle: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w500,
                color: Color.fromARGB(255, 199, 47, 93)),
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SearchPage()));
              },
              icon: const Icon(FeatherIcons.search)),
          Stack(
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true)
                        .pushNamed("/notification");
                  },
                  icon: const Icon(FeatherIcons.bell)),
              BlocBuilder<NotificationCubit, NotificationState>(
                builder: (context, state) {
                  if (state is NotificationLoaded) {
                    final numOfUnreadNotification =
                        state.numOfUnreadNotification;
                    if (numOfUnreadNotification == 0) {
                      return Container();
                    }

                    return Positioned(
                      right: 10,
                      top: 3,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                        child: Text(
                          numOfUnreadNotification.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }
                  return Container();
                },
              )
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          BlocProvider.of<PostCubit>(context).getFeed(context);
        },
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: [
              BlocBuilder<PostCubit, PostState>(
                builder: (context, state) {
                  if (state is PostLoading) {
                    return const Column(
                        children: [PostItemSkeleton(), PostItemSkeleton()]);
                  } else if (state is PostLoaded) {
                    var posts = state.posts;
                    final randInt =
                        Random().nextInt(((posts.length / 2) + 1).toInt());
                    if (state.posts.isEmpty) {
                      return Container(
                        height: 560,
                        color: Colors.white,
                        child: Center(
                            child: Text(
                                "No post found yet please go to search or nearme to find people",
                                style: GoogleFonts.kodchasan(
                                  textStyle: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w500,
                                      color: const Color.fromARGB(255, 0, 0, 0)
                                          .withOpacity(0.5)),
                                ))),
                      );
                    }
                    return Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            if (index == 0 &&
                                state.recommendedPeople.isNotEmpty) {
                              return RecommendedPeoples(
                                people: state.recommendedPeople,
                              );
                            }
                            return PostItem(
                              post: posts[index],
                            );
                          },
                        ),
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            "Loading more posts...",
                            style: GoogleFonts.kodchasan(
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecommendedPeoples extends StatelessWidget {
  final List<Map<String, dynamic>> people;
  const RecommendedPeoples({super.key, required this.people});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Suggested people for you',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    pageController.jumpToTab(1);
                  },
                  child: const Text(
                    'See all',
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 300,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: people.length,
              itemBuilder: (context, index) {
                return ProfileWithFollow(
                  person: people[index],
                );
              },
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}

class RefreashFeed extends StatefulWidget {
  const RefreashFeed({
    super.key,
  });

  @override
  State<RefreashFeed> createState() => _RefreashFeedState();
}

class _RefreashFeedState extends State<RefreashFeed> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline,
              color: Color.fromARGB(255, 228, 63, 113), size: 60),
          Text("You're all caught up",
              style: TextStyle(
                  fontSize: 25,
                  color: const Color.fromARGB(255, 0, 0, 0).withOpacity(1))),
          Text(
              "You have seen all new post from your area and friends from the past ${(feedIndex == -1 ? 1 : feedIndex + 1) * 7} days",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20,
                  color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5))),
          GestureDetector(
            onTap: () {
              scrollToTop();
              BlocProvider.of<PostCubit>(context)
                  .getFeed(context, refreach: true);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 228, 63, 113),
                  borderRadius: BorderRadius.circular(20)),
              child: const Text("Refresh",
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w500)),
            ),
          )
        ],
      ),
    );
  }
}
//  Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppHeader(context, "Feed"),
//         body: SingleChildScrollView(
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text("data"),
//                         Row(
//                           children: [
//                             Text("visibility"),
//                             SizedBox(
//                                 height: 20,
//                                 width: 30,
//                                 child: FittedBox(
//                                     fit: BoxFit.fill,
//                                     child:
//                                         Switch(value: true, onChanged: (_) {})))
//                           ],
//                         ),
//                       ],
//                     ),
//                     Text("data"),
//                   ],
//                 ),
//               ),
//               PostItem(),
//               // PeopleItem(),
//               ChatIcon(
//                 isOnline: true,
//                 imageUrl: "https://picsum.photos/200",
//                 username: "yigo",
//               ),
//               ChatListItem(
//                   fullName: "Yigermal Abebe",
//                   lastMessage: "lastMessage for remainber",
//                   isDelivered: true),
//               Text("Welcome",
//                   style: TextStyle(color: Colors.deepOrange, fontSize: 30)),
//               ElevatedButton(
//                   onPressed: () async {
//                     BlocProvider.of<AuthBloc>(context).add(GetLocationEvent());
//                   },
//                   child: Text('get location')),
//             ],
//           ),
//         ));
//   }

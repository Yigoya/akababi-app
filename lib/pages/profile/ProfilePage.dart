import 'dart:io';
import 'package:akababi/pages/profile/EditProfile.dart';
import 'package:akababi/pages/profile/UserFriends.dart';
import 'package:akababi/pages/profile/cubit/picture_cubit.dart';
import 'package:akababi/pages/profile/cubit/profile_cubit.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:akababi/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late TabController tabController;
  @override
  void initState() {
    tabController = TabController(length: 4, vsync: this);
    tabController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  void generateLinkAndShare(int id) {
    // Generate your text here
    String textToShare = "https://api1.myakababi.com/user/$id";

    // Share the text
    Share.share(textToShare);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Profile'),
          actions: [
            IconButton(
                onPressed: () {
                  BlocProvider.of<ProfileCubit>(context).getUser();
                },
                icon: const Icon(Icons.refresh)),
            // IconButton(
            //     onPressed: () {
            //       Navigator.of(context, rootNavigator: true).push(
            //           MaterialPageRoute(builder: (context) => UserProfile()));
            //     },
            //     icon: Icon(Icons.mode_edit)),
            IconButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true)
                      .pushNamed('/setting');
                },
                icon: const Icon(Icons.settings)),
          ],
        ),
        body: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                BlocConsumer<PictureCubit, PictureState>(
                    builder: ((context, state) {
                      if (state is PictureLoaded) {
                        return ClipOval(
                            child: Image.file(
                          File(state.imagePath),
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ));
                      } else if (state is PictureEmpty) {
                        if (state.imagePath != '') {
                          return ClipOval(
                              child: Image(
                            image: NetworkImage(
                                "${AuthRepo.SERVER}/${state.imagePath}"),
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          ));
                        }
                        return ClipOval(
                          child: IconButton(
                            onPressed: () {
                              BlocProvider.of<PictureCubit>(context).setImage();
                            },
                            icon: Container(
                              decoration:
                                  const BoxDecoration(color: Colors.black),
                              child: const Icon(
                                Icons.person,
                                size: 150,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      } else {
                        return const Center(
                          child: Text("loading ..."),
                        );
                      }
                    }),
                    listener: ((context, state) {})),
                BlocConsumer<ProfileCubit, ProfileState>(
                    builder: ((context, state) {
                      if (state is ProfileLoaded) {
                        return Column(
                          children: [
                            Text(
                              state.user.fullname,
                              style: const TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '@${state.user.username}',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                                IconButton(
                                    onPressed: () =>
                                        generateLinkAndShare(state.user.id),
                                    icon: const Icon(Icons.share))
                              ],
                            ),
                            BlocBuilder<ProfileCubit, ProfileState>(
                              builder: (context, state) {
                                if (state is ProfileLoaded) {
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          const Text("Posts"),
                                          Text('${state.posts.length}')
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .push(MaterialPageRoute(
                                                  builder: (_) =>
                                                      UserFriendsPage(
                                                        friends: state.friends,
                                                      )));
                                        },
                                        child: Column(
                                          children: [
                                            const Text("Match"),
                                            Text('${state.friends.length}')
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  return const Center(child: Text("No Posts"));
                                }
                              },
                            ),
                            fillInComplete(state.user.bio,
                                "add bio for your profile", 'bio'),
                            fillInComplete(
                                state.user.phonenumber,
                                "add Phone Number for your profile",
                                'phonenumber'),
                            fillInComplete(
                                state.user.date_of_birth,
                                "add User birth Day for your profile",
                                'birthday'),
                            const SizedBox(
                              height: 20,
                            ),
                            TabBar(
                              controller: tabController,
                              tabs: const [
                                Tab(text: 'Posts'),
                                Tab(text: 'Liked'),
                                Tab(text: 'Reposts'),
                                Tab(text: 'Saved'),
                              ],
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 400,
                              child: TabBarView(
                                controller: tabController,
                                children: [
                                  // Posts Page
                                  BlocBuilder<ProfileCubit, ProfileState>(
                                    builder: (context, state) {
                                      if (state is ProfileLoaded) {
                                        if (state.posts.isEmpty) {
                                          return const Center(
                                              child: Text("No Posts"));
                                        }
                                        return GridView.builder(
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            crossAxisSpacing: 10,
                                            mainAxisSpacing: 10,
                                          ),
                                          itemCount: state.posts.length,
                                          itemBuilder: (context, index) {
                                            final post = state.posts[index];

                                            return listItem(context, post);
                                          },
                                        );
                                      } else {
                                        return const Center(
                                            child: Text("No Posts"));
                                      }
                                    },
                                  ),
                                  // Container(
                                  //   color: Colors.amberAccent,
                                  //   child: Center(
                                  //     child: Text('Posts Page'),
                                  //   ),
                                  // ),
                                  // Liked Page
                                  BlocBuilder<ProfileCubit, ProfileState>(
                                    builder: (context, state) {
                                      if (state is ProfileLoaded) {
                                        if (state.likedPosts.isEmpty) {
                                          return const Center(
                                            child: Text("No Liked Posts"),
                                          );
                                        }
                                        return GridView.builder(
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            crossAxisSpacing: 10,
                                            mainAxisSpacing: 10,
                                          ),
                                          itemCount: state.likedPosts.length,
                                          itemBuilder: (context, index) {
                                            final post =
                                                state.likedPosts[index];
                                            Map<String, dynamic> media =
                                                decodeMedia(post['media']);
                                            var isVideo =
                                                media['video'] != null;
                                            var imagePath = isVideo
                                                ? media['thumbnail']
                                                : media['image'];
                                            return listItem(context, post);
                                          },
                                        );
                                      } else {
                                        return const Center(
                                            child: Text("No Liked Posts"));
                                      }
                                    },
                                  ),
                                  BlocBuilder<ProfileCubit, ProfileState>(
                                    builder: (context, state) {
                                      if (state is ProfileLoaded) {
                                        if (state.reposted.isEmpty) {
                                          return const Center(
                                              child: Text("No Reposts"));
                                        }
                                        return GridView.builder(
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            crossAxisSpacing: 10,
                                            mainAxisSpacing: 10,
                                          ),
                                          itemCount: state.reposted.length,
                                          itemBuilder: (context, index) {
                                            final repost =
                                                state.reposted[index];

                                            return listItem(
                                                context, repost["post"],
                                                isRepost: true,
                                                rePostId: repost["id"]);
                                          },
                                        );
                                      } else {
                                        return const Center(
                                            child: Text("No Reposts"));
                                      }
                                    },
                                  ),
                                  BlocBuilder<ProfileCubit, ProfileState>(
                                    builder: (context, state) {
                                      if (state is ProfileLoaded) {
                                        if (state.saved.isEmpty) {
                                          return const Center(
                                              child: Text("No Saved Posts"));
                                        }
                                        return GridView.builder(
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            crossAxisSpacing: 10,
                                            mainAxisSpacing: 10,
                                          ),
                                          itemCount: state.saved.length,
                                          itemBuilder: (context, index) {
                                            final saved = state.saved[index];
                                            print(saved.length);
                                            return listItem(
                                                context, saved['post']);
                                          },
                                        );
                                      } else {
                                        return const Center(
                                            child: Text("No Saved Posts"));
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      } else if (state is PictureEmpty) {
                        return const Center(
                          child: Text("no picture"),
                        );
                      } else {
                        return const Center(
                          child: Text("loading ..."),
                        );
                      }
                    }),
                    listener: ((context, state) {})),
                // ElevatedButton(
                //     onPressed: () {
                //       BlocProvider.of<PictureCubit>(context).setImage();
                //     },
                //     child: Text("upload")),
                // ElevatedButton(
                //     onPressed: () async {
                //       final pref = await SharedPreferences.getInstance();
                //       pref.remove('imagePath');
                //     },
                //     child: Text("delete image"))
              ],
            ),
          ),
        ));
  }

  Widget fillInComplete(String? vary, String text, String name) {
    return vary == ''
        ? GestureDetector(
            onTap: () {
              Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                  builder: (_) => EditProfile(
                        name: name,
                      )));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amberAccent)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                        color: Color.fromARGB(255, 95, 75, 15), fontSize: 20),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_right_sharp,
                    size: 30,
                  )
                ],
              ),
            ),
          )
        : Container();
  }

  // @override
  // void dispose() {
  //   picture
  //   super.dispose();

  // }
}



// BlocBuilder<AuthBloc, AuthState>(
//           builder: (context, state) {
//             print(state.user);
//             return Container(
//               child: Center(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.max,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     SizedBox(
//                       height: 100,
//                     ),
//                     state.user != null && state.user!.profile_picture != null
//                         ? ClipOval(
//                             child: Image.network(
//                               '${AuthRepo.SERVER}/files/${state.user!.profile_picture}',
//                               width: 200,
//                               height: 200,
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) =>
//                                   IconButton(
//                                       onPressed: () {
//                                         authBloc.add(ProfileEvent(context));
//                                       },
//                                       icon: Icon(
//                                         Icons.image,
//                                         size: 50,
//                                       )),
//                             ),
//                           )
//                         : IconButton(
//                             onPressed: () {
//                               authBloc.add(ProfileEvent(context));
//                             },
//                             icon: Icon(
//                               Icons.image,
//                               size: 50,
//                             )),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     Text(
//                       state.user!.fullname,
//                       style:
//                           TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
//                     ),
//                     Text(
//                       '@${state.user!.username}',
//                       style:
//                           TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
//                     ),
//                     ElevatedButton(
//                         onPressed: () {
//                           authBloc.add(LogOutEvent(context));
//                         },
//                         child: Text('Log Out'))
//                   ],
//                 ),
//               ),
//             );
//           },
//         )

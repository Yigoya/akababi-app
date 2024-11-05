import 'dart:io';
import 'package:akababi/bloc/auth/auth_bloc.dart';
import 'package:akababi/bloc/auth/auth_event.dart';
import 'package:akababi/bloc/cubit/post_cubit.dart';
import 'package:akababi/component/PostItem.dart';
import 'package:akababi/pages/profile/cubit/picture_cubit.dart';
import 'package:akababi/pages/profile/cubit/profile_cubit.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late TabController tabController;
  ScrollController scrollController = ScrollController();
  bool _switchValue = true;

  @override
  void initState() {
    tabController = TabController(length: 4, vsync: this);
    super.initState();

    // Listen to the scroll changes of the entire page
    scrollController.addListener(() {
      // If user scrolls to the top of the list, the profile header will show
      if (scrollController.position.atEdge &&
          scrollController.position.pixels == 0) {
        print("Reached top");
      }
    });
    init();
  }

  void init() async {
    final pref = await SharedPreferences.getInstance();
    bool location = pref.getBool('location') ?? true;

    BlocProvider.of<AuthBloc>(context)
        .add(GetLocationEvent(context: context, value: location));
    setState(() {
      _switchValue = location;
    });
  }

  void generateLinkAndShare(int id) {
    String textToShare = "https://api1.myakababi.com/user/$id";
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
          IconButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true)
                    .pushNamed('/setting');
              },
              icon: const Icon(Icons.settings)),
        ],
      ),
      body: NestedScrollView(
        controller: scrollController, // Attach controller here
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: _buildProfileHeader(context),
            ),
          ];
        },
        body: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  _buildPostTab(context),
                  _buildLikedTab(context),
                  _buildRepostTab(context),
                  _buildSavedTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return BlocConsumer<PictureCubit, PictureState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                      child: Text(
                          "By toggling the switch control your locationvisibility in the app")),
                  SizedBox(
                    height: 35,
                    width: 45,
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child: Switch(
                          value: _switchValue,
                          onChanged: (newValue) {
                            if (newValue) {
                              BlocProvider.of<AuthBloc>(context).add(
                                  GetLocationEvent(
                                      context: context, value: true));
                            } else {
                              BlocProvider.of<AuthBloc>(context).add(
                                  GetLocationEvent(
                                      context: context, value: false));
                            }
                            setState(() {
                              _switchValue = newValue;
                            });
                          }),
                    ),
                  ),
                ],
              ),
              if (state is PictureLoaded)
                Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.file(
                          File(state.imagePath),
                          width: 160,
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                        bottom: 1,
                        right: 1,
                        child: IconButton(
                            onPressed: () {
                              BlocProvider.of<PictureCubit>(context).setImage();
                            },
                            icon: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.camera))))
                  ],
                )
              else if (state is PictureLoadedInternet)
                Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          "${AuthRepo.SERVER}/${state.imageUrl}",
                          width: 160,
                          height: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return ClipOval(
                              child: IconButton(
                                onPressed: () {
                                  BlocProvider.of<PictureCubit>(context)
                                      .setImage();
                                },
                                icon: Container(
                                  decoration:
                                      const BoxDecoration(color: Colors.black),
                                  child: const Icon(
                                    Icons.person,
                                    size: 120,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                        bottom: 1,
                        right: 1,
                        child: IconButton(
                            onPressed: () {
                              BlocProvider.of<PictureCubit>(context).setImage();
                            },
                            icon: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.camera))))
                  ],
                )
              else if (state is PictureEmpty)
                ClipOval(
                  child: IconButton(
                    onPressed: () {
                      BlocProvider.of<PictureCubit>(context).setImage();
                    },
                    icon: Container(
                      decoration: const BoxDecoration(color: Colors.black),
                      child: const Icon(
                        Icons.person,
                        size: 120,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              else
                const CircularProgressIndicator(),
              const SizedBox(height: 10),
              _buildProfileInfo(context),
            ],
          ),
        );
      },
      listener: (context, state) {},
    );
  }

  Widget _buildProfileInfo(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded) {
          return Column(
            children: [
              Text(
                state.user.fullname,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '@${state.user.username}',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  IconButton(
                    onPressed: () => generateLinkAndShare(state.user.id),
                    icon: const Icon(Icons.share, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildProfileStats("Posts", state.posts.length),
                  _buildProfileStats("Friends", state.friends.length),
                ],
              ),
            ],
          );
        } else {
          return const Text("Loading profile...");
        }
      },
      listener: (context, state) {},
    );
  }

  Widget _buildProfileStats(String title, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text('$count',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: tabController,
      tabs: const [
        Tab(text: 'Posts'),
        Tab(text: 'Liked'),
        Tab(text: 'Reposts'),
        Tab(text: 'Saved'),
      ],
    );
  }

  Widget _buildPostTab(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded && state.posts.isNotEmpty) {
          return ListView.builder(
            itemCount: state.posts.length,
            itemBuilder: (context, index) {
              final post = state.posts[index];
              return PostItem(post: post);
            },
          );
        } else {
          return const Center(child: Text("No posts available"));
        }
      },
    );
  }

  Widget _buildLikedTab(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded && state.likedPosts.isNotEmpty) {
          return ListView.builder(
            itemCount: state.likedPosts.length,
            itemBuilder: (context, index) {
              final post = state.likedPosts[index];
              return PostItem(post: post);
            },
          );
        } else {
          return const Center(child: Text("No liked posts"));
        }
      },
    );
  }

  Widget _buildRepostTab(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded && state.reposted.isNotEmpty) {
          return ListView.builder(
            itemCount: state.reposted.length,
            itemBuilder: (context, index) {
              final post = state.reposted[index];
              return PostItem(post: post);
            },
          );
        } else {
          return const Center(child: Text("No reposts available"));
        }
      },
    );
  }

  Widget _buildSavedTab(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded && state.saved.isNotEmpty) {
          return ListView.builder(
            itemCount: state.reposted.length,
            itemBuilder: (context, index) {
              final post = state.reposted[index];
              return PostItem(post: post);
            },
          );
        } else {
          return const Center(child: Text("No saved posts available"));
        }
      },
    );
  }
}

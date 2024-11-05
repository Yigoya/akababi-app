import 'package:akababi/bloc/cubit/people_cubit.dart';
import 'package:akababi/component/person_nearme.dart';
import 'package:akababi/component/post_nearme.dart';
import 'package:akababi/pages/Nearme/nearme_people_scroll.dart';
import 'package:akababi/pages/Nearme/nearme_post_scroll.dart';
import 'package:akababi/skeleton/PeopleItemSkeleton.dart';
import 'package:akababi/skeleton/postItemSkeleton.dart';
import 'package:akababi/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class NearMePage extends StatefulWidget {
  NearMePage({super.key});

  @override
  State<NearMePage> createState() => _NearMePageState();
}

class _NearMePageState extends State<NearMePage> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    final location = await getCurrentLocation(context);
    print(location);
    if (location == null) {
      showLocationServiceDialog(context);
    } else {
      BlocProvider.of<PeopleCubit>(context).getNearMe(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            const SliverAppBar(
              title: Text('Near Me'),
              pinned: true,
              floating: true,
              bottom: TabBar(
                tabAlignment: TabAlignment.fill,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  Tab(child: Text('People')),
                  Tab(child: Text('Event')),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          children: <Widget>[
            RefreshIndicator(
              onRefresh: () async {
                BlocProvider.of<PeopleCubit>(context).getNearMe(context);
              },
              child: BlocConsumer<PeopleCubit, PeopleState>(
                builder: (contex, state) {
                  if (state is PeopleLoaded) {
                    var peoples = state.peoples;
                    peoples = peoples.map((item) {
                      var res = item;
                      return res;
                    }).toList();
                    print(peoples);
                    if (peoples.isEmpty) {
                      return Center(
                        child: Text('No People Found',
                            style: GoogleFonts.kodchasan(
                              textStyle: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w500,
                                  color: const Color.fromARGB(255, 0, 0, 0)
                                      .withOpacity(0.5)),
                            )),
                      );
                    }
                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.7,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: peoples.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ScrollPeoplePage(
                                          startIndex: index,
                                        )));
                          },
                          child: ProfileWithDistance(
                            people: peoples[index],
                          ),
                        );
                      },
                    );
                  } else {
                    return ListView(children: const [
                      PeopleItemSkeleton(),
                      PeopleItemSkeleton(),
                    ]);
                  }
                },
                listener: (contex, state) {},
              ),
            ),
            RefreshIndicator(
              onRefresh: () async {
                BlocProvider.of<PeopleCubit>(context).getNearMe(context);
              },
              child: BlocBuilder<PeopleCubit, PeopleState>(
                builder: (context, state) {
                  if (state is PeopleLoading) {
                    return ListView(children: const [
                      PostItemSkeleton(),
                      PostItemSkeleton()
                    ]);
                  } else if (state is PeopleLoaded) {
                    var posts = state.posts;
                    if (posts.isEmpty) {
                      return Center(
                        child: Text('No Post Found',
                            style: GoogleFonts.kodchasan(
                              textStyle: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w500,
                                  color: const Color.fromARGB(255, 0, 0, 0)
                                      .withOpacity(0.5)),
                            )),
                      );
                    }
                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.7,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ScrollPostPage(
                                          startIndex: index,
                                        )));
                          },
                          child: PostNearMe(
                            post: posts[index],
                          ),
                        );
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ],
        ),
      )),
    );
  }

  List<int> items = [1, 2, 3, 4, 5];

  Map<String, dynamic> data = {
    'full_name': "yigo abebe",
    'username': "yigo",
    'profile_picture': '1712297387579-1000030378.jpg'
  };
}

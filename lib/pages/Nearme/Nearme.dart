import 'package:akababi/bloc/cubit/post_cubit.dart';
import 'package:akababi/component/PostItem.dart';
import 'package:akababi/component/peopleItem.dart';
import 'package:akababi/bloc/cubit/people_cubit.dart';
import 'package:akababi/skeleton/PeopleItemSkeleton.dart';
import 'package:akababi/skeleton/postItemSkeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class NearMePage extends StatelessWidget {
  NearMePage({super.key});

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<PeopleCubit>(context).getPeopleSuggestions(context);
    BlocProvider.of<PostCubit>(context).getFeed(context);
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
                BlocProvider.of<PeopleCubit>(context)
                    .getPeopleSuggestions(context);
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
                    return ListView.builder(
                      itemCount: peoples.length, // total number of items
                      itemBuilder: (context, index) {
                        return PeopleItem(
                          data: peoples[index],
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
                BlocProvider.of<PostCubit>(context).getFeed(context);
              },
              child: BlocBuilder<PostCubit, PostState>(
                builder: (context, state) {
                  if (state is PostLoading) {
                    return ListView(children: const [
                      PostItemSkeleton(),
                      PostItemSkeleton()
                    ]);
                  } else if (state is PostLoaded) {
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
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        return PostItem(
                          post: posts[index],
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

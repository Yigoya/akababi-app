import 'package:akababi/component/Header.dart';
import 'package:akababi/component/PersonContainer.dart';
import 'package:akababi/component/peopleItem.dart';
import 'package:akababi/bloc/cubit/people_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NearMePage extends StatelessWidget {
  NearMePage({super.key});

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<PeopleCubit>(context).printSomeThing();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              title: Text('Tabs Demo'),
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
            BlocConsumer<PeopleCubit, PeopleState>(
              builder: (contex, state) {
                if (state is PeopleLoaded || state is SinglePeopleLoaded) {
                  var peoples = state is PeopleLoaded
                      ? (state as PeopleLoaded).peoples
                      : (state as SinglePeopleLoaded).peoples;
                  peoples = peoples.map((item) {
                    var res = item as Map<String, dynamic>;
                    return res;
                  }).toList();
                  print(peoples);
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 0.9,
                      crossAxisCount: 2, // number of items in each row
                      mainAxisSpacing: 2.0, // spacing between rows
                      crossAxisSpacing: 8.0, // spacing between columns
                    ),
                    itemCount: peoples.length, // total number of items
                    itemBuilder: (context, index) {
                      return PeopleItem(
                        data: peoples[index],
                      );
                    },
                  );
                } else {
                  return Text("loading ....");
                }
              },
              listener: (contex, state) {},
            ),
            Text("ewq")
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

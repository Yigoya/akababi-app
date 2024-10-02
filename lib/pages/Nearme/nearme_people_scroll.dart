import 'package:akababi/bloc/cubit/people_cubit.dart';
import 'package:akababi/pages/post/image_view.dart';
import 'package:akababi/pages/post/video_view.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

class ScrollPeoplePage extends StatefulWidget {
  final int startIndex;
  const ScrollPeoplePage({super.key, required this.startIndex});

  @override
  State<ScrollPeoplePage> createState() => _ScrollPeoplePageState();
}

class _ScrollPeoplePageState extends State<ScrollPeoplePage> {
  final PageController _pageController = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PeopleCubit, PeopleState>(
        builder: (context, state) {
          if (state is PeopleLoaded) {
            final contentList = state.peoples.sublist(widget.startIndex);
            return PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical, // Vertical scrolling like TikTok
              itemCount: contentList.length,
              itemBuilder: (context, index) {
                final content = contentList[index];
                return ImageViewingPage(
                    imageUrl: content['profile_picture'] != null
                        ? '${AuthRepo.SERVER}/${content['profile_picture']}'
                        : 'https://images.pexels.com/photos/771742/pexels-photo-771742.jpeg?auto=compress&cs=tinysrgb&w=600',
                    postedBy: content["full_name"],
                    likes: 12);
              },
            );
          } else {
            return Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }
        },
      ),
    );
  }
}

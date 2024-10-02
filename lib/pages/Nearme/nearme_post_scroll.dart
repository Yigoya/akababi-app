import 'package:akababi/bloc/cubit/people_cubit.dart';
import 'package:akababi/pages/post/image_view.dart';
import 'package:akababi/pages/post/video_view.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

class ScrollPostPage extends StatefulWidget {
  final int startIndex;
  const ScrollPostPage({super.key, required this.startIndex});

  @override
  State<ScrollPostPage> createState() => _ScrollPostPageState();
}

class _ScrollPostPageState extends State<ScrollPostPage> {
  final PageController _pageController = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PeopleCubit, PeopleState>(
        builder: (context, state) {
          if (state is PeopleLoaded) {
            final contentList = state.posts.sublist(widget.startIndex);
            return PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical, // Vertical scrolling like TikTok
              itemCount: contentList.length,
              itemBuilder: (context, index) {
                final content = contentList[index];
                if (content['media_type'] == 'image') {
                  return ImageViewingPage(
                      imageUrl: '${AuthRepo.SERVER}/${content['media']}',
                      postedBy: content["full_name"],
                      likes: 12);
                } else if (content['media_type'] == 'video') {
                  return VideoPlayerPage(
                      videoUrl:
                          'https://api1.myakababi.com/uploads/video/dc37d94f87e045153ca956f0b4ceb319-1000026273.mp4',
                      postedBy: content["full_name"],
                      likes: 12);
                } else {
                  return Container();
                }
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

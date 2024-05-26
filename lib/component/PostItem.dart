import 'dart:ui';
import 'dart:convert';
import 'package:akababi/bloc/cubit/post_cubit.dart';
import 'package:akababi/component/Reaction.dart';
import 'package:akababi/pages/post/SinglePostPage.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";
import 'package:video_player/video_player.dart';

class PostItem extends StatefulWidget {
  final Map<String, dynamic> post;
  const PostItem({super.key, required this.post});

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  late VideoPlayerController videoPlayerController;
  late ChewieController chewieController;
  bool isVideoLoaded = false;

  @override
  void initState() {
    super.initState();
    initVideo();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.post['user'] as Map<String, dynamic>;
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(
                                  '${AuthRepo.SERVER}/${user['profile_picture']}',
                                ),
                                fit: BoxFit.cover,
                              ),
                            )),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${user['first_name']} ${user['last_name']}'),
                            Text("@${user['username']}"),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.favorite,
                              color: Colors.red,
                            )),
                        IconButton(
                            onPressed: () {},
                            icon: Icon(FeatherIcons.moreVertical)),
                      ],
                    )
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(widget.post['content']),
              ),
              GestureDetector(
                  onTap: () {
                    Navigator.of(context, rootNavigator: true)
                        .push(MaterialPageRoute(
                            builder: (context) => SinglePostPage(
                                  id: widget.post['id'],
                                )));
                  },
                  child: Media()),
              Container(
                // color: Colors.amber,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text("${widget.post['distance']} km away"),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Reaction(
                          reaction: widget.post['reaction'],
                          id: widget.post['id'],
                          likes: widget.post['likes'],
                        ),
                        Row(
                          children: [
                            IconButton(
                                onPressed: () {}, icon: Icon(Icons.comment)),
                            Text(widget.post['comments'].toString())
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                                onPressed: () {},
                                icon: Icon(FeatherIcons.share2)),
                            Text("data")
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                                onPressed: () {},
                                icon: Icon(FeatherIcons.refreshCw)),
                            Text("data")
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        // Positioned(top: 75, left: 0, child: Media()),
      ],
    );
  }

  void initVideo() async {
    final media = widget.post['media'] as Map<String, dynamic>;
    if (media['video'] != null) {
      print('${AuthRepo.SERVER}/${media['video']}');
      videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse('${AuthRepo.SERVER}/${media['video']}'));

      await videoPlayerController.initialize();
      print("initialication done");
      chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        autoPlay: true,
        looping: true,
      );
      setState(() {
        isVideoLoaded = true;
      });
    }
  }

  Widget Media() {
    if (widget.post['media'] != null) {
      Map<String, dynamic> media = jsonDecode(widget.post['media']);
      if (media['image'] != null) {
        print('${AuthRepo.SERVER}/${media['image']}');
        return Container(
            width: MediaQuery.of(context).size.width,
            height: 400,
            decoration: BoxDecoration(),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.elliptical(24, 16),
                topRight: Radius.elliptical(24, 16),
                bottomLeft: Radius.elliptical(16, 8),
                bottomRight: Radius.elliptical(16, 8),
              ),
              child: Image.network(
                '${AuthRepo.SERVER}/${media['image']}',
                fit: BoxFit.fitWidth,
              ),
            ));
      } else if (media['video'] != null) {
        return isVideoLoaded
            ? Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: AspectRatio(
                  aspectRatio: videoPlayerController.value.aspectRatio,
                  child: Chewie(controller: chewieController),
                ),
              )
            : Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  image: DecorationImage(
                    image: AssetImage('assets/image/profile.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              );
      } else if (media['audio'] != null) {
        return Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              children: [
                Text("Audio"),
              ],
            ));
      }
      return Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          image: DecorationImage(
            image: AssetImage('assets/image/profile.png'),
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    return Container();
  }
}

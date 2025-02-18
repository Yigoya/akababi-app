import 'package:akababi/bloc/cubit/comment_cubit.dart';
import 'package:akababi/bloc/cubit/post_cubit.dart';
import 'package:akababi/bloc/cubit/single_post_cubit.dart';
import 'package:akababi/component/PlayerWidget.dart';
import 'package:akababi/component/comment.dart';
import 'package:akababi/component/commentCard.dart';
import 'package:akababi/component/post_follow_button.dart';
import 'package:akababi/component/replayCard.dart';
import 'package:akababi/model/User.dart';
import 'package:akababi/pages/post/EditPage.dart';
import 'package:akababi/pages/post/ReportPost.dart';
import 'package:akababi/pages/post/SinglePostPage.dart';
import 'package:akababi/pages/post/image_view.dart';
import 'package:akababi/pages/post/video_view.dart';
import 'package:akababi/pages/profile/PersonProfile.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:akababi/utility.dart';
import 'package:chewie/chewie.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:video_player/video_player.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';

class PostItem extends StatefulWidget {
  final Map<String, dynamic> post;
  final bool? isSinglePost;
  const PostItem({super.key, required this.post, this.isSinglePost});

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;
  bool isVideoLoaded = false;
  AudioPlayer? _audioPlayer;
  double videoRatio = 200;
  User? user0;
  bool liked = false;
  String likes = '';
  bool isContentExpanded = false;
  Map<String, IconData> privacySettingIcons = {
    'public': Icons.public,
    'private': Icons.lock,
    'friends_only': Icons.people,
  };
  @override
  void initState() {
    super.initState();
    init();

    Map<String, dynamic> media = decodeMedia(widget.post['media']);
    if (media['video'] != null) {
      videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse('${AuthRepo.SERVER}/' + media['video']));
      try {
        videoPlayerController!.initialize().then((_) => setState(() {}));
        chewieController = ChewieController(
          videoPlayerController: videoPlayerController!,
          aspectRatio: videoPlayerController!.value.aspectRatio,
          autoPlay: true,
          looping: true,
        );
        setState(() {
          videoRatio = videoPlayerController!.value.aspectRatio;
        });
      } catch (e) {
        print("Error initializing video player: $e");
      }
    }
  }

  Future<void> _initializePlayer(String link) async {
    try {
      await _audioPlayer!.setUrl(link); // Replace with your audio URL
    } catch (e) {
      print("Error initializing audio player: $e");
    }
  }

  void init() async {
    User? u = await AuthRepo().user;
    setState(() {
      user0 = u;
      liked = widget.post['liked'];
      likes = widget.post['likes'] ?? '';
    });
  }

  @override
  void dispose() {
    Map<String, dynamic> media = decodeMedia(widget.post['media']);
    if (media['video'] != null) {
      videoPlayerController!.dispose();
      chewieController!.dispose();
    }
    if (media['audio'] != null) _audioPlayer!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.post['user'] as Map<String, dynamic>;
    Map<String, dynamic>? repostUser = widget.post['repost_user'] != null
        ? widget.post['repost_user'] as Map<String, dynamic>
        : null;

    bool shouldShowSeeMore = widget.post['content'].length > 100;
    return Stack(
      children: [
        Container(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              repostUser != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PersonPage(
                                            id: repostUser['id'],
                                          )));
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                        width: 45,
                                        height: 45,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: repostUser[
                                                        'profile_picture'] !=
                                                    null
                                                ? NetworkImage(
                                                    '${AuthRepo.SERVER}/${repostUser['profile_picture']}',
                                                  ) as ImageProvider
                                                : const AssetImage(
                                                    'assets/image/defaultprofile.png'),
                                            fit: BoxFit.cover,
                                          ),
                                        )),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${repostUser["full_name"]}',
                                          style: GoogleFonts.exo(
                                              textStyle: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w500)),
                                        ),
                                        Text("@${repostUser['username']}",
                                            style: GoogleFonts.exo(
                                                textStyle: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w400))),
                                      ],
                                    ),
                                  ],
                                ),
                                (user0 != null) &&
                                        (widget.post['repost_user_id'] ==
                                            user0!.id)
                                    ? IconButton(
                                        onPressed: () {
                                          showModalBottomSheet(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return BottomSheetContent(
                                                isSinglePost:
                                                    widget.isSinglePost,
                                                post: widget.post,
                                                isRepost: true,
                                              );
                                            },
                                          );
                                        },
                                        icon: const Icon(Icons.more_vert),
                                      )
                                    : const SizedBox.shrink(),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 8),
                          child: Text(widget.post['repost_content'],
                              style: GoogleFonts.spaceGrotesk(
                                  textStyle: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400))),
                        ),
                      ],
                    )
                  : Container(),
              Container(
                padding: const EdgeInsets.only(top: 8),
                margin: repostUser != null ? const EdgeInsets.all(4) : null,
                decoration: repostUser != null
                    ? BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ))
                    : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PersonPage(
                                        id: user['id'],
                                      )));
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                    width: repostUser != null ? 35 : 45,
                                    height: repostUser != null ? 35 : 45,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: user['profile_picture'] != null
                                            ? NetworkImage(
                                                '${AuthRepo.SERVER}/${user['profile_picture']}',
                                              ) as ImageProvider
                                            : const AssetImage(
                                                'assets/image/defaultprofile.png'),
                                        fit: BoxFit.cover,
                                      ),
                                    )),
                                const SizedBox(
                                  width: 5,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${user['full_name']}',
                                      style: GoogleFonts.exo(
                                          textStyle: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          '@${user['username']}', // Timestamp, e.g., '2h ago'
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 4.0),
                                          height: 4.0,
                                          width: 4.0,
                                          decoration: const BoxDecoration(
                                            color: Colors.grey,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        Text(
                                          widget.post[
                                              'timeAgo'], // Timestamp, e.g., '2h ago'
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 4.0),
                                          height: 4.0,
                                          width: 4.0,
                                          decoration: const BoxDecoration(
                                            color: Colors.grey,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        Icon(
                                          privacySettingIcons[
                                              widget.post['privacy_setting']],
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                PostFollowButton(
                                    friendshipStatus: user['friendshipStatus'],
                                    id: user['id'])
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return BottomSheetContent(
                                          isSinglePost: widget.isSinglePost,
                                          post: widget.post,
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(Icons.more_vert),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          // child: Text(widget.post['content'],
                          //     style: GoogleFonts.spaceGrotesk(
                          //         textStyle: const TextStyle(
                          //             fontSize: 18,
                          //             fontWeight: FontWeight.w400))),
                          child: shouldShowSeeMore && !isContentExpanded
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${widget.post['content'].substring(0, 100)}...',
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isContentExpanded =
                                              true; // Expand the text
                                        });
                                      },
                                      child: const Text(
                                        'See more',
                                        style: TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(widget.post['content']),
                                    if (shouldShowSeeMore)
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            isContentExpanded =
                                                false; // Collapse the text
                                          });
                                        },
                                        child: const Text(
                                          'See less',
                                          style: TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                  ],
                                ),
                        ),
                        Stack(
                          children: [
                            GestureDetector(
                                onTap: () {
                                  if (widget.post['media_type'] == 'image') {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ImageViewingPage(
                                                  imageUrl:
                                                      '${AuthRepo.SERVER}/${widget.post['media']}',
                                                )));
                                  } else if (widget.post['media_type'] ==
                                      'video') {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                VideoPlayerPage(
                                                  videoUrl:
                                                      'https://api1.myakababi.com/uploads/video/dc37d94f87e045153ca956f0b4ceb319-1000026273.mp4',
                                                  postedBy: user["full_name"],
                                                  likes: 12,
                                                )));
                                  }
                                },
                                child: Stack(
                                  children: [
                                    Media(),
                                    if (widget.post['media_type'] == 'video')
                                      Positioned(
                                        top: 0,
                                        left: 0,
                                        right: 0,
                                        bottom: 0,
                                        child: Center(
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.black.withOpacity(0.3),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.play_arrow_rounded,
                                              size: 50,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      Container(),
                                  ],
                                )),
                            Positioned(
                              bottom: 10,
                              right: 20,
                              child: widget.post['distance'] != null
                                  ? Container(
                                      margin: const EdgeInsets.only(
                                          left: 16, top: 8),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0, vertical: 4),
                                      decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.3),
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      child: Text(
                                        widget.post['distance'] != 0
                                            ? "${widget.post['distance']} km"
                                            : "Posted Here",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ))
                                  : Container(),
                            )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              likes != '' || widget.post['comment_share'] != null
                  ? GestureDetector(
                      onTap: () {
                        BlocProvider.of<SinglePostCubit>(context)
                            .getReaction(widget.post['post_id']);
                        _showWhoLiked(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            likes != ''
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.favorite_border_outlined,
                                        color: Color.fromARGB(117, 244, 67, 54),
                                        size: 20,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text('$likes liked'),
                                    ],
                                  )
                                : const SizedBox(),
                            Text(widget.post["comment_share"] ?? '')
                          ],
                        ),
                      ),
                    )
                  : const SizedBox(
                      height: 12,
                    ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (liked == true) {
                          BlocProvider.of<PostCubit>(context).setReaction({
                            'post_id': widget.post['post_id'],
                            'reaction_type': null,
                          });
                          setState(() {
                            liked = false;
                            likes = likes.substring(4);
                          });
                        } else {
                          BlocProvider.of<PostCubit>(context).setReaction({
                            'post_id': widget.post['post_id'],
                            'reaction_type': 'like',
                          });
                          setState(() {
                            liked = true;
                            likes = 'you $likes';
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            !liked
                                ? const Icon(
                                    Icons.favorite_border_rounded,
                                    size: 20,
                                  )
                                : const Icon(
                                    Icons.favorite_rounded,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                            const SizedBox(
                              width: 10,
                            ),
                            const Text(
                              "Like",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w400),
                            )
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        BlocProvider.of<CommentCubit>(context)
                            .getComments(widget.post['post_id']);
                        _showComment(context, widget.post['post_id']);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.mode_comment_outlined,
                              size: 20,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Comment',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w400),
                            )
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        generateLinkAndShare(widget.post['post_id']);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: const Row(
                          children: [
                            Icon(
                              FeatherIcons.link,
                              size: 18,
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Text("Share")
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _showRepostDialog(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: const Row(
                          children: [
                            Icon(
                              FluentIcons.share_20_regular,
                              size: 20,
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Text("Repost",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w400))
                          ],
                        ),
                      ),
                    ),
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

  void _showWhoLiked(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the bottom sheet to expand
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
            expand: false, // Ensures it starts at a small height and can expand
            minChildSize:
                0.5, // Minimum size of the bottom sheet (30% of screen height)
            maxChildSize:
                1.0, // Maximum size when expanded to full screen (100% of screen height)
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                child: Column(
                  children: [
                    const Text('Who Liked'),
                    const Divider(),
                    BlocBuilder<SinglePostCubit, SinglePostState>(
                      builder: (context, state) {
                        if (state is SinglePostLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is PostLikesLoaded) {
                          return Expanded(
                            child: ListView.builder(
                              controller: scrollController,
                              itemCount: state.likes.length,
                              itemBuilder: (context, index) {
                                final person = state.likes[index];
                                return ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          '${AuthRepo.SERVER}/${state.likes[index]['profile_picture']}'),
                                    ),
                                    title:
                                        Text(state.likes[index]['full_name']),
                                    subtitle: Text(
                                        '@${person['username']} • following ${person['following']} • followers ${person['followers']}'));
                              },
                            ),
                          );
                        } else
                          return Container();
                      },
                    )
                  ],
                ),
              );
            });
      },
    );
  }

  void _showComment(BuildContext context, int postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the bottom sheet to expand
      builder: (BuildContext context) {
        return CommentSection(
          postId: postId,
        );
      },
    );
  }

  void generateLinkAndShare(int id) {
    // Generate your text here
    String textToShare = "https://api1.myakababi.com/post/$id";

    // Share the text
    Share.share(textToShare);
  }

  Widget Media() {
    if (widget.post['media'] != null) {
      final media = widget.post['media'];
      if (widget.post['media_type'] == 'image' ||
          widget.post['media_type'] == 'video') {
        return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
              minHeight: 200,
            ),
            width: MediaQuery.of(context).size.width,
            child: Image.network(
              '${AuthRepo.SERVER}/${media}',
              fit: BoxFit.fitWidth,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                } else {
                  return Center(
                    child: Image.asset(
                      'assets/image/imageLoading.gif', // Your GIF asset as the placeholder
                      width: 300, // Adjust size as needed
                      height: 300, // Adjust size as needed
                    ),
                  );
                }
              },
              errorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
                return Image.asset(
                  'assets/image/imageError.gif',
                  width: 300, // Adjust size as needed
                  height: 300,
                ); // Provide a local asset as a placeholder
              },
            ));
      } else if (widget.post['media_type'] == 'audio') {
        return AudioPlayerScreen(audioUrl: '${AuthRepo.SERVER}/$media');
      }
      return Container(
        height: 50,
      );
    }
    return Container();
  }

  void _showRepostDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RepostDialog(postId: widget.post['post_id']);
      },
    );
  }
}

class CommentSection extends StatefulWidget {
  final int postId;
  const CommentSection({
    super.key,
    required this.postId,
  });

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection>
    with WidgetsBindingObserver {
  double keyboardHeight = 0.0;
  final controller = TextEditingController();
  bool isEditComment = false;
  bool isReply = false;
  bool isEditReply = false;
  String _replyTo = "John Doe";
  int _repliedUserId = 1;
  int _commentId = 1;
  String? imagePath;
  late int _id;
  final DraggableScrollableController _controller =
      DraggableScrollableController();

  void editComment(int id, String content) {
    controller.text = content;
    setState(() {
      isEditComment = true;
      _id = id;

      isReply = false;
      isEditReply = false;
    });
  }

  void _expandSheet() {
    _controller.animateTo(
      1.0, // Maximum extent
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void editReply(int id, String content, int commentId) {
    controller.text = content;
    setState(() {
      isEditReply = true;
      _id = id;
      _commentId = commentId;

      isEditComment = false;
      isReply = false;
    });
  }

  void setReply(int id, String replyTo, int repliedUserId) {
    setState(() {
      _id = id;
      isReply = true;
      _replyTo = replyTo;
      _repliedUserId = repliedUserId;
      isEditReply = false;
      isEditComment = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _id = widget.postId;
    WidgetsBinding.instance
        .addObserver(this); // Add observer to listen for changes
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    // Use PlatformDispatcher for multi-window support (context-free)
    final bottomInset = WidgetsBinding
        .instance.platformDispatcher.views.first.viewInsets.bottom;

    setState(() {
      keyboardHeight = bottomInset / 1.88; // Update the keyboard height
    });

    print("Keyboard height: $keyboardHeight");
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        controller: _controller,
        snap: true, // Snap the sheet to the nearest snap point
        expand: false, // Ensures it starts at a small height and can expand
        minChildSize:
            0.5, // Minimum size of the bottom sheet (30% of screen height)
        maxChildSize:
            1.0, // Maximum size when expanded to full screen (100% of screen height)
        builder: (BuildContext context, ScrollController scrollController) {
          return Stack(
            children: [
              // Post Header
              Container(
                padding: const EdgeInsets.only(
                  left: 16,
                  top: 24,
                ),
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12))),
                child: Column(
                  children: [
                    const Text('Comments'),
                    const Divider(),
                    // Comments List
                    BlocBuilder<CommentCubit, CommentState>(
                      builder: (context, state) {
                        if (state is CommentLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is CommentLoaded) {
                          return Expanded(
                            child: ListView.builder(
                              controller: scrollController,
                              itemCount: state.comments.length,
                              itemBuilder: (context, index) {
                                return CommentCards(
                                    editComment: editComment,
                                    editReply: editReply,
                                    setReply: setReply,
                                    comment: state.comments[index]);
                              },
                            ),
                          );
                        } else if (state is CommentAdded) {
                          return Expanded(
                            child: ListView.builder(
                              controller: scrollController,
                              itemCount: state.comments.length,
                              itemBuilder: (context, index) {
                                return CommentCards(
                                    editComment: editComment,
                                    editReply: editReply,
                                    setReply: setReply,
                                    comment: state.comments[index]);
                              },
                            ),
                          );
                        } else if (state is ReplyLoaded) {
                          return Expanded(
                            child: ListView.builder(
                              controller: scrollController,
                              itemCount: state.comments.length,
                              itemBuilder: (context, index) {
                                final comment = state.comments[index];
                                Logger().d(state.replies[comment['id']]);
                                return CommentCards(
                                  editComment: editComment,
                                  editReply: editReply,
                                  setReply: setReply,
                                  comment: comment,
                                  replies: state.replies[comment['id']],
                                );
                              },
                            ),
                          );
                        } else if (state is ReplyLoading) {
                          return Expanded(
                            child: ListView.builder(
                              controller: scrollController,
                              itemCount: state.comments.length,
                              itemBuilder: (context, index) {
                                final comment = state.comments[index];
                                Logger().d(state.replies[comment['id']]);
                                return CommentCards(
                                  editComment: editComment,
                                  editReply: editReply,
                                  setReply: setReply,
                                  comment: comment,
                                  replies: state.replies[comment['id']],
                                );
                              },
                            ),
                          );
                        }

                        return Container();
                      },
                    ),
                    const SizedBox(
                      height: 72,
                    )
                  ],
                ),
              ),
              // Comment Input
              Positioned(
                left: 0,
                right: 0,
                bottom: keyboardHeight,
                child: Container(
                  padding: const EdgeInsets.only(left: 16),
                  height: 70,
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onTap: () {
                            _expandSheet();
                          },
                          onChanged: (value) {
                            setState(() {});
                          },
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: isReply
                                ? 'Reply to $_replyTo'
                                : 'Write a comment',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.send,
                          color: controller.text.isEmpty
                              ? Colors.grey
                              : Colors.blue,
                        ),
                        onPressed: controller.text.isEmpty
                            ? null
                            : () {
                                // Handle send comment
                                if (isEditComment) {
                                  BlocProvider.of<CommentCubit>(context)
                                      .updateComment(_id, controller.text);
                                } else if (isReply) {
                                  BlocProvider.of<CommentCubit>(context)
                                      .addReply(
                                          commentId: _id,
                                          content: controller.text,
                                          replyTo: _replyTo,
                                          repliedUserId: _repliedUserId,
                                          imagePath: imagePath);
                                } else if (isEditReply) {
                                  BlocProvider.of<CommentCubit>(context)
                                      .updateReply(
                                          _id, controller.text, _commentId);
                                } else {
                                  BlocProvider.of<CommentCubit>(context)
                                      .addComment(widget.postId,
                                          controller.text, imagePath);
                                }
                                FocusScope.of(context).unfocus();
                                controller.clear();
                                setState(() {
                                  imagePath = null;
                                  isEditComment = false;
                                  isReply = false;
                                  isEditReply = false;
                                  _replyTo = "John Doe";
                                  _repliedUserId = 1;
                                  _commentId = 1;
                                });
                              },
                      ),
                      IconButton(
                        icon: Icon(Icons.image,
                            color:
                                imagePath != null ? Colors.blue : Colors.black),
                        onPressed: () async {
                          // Implement your image upload logic here
                          // For example, you can use the image_picker package to pick an image
                          // and then upload it to your server or cloud storage
                          final pickedFile = await ImagePicker()
                              .pickImage(source: ImageSource.gallery);
                          if (pickedFile != null) {
                            setState(() {
                              imagePath = pickedFile.path;
                            });
                            // Handle image upload
                          }
                        },
                      )
                    ],
                  ),
                ),
              ),
              // Floating Button to Open Bottom Sheet
            ],
          );
        });
  }
}

class RepostDialog extends StatefulWidget {
  final int postId;
  const RepostDialog({super.key, required this.postId});

  @override
  State<RepostDialog> createState() => _RepostDialogState();
}

class _RepostDialogState extends State<RepostDialog> {
  TextEditingController controller = TextEditingController();
  String error = '';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      title: const Text(
        'Repost',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                error,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14.0,
                ),
              ),
            ),
          const Text('Add a caption to your repost',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400)),
          const SizedBox(
            height: 16.0,
          ),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter your caption',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 12.0,
              ),
            ),
            maxLength:
                100, // Optional: Add a max length to limit the caption size
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close dialog on cancel
          },
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: isLoading
              ? null
              : () async {
                  if (controller.text.isEmpty) {
                    setState(() {
                      error = 'Caption cannot be empty';
                    });
                    return;
                  }
                  setState(() {
                    isLoading = true;
                  });

                  final res = await BlocProvider.of<PostCubit>(context)
                      .repostPost({
                    'post_id': widget.postId,
                    'content': controller.text
                  });
                  if (res) {
                    await BlocProvider.of<PostCubit>(context).getNewRePost();
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: res
                          ? const Text('Post reposted successfully')
                          : const Text("Failed to repost, try again later"),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  setState(() {
                    isLoading = false;
                  });
                  scrollToTop();
                  Navigator.pop(context);
                },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isLoading ? Colors.grey[300] : Theme.of(context).primaryColor,
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20.0,
                  width: 20.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Submit',
                  style: TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }
}

class BottomSheetContent extends StatefulWidget {
  final bool? isSinglePost;
  final Map<String, dynamic> post;
  final bool? isRepost;
  const BottomSheetContent(
      {super.key, required this.post, this.isSinglePost, this.isRepost});

  @override
  State<BottomSheetContent> createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<BottomSheetContent> {
  User? user;
  bool isSaved = false;
  @override
  void initState() {
    super.initState();
    getUser();
  }

  void getUser() async {
    User? u = await AuthRepo().user;
    setState(() {
      user = u;
      isSaved = widget.post['isSaved'] ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25.0)),
        color: Colors.grey[200],
      ),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 32.0),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: isSaved
                      ? const Icon(Icons.bookmark_remove_rounded)
                      : const Icon(Icons.bookmark_add_rounded),
                  title: Text(isSaved ? 'Unsave Post' : 'Save Post'),
                  subtitle: Text(isSaved
                      ? 'Remove this post from your saved post'
                      : 'Add this post to your saved posts'),
                  onTap: () async {
                    if (isSaved) {
                      final res = await BlocProvider.of<PostCubit>(context)
                          .unsavePost({'post_id': widget.post['post_id']});
                      BlocProvider.of<PostCubit>(context).updateMapInList(
                          widget.post['post_id'], {'isSaved': false});

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: res
                              ? const Text('Post Unsaved')
                              : const Text('Post Didn\'t Unsaved'),
                          padding: const EdgeInsets.only(
                              bottom: 20, top: 10, left: 10),
                        ),
                      );
                    } else {
                      final res = await BlocProvider.of<PostCubit>(context)
                          .savePost({'post_id': widget.post['post_id']});
                      BlocProvider.of<PostCubit>(context).updateMapInList(
                          widget.post['post_id'], {'isSaved': true});

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: res
                              ? const Text('Post Saved')
                              : const Text('Post Didn\'t Saved'),
                          padding: const EdgeInsets.only(
                              bottom: 20, top: 10, left: 10),
                        ),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.flag),
                  title: const Text('Report'),
                  subtitle: const Text('We won\'t tell them who reported'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ReportPostPage(
                                  id: widget.post['post_id'],
                                  postContent: widget.post['content'],
                                )));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.flag),
                  title: const Text('Copy Link'),
                  onTap: () async {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          (user != null && user!.id == widget.post['user_id']) ||
                  (user != null && user!.id == widget.post['repost_user_id'])
              ? Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.flag),
                        title: Text(widget.isRepost == true
                            ? 'Edit Repost'
                            : 'Edit Post'),
                        subtitle: Text(widget.isRepost == true
                            ? 'Edit the Content of the Repost'
                            : 'Edit the Content of the Post'),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditPost(
                                        isRepost: widget.isRepost,
                                        post: widget.post,
                                      )));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.flag),
                        title: Text(widget.isRepost == true
                            ? 'Delete Repost'
                            : 'Delete Post'),
                        subtitle: Text(widget.isRepost == true
                            ? 'Remove this post from your profile'
                            : 'Remove this post from your profile'),
                        onTap: () async {
                          bool res;
                          if (widget.isRepost == true) {
                            res = await BlocProvider.of<PostCubit>(context)
                                .deleteRepost(widget.post['repost_id'],
                                    isRepost: true);
                          } else {
                            res = await BlocProvider.of<PostCubit>(context)
                                .deletePost(widget.post['post_id']);
                          }
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: res
                                  ? const Text('Post deleted')
                                  : const Text('Post deletion failed'),
                              padding: const EdgeInsets.only(
                                  bottom: 20, top: 10, left: 10),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink()
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();
    List<String> reportTypes = [
      'Spam',
      'Inappropriate',
      'Hate speech',
      'Other'
    ];
    String selectedReportType = 'Spam';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Report'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('What is your report?'),
              Column(
                children: [
                  ...reportTypes
                      .map((type) => RadioListTile(
                            title: Text(type),
                            value: type,
                            groupValue: selectedReportType,
                            onChanged: (value) {
                              setState(() {
                                selectedReportType = value!;
                              });
                            },
                          ))
                      .toList(),
                ],
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Enter your report',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                final res =
                    await BlocProvider.of<PostCubit>(context).reportPost({
                  'report_id': widget.post['id'],
                  'reason': '$selectedReportType ${controller.text}'
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: res
                          ? const Text('Report submitted')
                          : const Text("Report didn't submitted")),
                );
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const ActionButton(
      {super.key,
      required this.icon,
      required this.label,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        children: <Widget>[
          IconButton(
            icon: FaIcon(icon),
            onPressed: onPressed,
            iconSize: 32.0,
            color: Colors.blue,
          ),
          Text(label),
        ],
      ),
    );
  }
}

class EditPosts extends StatefulWidget {
  final Map<String, dynamic> post;
  final bool? isSinglePost;
  final bool? isRepost;
  const EditPosts(
      {super.key, required this.post, this.isRepost, this.isSinglePost});

  @override
  State<EditPosts> createState() => _EditPostsState();
}

class _EditPostsState extends State<EditPosts> {
  final TextEditingController controller = TextEditingController();
  final double _keyboardHeight = 0.0;
  User? user;
  late String dropdownValue;
  @override
  void initState() {
    super.initState();
    getUser();
    Logger().i(widget.post);
    controller.text = widget.isRepost == true
        ? widget.post['repost_content']
        : widget.post['content'];
    dropdownValue = widget.post['privacy_setting'];
  }

  void getUser() async {
    User? u = await AuthRepo().user;
    setState(() {
      user = u;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text(
            'Edit Post',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage:
                    (user != null) && (user?.profile_picture != null)
                        ? NetworkImage(
                            '${AuthRepo.SERVER}/${user!.profile_picture!}')
                        : const AssetImage('assets/image/defaultprofile.png')
                            as ImageProvider,
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user?.fullname ?? ''),
                  Row(
                    children: [
                      Container(
                        height: 30,
                        padding: const EdgeInsets.only(left: 15),
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8)),
                        child: DropdownButton<String>(
                          dropdownColor: Colors.amber,
                          iconSize: 35,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(16)),
                          value: dropdownValue,
                          underline: const SizedBox(),
                          onChanged: (String? newValue) {
                            setState(() {
                              dropdownValue = newValue!;
                            });
                          },
                          items: <String>['public', 'private', 'friends_only']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 18),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          TextField(
            autofocus: true,
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter your post',
              border: OutlineInputBorder(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                onPressed: () async {
                  bool res;
                  if (widget.isRepost == true) {
                    res = await BlocProvider.of<PostCubit>(context).editRepost({
                      'post_id': widget.post['repost_id'],
                      'content': controller.text,
                    });
                    if (res) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Post edited'),
                          padding:
                              EdgeInsets.only(bottom: 20, top: 10, left: 10),
                        ),
                      );
                      BlocProvider.of<PostCubit>(context).updateMapInList(
                          widget.post['repost_id'],
                          {
                            'repost_content': controller.text,
                          },
                          isRepost: true);
                      context
                          .read<SinglePostCubit>()
                          .getRepostById(widget.post['repost_id']);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Post edit failed'),
                          padding:
                              EdgeInsets.only(bottom: 20, top: 10, left: 10),
                        ),
                      );
                    }
                  } else {
                    res = await BlocProvider.of<PostCubit>(context).editPost({
                      'post_id': widget.post['id'],
                      'content': controller.text,
                      'privacy_setting': dropdownValue
                    });
                    if (res) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Post edited'),
                          padding:
                              EdgeInsets.only(bottom: 20, top: 10, left: 10),
                        ),
                      );
                      BlocProvider.of<PostCubit>(context).updateMapInList(
                          widget.post['id'], {
                        'content': controller.text,
                        'privacy_setting': dropdownValue
                      });
                      context
                          .read<SinglePostCubit>()
                          .getPostById(widget.post['id']);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Post edit failed'),
                          padding:
                              EdgeInsets.only(bottom: 20, top: 10, left: 10),
                        ),
                      );
                    }
                  }

                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
          const SizedBox(height: 300),
        ],
      ),
    );
  }
}

import 'package:akababi/bloc/cubit/post_cubit.dart';
import 'package:akababi/bloc/cubit/single_post_cubit.dart';
import 'package:akababi/component/PlayerWidget.dart';
import 'package:akababi/component/Reaction.dart';
import 'package:akababi/model/User.dart';
import 'package:akababi/pages/post/SinglePostPage.dart';
import 'package:akababi/pages/profile/UserProfile.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:akababi/utility.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";
import 'package:google_fonts/google_fonts.dart';
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
  Future<void>? _initializeFuture;
  bool _hasError = false;
  double videoRatio = 200;
  User? user0;
  @override
  void initState() {
    super.initState();
    getUser();
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
        setState(() {
          _hasError = true;
        });
      }
    }
    if (media['audio'] != null) {
      print(AuthRepo.SERVER + '/' + media['audio']);
      _audioPlayer = AudioPlayer();
      _initializeFuture =
          _initializePlayer(AuthRepo.SERVER + '/' + media['audio']);
    }
  }

  Future<void> _initializePlayer(String link) async {
    try {
      await _audioPlayer!.setUrl(link); // Replace with your audio URL
    } catch (e) {
      print("Error initializing audio player: $e");
    }
  }

  void getUser() async {
    User? u = await AuthRepo().user;
    setState(() {
      user0 = u;
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
    final user = widget.post['originalUser'] != null
        ? widget.post['originalUser']
        : widget.post['user'] as Map<String, dynamic>;
    return Stack(
      children: [
        Container(
          color: Colors.white,
          margin: EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.post['originalUser'] != null
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
                                      builder: (context) => UserProfile(
                                            id: widget.post['user']['id'],
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
                                            image: widget.post['user']
                                                        ['profile_picture'] !=
                                                    null
                                                ? NetworkImage(
                                                    '${AuthRepo.SERVER}/${widget.post['user']['profile_picture']}',
                                                  ) as ImageProvider
                                                : AssetImage(
                                                    'assets/image/defaultprofile.png'),
                                            fit: BoxFit.cover,
                                          ),
                                        )),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${widget.post['user']['first_name']} ${widget.post['user']['last_name']}',
                                          style: GoogleFonts.exo(
                                              textStyle: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w500)),
                                        ),
                                        Text(
                                            "@${widget.post['user']['username']}",
                                            style: GoogleFonts.exo(
                                                textStyle: TextStyle(
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
                                        icon: Icon(Icons.more_vert),
                                      )
                                    : SizedBox.shrink(),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 8),
                          child: Text(widget.post['repost_content'],
                              style: GoogleFonts.spaceGrotesk(
                                  textStyle: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400))),
                        ),
                      ],
                    )
                  : Container(),
              Container(
                padding: EdgeInsets.only(top: 8),
                margin: widget.post['originalUser'] != null
                    ? EdgeInsets.only(left: 16, top: 4, right: 8)
                    : null,
                decoration: widget.post['originalUser'] != null
                    ? BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(10))
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
                                  builder: (context) => UserProfile(
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
                                    width: widget.post['originalUser'] != null
                                        ? 35
                                        : 45,
                                    height: widget.post['originalUser'] != null
                                        ? 35
                                        : 45,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: (widget.post['originalUser'] ==
                                                        null &&
                                                    widget.post['user'][
                                                            'profile_picture'] !=
                                                        null) ||
                                                (widget.post['originalUser'] !=
                                                        null &&
                                                    widget.post['originalUser'][
                                                            'profile_picture'] !=
                                                        null)
                                            ? NetworkImage(
                                                '${AuthRepo.SERVER}/${widget.post['originalUser'] != null ? widget.post['originalUser']['profile_picture'] : widget.post['user']['profile_picture']}',
                                              ) as ImageProvider
                                            : AssetImage(
                                                'assets/image/defaultprofile.png'),
                                        fit: BoxFit.cover,
                                      ),
                                    )),
                                SizedBox(
                                  width: 5,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${user['first_name']} ${user['last_name']}',
                                      style: GoogleFonts.exo(
                                          textStyle: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                    Row(
                                      children: [
                                        Text("@${user['username']}",
                                            style: GoogleFonts.sofia(
                                                textStyle: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w400))),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                              '${widget.post['privacy_setting']}'),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                // GestureDetector(
                                //     onTap: () {
                                //       Navigator.push(
                                //           context,
                                //           MaterialPageRoute(
                                //               builder: (context) => UserProfile(
                                //                     id: user['id'],
                                //                   )));
                                //     },
                                //     child: Container(
                                //         padding: EdgeInsets.symmetric(
                                //             horizontal: 12, vertical: 4),
                                //         decoration: BoxDecoration(
                                //           color: Colors.grey[200],
                                //           borderRadius:
                                //               BorderRadius.circular(20),
                                //         ),
                                //         child: Text("view profile",
                                //             style: TextStyle(
                                //                 fontSize: 16,
                                //                 fontWeight: FontWeight.w500,
                                //                 color: Colors.grey[700])))),
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
                                  icon: Icon(Icons.more_vert),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (widget.isSinglePost == true) return;
                        Navigator.of(context, rootNavigator: true)
                            .push(MaterialPageRoute(
                                builder: (context) => SinglePostPage(
                                      id: widget.post['id'],
                                    )));
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Text(widget.post['content'],
                                style: GoogleFonts.spaceGrotesk(
                                    textStyle: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400))),
                          ),
                          Media(),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Container(
                // color: Colors.amber,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        widget.post['distance'] != null
                            ? Container(
                                margin: EdgeInsets.only(left: 16, top: 8),
                                padding:
                                    const EdgeInsets.only(left: 16.0, right: 8),
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(20)),
                                child: Text(
                                  "${widget.post['distance']} km away",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                  ),
                                ))
                            : Container(),
                        Container(
                          margin: const EdgeInsets.only(right: 16, top: 8),
                          child: Text(
                            formatDateTime(widget.post[
                                'created_at']), // Timestamp, e.g., '2h ago'
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Reaction(
                          isSinglePost: widget.isSinglePost,
                          reaction: widget.post['reaction'],
                          id: widget.post['id'],
                          likes: widget.post['num_likes'],
                        ),
                        GestureDetector(
                          onTap: () {
                            if (widget.isSinglePost == true) return;
                            Navigator.of(context, rootNavigator: true)
                                .push(MaterialPageRoute(
                                    builder: (context) => SinglePostPage(
                                          id: widget.post['id'],
                                        )));
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: 5, bottom: 5),
                            padding: EdgeInsets.only(
                                left: 24, right: 24, top: 5, bottom: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.comment,
                                  size: 20,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  widget.post['comments'].toString(),
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400),
                                )
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _showRepostDialog(context, widget.isSinglePost);
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: 5, bottom: 5),
                            padding: EdgeInsets.only(
                                left: 24, right: 24, top: 5, bottom: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  FeatherIcons.refreshCw,
                                  size: 20,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(widget.post['num_reposts'].toString(),
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400))
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            generateLinkAndShare(widget.post['id']);
                          },
                          child: Container(
                              margin:
                                  EdgeInsets.only(right: 16, top: 5, bottom: 5),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Icon(
                                FeatherIcons.share2,
                                size: 20,
                              )),
                        ),
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

  void generateLinkAndShare(int id) {
    // Generate your text here
    String textToShare = "https://api1.myakababi.com/post/$id";

    // Share the text
    Share.share(textToShare);
  }

  Widget Media() {
    if (widget.post['media'] != null) {
      Map<String, dynamic> media = decodeMedia(widget.post['media']);
      if (media['image'] != null) {
        return Container(
            width: MediaQuery.of(context).size.width,
            child: Image.network(
              '${AuthRepo.SERVER}/${media['image']}',
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
      } else if (media['video'] != null) {
        return SizedBox(
            height: MediaQuery.of(context).size.width / videoRatio,
            width: MediaQuery.of(context).size.width,
            child: _hasError
                ? Text("Error loading video")
                : videoPlayerController != null &&
                        videoPlayerController!.value.isInitialized
                    ? Chewie(
                        controller: chewieController!,
                      )
                    : Center(child: CircularProgressIndicator()));
      } else if (media['audio'] != null) {
        return AudioPlayerScreen(
            audioUrl: AuthRepo.SERVER + '/' + media['audio']);
      }
      return Container(
        height: 50,
      );
    }
    return Container();
  }

  void _showRepostDialog(BuildContext context, bool? isSinglePost) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RepostDialog(
            isSinglePost: isSinglePost, postId: widget.post['id']);
      },
    );
  }
}

class RepostDialog extends StatefulWidget {
  final bool? isSinglePost;
  final int postId;
  const RepostDialog({super.key, this.isSinglePost, required this.postId});

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
      title: Text('Repost'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(error.isEmpty ? 'Add a caption to your repost' : error),
          SizedBox(height: 16.0),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter your caption',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            if (isLoading) return;
            setState(() {
              isLoading = true;
            });
            if (controller.text.isEmpty) {
              setState(() {
                error = 'Caption cannot be empty';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Caption cannot be empty'),
                  dismissDirection: DismissDirection.up,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              return;
            }

            final res = await BlocProvider.of<PostCubit>(context).repostPost(
                {'post_id': widget.postId, 'content': controller.text});
            if (res) {
              await BlocProvider.of<PostCubit>(context).getNewRePost();
            }
            jumpToTop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: res
                      ? Text('Post reposted')
                      : Text("Post didn't reposted try again later")),
            );
            if (widget.isSinglePost == true) {
              Navigator.of(context).pop();
            }
            setState(() {
              isLoading = false;
            });
            Navigator.pop(context);
          },
          child: Text('Submit',
              style: TextStyle(color: isLoading ? Colors.grey : Colors.black)),
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
  @override
  void initState() {
    super.initState();
    getUser();
  }

  void getUser() async {
    User? u = await AuthRepo().user;
    setState(() {
      user = u;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Actions',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              (widget.post['isSaved'] == null || !widget.post['isSaved']) &&
                      widget.isRepost != true
                  ? ActionButton(
                      icon: FontAwesomeIcons.bookmark,
                      label: 'Save',
                      onPressed: () async {
                        final res = await BlocProvider.of<PostCubit>(context)
                            .savePost({'post_id': widget.post['id']});
                        BlocProvider.of<PostCubit>(context).updateMapInList(
                            widget.post['id'], {'isSaved': true});
                        if (widget.isSinglePost == true) {
                          context
                              .read<SinglePostCubit>()
                              .getPostById(widget.post['id']);
                        }
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: res
                                ? Text('Post saved')
                                : Text('Post didn\'t saved'),
                            padding:
                                EdgeInsets.only(bottom: 20, top: 10, left: 10),
                          ),
                        );
                      },
                    )
                  : widget.isRepost != true
                      ? ActionButton(
                          icon: Icons.bookmark_remove_outlined,
                          label: 'Unsave',
                          onPressed: () async {
                            final res =
                                await BlocProvider.of<PostCubit>(context)
                                    .unsavePost({'post_id': widget.post['id']});
                            BlocProvider.of<PostCubit>(context).updateMapInList(
                                widget.post['id'], {'isSaved': false});
                            if (widget.isSinglePost == true) {
                              context
                                  .read<SinglePostCubit>()
                                  .getPostById(widget.post['id']);
                            }
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: res
                                    ? Text('Post unsaved')
                                    : Text('Post didn\'t unsaved'),
                                padding: EdgeInsets.only(
                                    bottom: 20, top: 10, left: 10),
                              ),
                            );
                          },
                        )
                      : const SizedBox.shrink(),
              widget.isRepost != true
                  ? ActionButton(
                      icon: FontAwesomeIcons.fileAlt,
                      label: 'Report',
                      onPressed: () {
                        _showReportDialog(context);
                      },
                    )
                  : const SizedBox.shrink(),
              (user != null) &&
                      ((widget.post['user_id'] == user!.id) ||
                          (widget.isRepost == true &&
                              widget.post['repost_user_id'] == user!.id))
                  ? ActionButton(
                      icon: FontAwesomeIcons.edit,
                      label: 'Edit',
                      onPressed: () {
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return EditPost(
                              post: widget.post,
                              isRepost: widget.isRepost,
                              isSinglePost: widget.isSinglePost,
                            );
                          },
                        );
                      },
                    )
                  : SizedBox.shrink(),
              (user != null) &&
                      ((widget.post['user_id'] == user!.id) ||
                          (widget.isRepost == true &&
                              widget.post['repost_user_id'] == user!.id))
                  ? ActionButton(
                      icon: FontAwesomeIcons.trash,
                      label: 'Delete',
                      onPressed: () async {
                        var res;
                        if (widget.isRepost == true) {
                          res = await BlocProvider.of<PostCubit>(context)
                              .deleteRepost(widget.post['repost_id'],
                                  isRepost: true);
                        } else {
                          res = await BlocProvider.of<PostCubit>(context)
                              .deletePost(widget.post['id']);
                        }
                        if (widget.isSinglePost == true) {
                          Navigator.of(context).pop();
                        }
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: res
                                ? Text('Post deleted')
                                : Text('Post deletion failed'),
                            padding:
                                EdgeInsets.only(bottom: 20, top: 10, left: 10),
                          ),
                        );
                      },
                    )
                  : Container(),
            ],
          ),
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
          title: Text('Report'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('What is your report?'),
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
              SizedBox(height: 16.0),
              TextField(
                controller: controller,
                decoration: InputDecoration(
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
                          ? Text('Report submitted')
                          : Text("Report didn't submitted")),
                );
              },
              child: Text('Submit'),
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

  ActionButton(
      {required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.0),
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

class EditPost extends StatefulWidget {
  final Map<String, dynamic> post;
  final bool? isSinglePost;
  final bool? isRepost;
  EditPost({super.key, required this.post, this.isRepost, this.isSinglePost});

  @override
  State<EditPost> createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> with WidgetsBindingObserver {
  final TextEditingController controller = TextEditingController();
  double _keyboardHeight = 0.0;
  late String dropdownValue;
  @override
  void initState() {
    super.initState();
    Logger().i(widget.post);
    WidgetsBinding.instance.addObserver(this);
    controller.text = widget.isRepost == true
        ? widget.post['repost_content']
        : widget.post['content'];
    dropdownValue = widget.post['privacy_setting'];
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    print("object");
    final bottomInset = View.of(context).viewInsets.bottom;
    setState(() {
      _keyboardHeight = bottomInset;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Edit Post',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.0),
          TextField(
            autofocus: true,
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter your post',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16.0),
          widget.isRepost != true
              ? DropdownButton<String>(
                  value: dropdownValue,
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownValue = newValue!;
                    });
                  },
                  items: <String>['public', 'private', 'friends_only']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                )
              : SizedBox.shrink(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                onPressed: () async {
                  var res;
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
                child: Text('Save'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
            ],
          ),
          SizedBox(height: _keyboardHeight),
        ],
      ),
    );
  }
}

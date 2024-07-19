import 'package:akababi/bloc/cubit/post_cubit.dart';
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
  const PostItem({super.key, required this.post});

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
  @override
  void initState() {
    super.initState();
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
                                            image: NetworkImage(
                                              '${AuthRepo.SERVER}/${widget.post['user']['profile_picture']}',
                                            ),
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
                                Row(
                                  children: [
                                    GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      UserProfile(
                                                        id: widget.post['user']
                                                            ['id'],
                                                      )));
                                        },
                                        child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text("view profile",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey[700])))),
                                  ],
                                )
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
                                        image: NetworkImage(
                                          '${AuthRepo.SERVER}/${user['profile_picture']}',
                                        ),
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
                                    Text("@${user['username']}",
                                        style: GoogleFonts.sofia(
                                            textStyle: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400))),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => UserProfile(
                                                    id: user['id'],
                                                  )));
                                    },
                                    child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text("view profile",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey[700])))),
                                IconButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return BottomSheetContent(
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
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Text(widget.post['content'],
                          style: GoogleFonts.spaceGrotesk(
                              textStyle: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w400))),
                    ),
                    GestureDetector(
                        onTap: () {
                          Navigator.of(context, rootNavigator: true)
                              .push(MaterialPageRoute(
                                  builder: (context) => SinglePostPage(
                                        id: widget.post['id'],
                                      )));
                        },
                        child: Media())
                  ],
                ),
              ),
              Container(
                // color: Colors.amber,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Reaction(
                            reaction: widget.post['reaction'],
                            id: widget.post['id'],
                            likes: widget.post['num_likes'],
                          ),
                          Row(
                            children: [
                              IconButton(
                                  onPressed: () {}, icon: Icon(Icons.comment)),
                              Text(
                                widget.post['comments'].toString(),
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w400),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                  onPressed: () {
                                    _showRepostDialog(context);
                                  },
                                  icon: Icon(FeatherIcons.refreshCw)),
                              Text(widget.post['num_reposts'].toString(),
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400))
                            ],
                          ),
                          IconButton(
                              onPressed: () {
                                generateLinkAndShare(widget.post['id']);
                              },
                              icon: Icon(FeatherIcons.share2)),
                        ],
                      ),
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
        print('${AuthRepo.SERVER}/${media['image']}');
        return Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(),
            child: Image.network(
              '${AuthRepo.SERVER}/${media['image']}',
              fit: BoxFit.fitWidth,
            ));
      } else if (media['video'] != null) {
        return SizedBox(
            height: MediaQuery.of(context).size.width / videoRatio,
            width: MediaQuery.of(context).size.width,
            child: _hasError
                ? Text("Error loading video")
                : videoPlayerController!.value.isInitialized
                    ? Chewie(
                        controller: chewieController!,
                      )
                    : CircularProgressIndicator());
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

  void _showRepostDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Repost'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add a caption to your repost'),
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
                final res = await BlocProvider.of<PostCubit>(context)
                    .repostPost({
                  'post_id': widget.post['id'],
                  'content': controller.text
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: res
                          ? Text('Post reported')
                          : Text("Post didn't reported")),
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

class BottomSheetContent extends StatefulWidget {
  final Map<String, dynamic> post;

  const BottomSheetContent({super.key, required this.post});

  @override
  State<BottomSheetContent> createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<BottomSheetContent> {
  late User? user;
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ActionButton(
                icon: FontAwesomeIcons.bookmark,
                label: 'Save',
                onPressed: () async {
                  final res = await BlocProvider.of<PostCubit>(context)
                      .savePost({'post_id': widget.post['id']});
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          res ? Text('Post saved') : Text('Post didn\'t saved'),
                      padding: EdgeInsets.only(bottom: 20, top: 10, left: 10),
                    ),
                  );
                },
              ),
              ActionButton(
                icon: FontAwesomeIcons.fileAlt,
                label: 'Report',
                onPressed: () {
                  _showReportDialog(context);
                  Navigator.pop(context);
                },
              ),
              ActionButton(
                icon: FontAwesomeIcons.edit,
                label: 'Edit',
                onPressed: () {
                  print("object");
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return EditPost(post: widget.post);
                    },
                  );
                },
              ),
              widget.post['user_id'] == user!.id
                  ? ActionButton(
                      icon: FontAwesomeIcons.trash,
                      label: 'Delete',
                      onPressed: () async {
                        final res = await BlocProvider.of<PostCubit>(context)
                            .deletePost(widget.post['id']);
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
    return Column(
      children: <Widget>[
        IconButton(
          icon: FaIcon(icon),
          onPressed: onPressed,
          iconSize: 32.0,
          color: Colors.blue,
        ),
        Text(label),
      ],
    );
  }
}

class EditPost extends StatefulWidget {
  final Map<String, dynamic> post;
  EditPost({super.key, required this.post});

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
    WidgetsBinding.instance.addObserver(this);
    controller.text = widget.post['content'];
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
          DropdownButton<String>(
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
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  BlocProvider.of<PostCubit>(context).editPost({
                    'post_id': widget.post['id'],
                    'content': controller.text,
                    'privacy_setting': dropdownValue
                  });
                  Navigator.pop(context);
                },
                child: Text('Save'),
              ),
              ElevatedButton(
                onPressed: () {},
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

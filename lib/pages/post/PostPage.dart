import 'dart:io';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_compress/video_compress.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:akababi/bloc/auth/auth_state.dart';
import 'package:akababi/bloc/cubit/post_cubit.dart';
import 'package:akababi/model/User.dart';
import 'package:akababi/pages/post/VideoEditor.dart';
import 'package:akababi/pages/post/utilities.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:akababi/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  String dropdownValue = 'public';
  User? user;
  bool _switchValue = true;
  late ChewieController _chewieController;
  late VideoPlayerController _videoPlayerController;
  final mediaPicker = MediaPicker();
  final mediaProcessing = MediaProcessing();
  late Subscription _subscription;
  final TextEditingController _textEditingController = TextEditingController();
  bool isLoading = false;
  double progress = 0;
  String? error;
  String thumbnailFilePath = '';

  @override
  void initState() {
    super.initState();
    init();
    // _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(
    //     'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'))
    //   ..initialize().then((_) {
    //     // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
    //     setState(() {
    //       _chewieController = ChewieController(
    //         videoPlayerController: _videoPlayerController,
    //         aspectRatio: _videoPlayerController.value.aspectRatio,
    //       );
    //     });
    //   });
    _subscription = VideoCompress.compressProgress$.subscribe((progress) {
      print('progress: $progress');
      setState(() {
        this.progress = progress;
      });
    });
  }

  void init() async {
    User? u = await authRepo.user;
    final pref = await SharedPreferences.getInstance();
    bool location = pref.getBool('location') ?? true;
    setState(() {
      _switchValue = location;
      user = u;
    });
  }

  @override
  void dispose() {
    _subscription.unsubscribe();
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Post"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              onPressed: () {
                if (isLoading) {
                  return;
                } else {
                  uploadFile(context);
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: isLoading
                    ? Colors.grey[200]
                    : Colors.blue, // Set the text color

                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10), // Set the button padding
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8), // Set the button border radius
                ),
              ),
              child: const Text('Post'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              !_switchValue
                  ? Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.red.withOpacity(0.7),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "Enabling location helps you reach a wider audience.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red.withOpacity(0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : SizedBox.shrink(),
              const SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: (user != null) &&
                            (user?.profile_picture != null)
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
                      Text(
                        user?.fullname ?? '',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: const Color.fromARGB(255, 0, 0, 0)
                                .withOpacity(0.8)),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Container(
                            width: 100,
                            height: 35,
                            padding: const EdgeInsets.only(left: 15),
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8)),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              elevation: 16,
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
                              items: <String>[
                                'public',
                                'private',
                                'friends_only'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Row(
                            children: [
                              Text("Location",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: const Color.fromARGB(255, 0, 0, 0)
                                          .withOpacity(0.5))),
                              const SizedBox(
                                width: 5,
                              ),
                              SizedBox(
                                height: 30,
                                width: 40,
                                child: FittedBox(
                                  fit: BoxFit.fill,
                                  child: Switch(
                                      value: _switchValue,
                                      onChanged: (newValue) {
                                        setState(() {
                                          _switchValue = newValue;
                                        });
                                      }),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        width: 180,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                                onTap: () async {
                                  await mediaPicker
                                      .pickImage(ImageSource.camera);
                                  setState(() {});
                                },
                                child:
                                    const Icon(FluentIcons.camera_20_regular)),
                            GestureDetector(
                              onTap: () async {
                                await mediaPicker
                                    .pickImage(ImageSource.gallery);
                                setState(() {});
                              },
                              child: const Icon(FluentIcons.image_20_regular),
                            ),
                            GestureDetector(
                              onTap: () async {
                                await mediaPicker.pickAudio();
                                setState(() {});
                              },
                              child: const Icon(FluentIcons.mic_20_regular),
                            ),
                            GestureDetector(
                              onTap: () async {
                                await mediaPicker
                                    .pickVideo(ImageSource.gallery);
                                setState(() {});
                              },
                              child:
                                  const Icon(FluentIcons.video_clip_20_regular),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              isLoading && error == null
                  ? UploadProgress(progress: progress)
                  : error != null
                      ? Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                              color: Colors.red.shade400,
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(error!,
                              style: const TextStyle(color: Colors.white)),
                        )
                      : Container(),
              const SizedBox(
                height: 20,
              ),
              TextField(
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                autofocus: true,
                controller: _textEditingController,
                minLines: 1,
                maxLines: 12,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "What's on your mind?",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 24),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8))),
                  child: Column(
                    children: [
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8)),
                                child: Text(selectedMedia["fileType"] ?? "",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18)),
                              ),
                              Flexible(
                                child: Text(
                                  basename(selectedMedia["filePath"] ?? ""),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: Colors.grey),
                                ),
                              ),
                              selectedMedia["fileType"] == 'image'
                                  ? GestureDetector(
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ProImageEditor.file(
                                              File(selectedMedia["filePath"]),
                                              callbacks:
                                                  ProImageEditorCallbacks(
                                                onImageEditingComplete:
                                                    (Uint8List bytes) async {
                                                  await mediaPicker
                                                      .saveImageFromBytes(
                                                          bytes);
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ),
                                          ),
                                        );
                                        setState(() {});
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 4),
                                        decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: const Text('Edit',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 18,
                                                color: Colors.white)),
                                      ),
                                    )
                                  : Container(),
                            ],
                          )),
                      _ShowSelectedFile(),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void uploadFile(BuildContext context) async {
    try {
      if (selectedMedia["filePath"].isEmpty) {
        setState(() {
          error = 'Please select a file';
        });
        Future.delayed(const Duration(seconds: 3), () {
          setState(() {
            error = null;
          });
        });
        return;
      }
      if (_textEditingController.text.isEmpty) {
        setState(() {
          error = 'Please enter a text';
        });
        Future.delayed(const Duration(seconds: 3), () {
          setState(() {
            error = null;
          });
        });
        return;
      }
      setState(() {
        isLoading = true;
      });
      print("pass check out next ${selectedMedia["filePath"]}");
      if (selectedMedia["fileType"] == 'image') {
        await mediaProcessing.compressImage(File(selectedMedia["filePath"]));
      } else if (selectedMedia["fileType"] == 'video') {
        MediaInfo? mediaInfo = await VideoCompress.compressVideo(
          selectedMedia["filePath"],
          quality: VideoQuality.DefaultQuality,
          deleteOrigin: false, // It's false by default
        );
        print('${mediaInfo!.path}');
        selectedMedia["filePath"] = mediaInfo.path;

        print("pass compress video");
        final thumbnailFile =
            await VideoCompress.getFileThumbnail(selectedMedia["filePath"],
                quality: 50, // default(100)
                position: -1 // default(-1)
                );
        setState(() {
          thumbnailFilePath = thumbnailFile.path;
        });
      }

      print("pass compress");
      final loc = await getCurrentLocation(context);
      print("pass location");
      Map<String, dynamic> formDataMap = {
        "user_id": user!.id,
        "longitude": loc!.longitude,
        "latitude": loc.latitude,
        "privacy_setting": dropdownValue,
        "content": _textEditingController.text,
        selectedMedia["fileType"]: await MultipartFile.fromFile(
            selectedMedia["filePath"],
            contentType: MediaType(selectedMedia["mediaType"].split(' ')[0],
                selectedMedia["mediaType"].split(' ')[1])),
      };
      if (_switchValue == false) {
        formDataMap.remove("longitude");
        formDataMap.remove("latitude");
      }
      ;

      if (thumbnailFilePath.isNotEmpty &&
          selectedMedia["fileType"] == 'video') {
        formDataMap["thumbnail"] = await MultipartFile.fromFile(
            thumbnailFilePath,
            contentType: MediaType('image', 'jpeg'));
      }
      FormData formData = FormData.fromMap(formDataMap);
      print("pass formdata");
      await Dio().post("${AuthRepo.SERVER}/post/createPost", data: formData);
      print("pass post");
      setState(() {
        selectedMedia = {"filePath": "", "fileType": "", "mediaType": ""};
        thumbnailFilePath = '';
      });

      _textEditingController.clear();
      trigerNotification("Post Upload", "Post uploaded successfully");
      await BlocProvider.of<PostCubit>(context).getNewPost();
      Navigator.pop(context);
      scrollToTop();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (e is DioException) {
        String error = handleDioError(e);
        print(error);
        setState(() {
          isLoading = false;
          error = error;
        });
      }
      Future.delayed(const Duration(seconds: 5), () {
        setState(() {
          error = null;
        });
      });
    }
  }

  void openFile() async {
    OpenFile.open(selectedMedia["filePath"]);
  }

  Future<void> initVideo() async {
    _videoPlayerController =
        VideoPlayerController.file(File(selectedMedia["filePath"]));
    await _videoPlayerController.initialize();
    // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
    setState(() {
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        aspectRatio: _videoPlayerController.value.aspectRatio,
      );
    });
  }

  // ignore: non_constant_identifier_names
  Widget _ShowSelectedFile() {
    if (selectedMedia["fileType"] == 'video') {
      return thumbnailFilePath.isNotEmpty
          ? Image.file(File(thumbnailFilePath))
          : FutureBuilder(
              future: initVideo(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return AspectRatio(
                    aspectRatio: _videoPlayerController.value.aspectRatio,
                    child: Chewie(controller: _chewieController),
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                return const SizedBox.shrink();
              });
    } else if (selectedMedia["fileType"] == 'image') {
      return Image.file(File(selectedMedia["filePath"]));
    } else if (selectedMedia["fileType"] == 'file') {
      return ElevatedButton(
        onPressed: () {
          openFile();
        },
        child: const Text('Open file'),
      );
    } else if (selectedMedia["fileType"] == 'audio') {
      return Container(
          child: ElevatedButton(
        onPressed: () {
          openFile();
        },
        child: const Text('Open audio file'),
      ));
    } else {
      return const SizedBox(
        height: 320,
        child: Center(
          child: Text('No file selected',
              style: TextStyle(
                fontSize: 24,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              )),
        ),
      );
    }
  }

  void _showModalBottomSheet(BuildContext context, bool isImage) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera),
                title: isImage
                    ? const Text('Take a photo')
                    : const Text('Take a video'),
                onTap: () {
                  if (isImage) {
                    mediaPicker.pickImage(ImageSource.camera);
                  } else {
                    mediaPicker.pickVideo(ImageSource.camera);
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  if (isImage) {
                    mediaPicker.pickImage(ImageSource.gallery);
                  } else {
                    mediaPicker.pickVideo(ImageSource.gallery);
                  }
                  Navigator.pop(context);
                },
              ),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        );
      },
    );
  }

  Widget button(void Function() fun, String text, Color color) {
    return GestureDetector(
      onTap: fun,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 38, vertical: 4),
        decoration:
            BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}

class UploadProgress extends StatelessWidget {
  final double progress;

  const UploadProgress({Key? key, required this.progress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // // Circular progress indicator for a sleek, modern look
          // Stack(
          //   alignment: Alignment.center,
          //   children: [
          //     SizedBox(
          //       width: 100,
          //       height: 100,
          //       child: CircularProgressIndicator(
          //         value: progress / 100,
          //         strokeWidth: 8,
          //         backgroundColor: Colors.grey.shade200,
          //         valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          //       ),
          //     ),
          //     // Progress percentage inside the circular indicator
          //     Text(
          //       '${progress.toStringAsFixed(0)}%',
          //       style: const TextStyle(
          //         fontSize: 20,
          //         fontWeight: FontWeight.bold,
          //         color: Colors.black,
          //       ),
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 20),
          // // Progress bar for another visual representation
          Text(
            'Uploading... ${progress.toStringAsFixed(2)}%',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            minHeight: 16,
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      ),
    );
  }
}

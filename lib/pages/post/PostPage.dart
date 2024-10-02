import 'dart:io';
import 'package:flutter/foundation.dart';
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
  PostPage({Key? key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  String dropdownValue = 'public';
  User? user;
  bool _switchValue = true;

  final mediaPicker = MediaPicker();
  final mediaProcessing = MediaProcessing();
  late Subscription _subscription;
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  final TextEditingController _textEditingController = TextEditingController();
  bool isLoading = false;
  double progress = 0;
  String? error;
  String thumbnailFilePath = '';
  @override
  void initState() {
    super.initState();
    init();
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController,
            aspectRatio: _videoPlayerController.value.aspectRatio,
          );
        });
      });
    _subscription = VideoCompress.compressProgress$.subscribe((progress) {
      print('progress: $progress');
      setState(() {
        this.progress = progress;
      });
    });
  }

  void init() async {
    user = await authRepo.user;
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    _subscription.unsubscribe();
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
              child: const Text('Upload'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
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
                                  BorderRadius.all(Radius.circular(16)),
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
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          Row(
                            children: [
                              Text("location",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Color.fromARGB(255, 0, 0, 0)
                                          .withOpacity(0.5))),
                              SizedBox(
                                height: 20,
                                width: 30,
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
                        margin: EdgeInsets.symmetric(vertical: 20),
                        width: 180,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                await mediaPicker.pickImage(ImageSource.camera);
                                setState(() {});
                              },
                              child: Icon(Icons.camera_alt_outlined),
                            ),
                            GestureDetector(
                              onTap: () async {
                                await mediaPicker
                                    .pickImage(ImageSource.gallery);
                                setState(() {});
                              },
                              child: Icon(Icons.image),
                            ),
                            GestureDetector(
                              onTap: () async {
                                await mediaPicker.pickAudio();
                                setState(() {});
                              },
                              child: Icon(Icons.mic),
                            ),
                            GestureDetector(
                              onTap: () async {
                                await mediaPicker
                                    .pickVideo(ImageSource.gallery);
                                setState(() {});
                              },
                              child: Icon(Icons.play_circle_outline_outlined),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
              isLoading && error == null
                  ? Column(
                      children: [
                        const Center(
                            child: CircularProgressIndicator.adaptive()),
                        const SizedBox(height: 10),
                        Text(
                          'Uploading ${progress.toStringAsFixed(2)}%',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    )
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
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: TextField(
                  autofocus: true,
                  controller: _textEditingController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "What's on your mind?",
                    hintStyle: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  const Text("Privacy setting"),
                  const SizedBox(
                    width: 20,
                  ),
                ],
              ),
              ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProImageEditor.file(
                          File(selectedMedia["filePath"]),
                          callbacks: ProImageEditorCallbacks(
                            onImageEditingComplete: (Uint8List bytes) async {
                              await mediaPicker.saveImageFromBytes(bytes);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                    );
                    setState(() {});
                  },
                  child: Text("Edit")),
              const SizedBox(
                height: 20,
              ),
              Container(
                child: Text(basename(selectedMedia["filePath"] ?? "")),
              ),
              _ShowSelectedFile(),
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
      scrollToTop();
      pageController.jumpToTab(0);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (e is DioException) {
        String _error = handleDioError(e);
        print(_error);
        setState(() {
          isLoading = false;
          error = _error;
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

  Widget _ShowSelectedFile() {
    if (selectedMedia["fileType"] == 'video') {
      _videoPlayerController =
          VideoPlayerController.file(File(selectedMedia["filePath"]));

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        aspectRatio: _videoPlayerController.value.aspectRatio,
      );
      return thumbnailFilePath.isNotEmpty
          ? Image.file(File(thumbnailFilePath))
          : Column(children: [
              AspectRatio(
                aspectRatio: _videoPlayerController.value.aspectRatio,
                child: Chewie(controller: _chewieController),
              )
            ]);
    } else if (selectedMedia["fileType"] == 'image') {
      return Image.file(File(selectedMedia["filePath"]));
    } else if (selectedMedia["fileType"] == 'file') {
      return Container(
          child: ElevatedButton(
        onPressed: () {
          openFile();
        },
        child: const Text('Open file'),
      ));
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

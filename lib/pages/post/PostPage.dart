import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:akababi/bloc/auth/auth_state.dart';
import 'package:akababi/bloc/cubit/post_cubit.dart';
import 'package:akababi/model/User.dart';
import 'package:akababi/pages/post/EditImage.dart';
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
      User? user = await authRepo.user;
      final loc = await getCurrentLocation(context);
      if (selectedMedia["filePath"].isNotEmpty) {
        FormData formData = FormData.fromMap({
          "user_id": user!.id,
          "longitude": loc!.longitude,
          "latitude": loc.latitude,
          "privacy_setting": dropdownValue,
          "content": _textEditingController.text,
          selectedMedia["fileType"]: await MultipartFile.fromFile(
              selectedMedia["filePath"],
              contentType: selectedMedia["MediaType"](
                  selectedMedia["mediaType"].split(' ')[0],
                  selectedMedia["mediaType"].split(' ')[1])),
        });
        print(formData);
        Response response = await Dio()
            .post("${AuthRepo.SERVER}/post/createPost", data: formData);
        print(response);
        // Handle the response as needed
        setState(() {
          selectedMedia["filePath"] = '';
          selectedMedia["fileType"] = '';
          selectedMedia["mediaType"] = '';
        });
        _textEditingController.clear();
        trigerNotification("Post Upload", "Post uploaded successfully");
        await BlocProvider.of<PostCubit>(context).getNewPost();
        scrollToTop();
        pageController.jumpToTab(0);
      }
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
        // final arg = {"type": ErrorType.noconnect, "msg": error};
        // Navigator.pushNamed(event.context, '/error', arguments: arg);
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

  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  final TextEditingController _textEditingController = TextEditingController();
  bool isLoading = false;
  String? error;
  @override
  void initState() {
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
    super.initState();
  }

  void init() async {
    user = await authRepo.user;
  }

  @override
  void dispose() {
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
                  ? const Center(child: CircularProgressIndicator.adaptive())
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
                    // Navigator.push(context,
                    //     MaterialPageRoute(builder: (context) => EditImage()));
                    // await mediaProcessing
                    //     .resizeImage(File(selectedMedia["filePath"]));
                    // setState(() {});
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProImageEditor.network(
                          'https://picsum.photos/id/237/2000',
                          callbacks: ProImageEditorCallbacks(
                            onImageEditingComplete: (Uint8List bytes) async {
                              /*
              Your code to handle the edited image. Upload it to your server as an example.
              You can choose to use await, so that the loading-dialog remains visible until your code is ready, or no async, so that the loading-dialog closes immediately.
              By default, the bytes are in `jpg` format.
            */
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                    );
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

  Widget _ShowSelectedFile() {
    if (selectedMedia["fileType"] == 'video') {
      _videoPlayerController =
          VideoPlayerController.file(File(selectedMedia["filePath"]));

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        aspectRatio: _videoPlayerController.value.aspectRatio,
      );

      return Column(children: [
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

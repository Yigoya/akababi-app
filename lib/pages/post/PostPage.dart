import 'dart:io';

import 'package:akababi/bloc/auth/auth_state.dart';
import 'package:akababi/component/Header.dart';
import 'package:akababi/model/User.dart';
import 'package:akababi/pages/feed/FeedPage.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:akababi/utility.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  String dropdownValue = 'public';
  String filePath = '';
  String fileType = '';
  String mediaType = '';
  Future<void> pickImage(ImageSource imageSource) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: imageSource);

    if (image != null) {
      String fileExtension = extension(image.path);

      setState(() {
        filePath = image.path;
        fileType = 'image';
        mediaType = 'image $fileExtension';
      });
    }
  }

  void pickVideo(ImageSource imageSource) async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(source: imageSource);
    if (video != null) {
      String fileExtension = extension(video.path);

      setState(() {
        filePath = video.path;
        fileType = 'video';
        mediaType = 'video $fileExtension';
      });
    }
  }

  void pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );
    if (result != null) {
      PlatformFile file = result.files.first;
      String fileExtension = extension(file.path!);
      setState(() {
        filePath = file.path!;
        fileType = 'audio';
        mediaType = 'audio $fileExtension';
      });
    }
  }

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;
      String fileExtension = extension(file.path!);
      setState(() {
        filePath = file.path!;
        fileType = 'file';
        mediaType = 'application $fileExtension';
      });
      // FormData formData = FormData.fromMap({
      //   "file": await MultipartFile.fromFile(file.path),
      // });
      // Response response = await Dio().post("your_backend_url", data: formData);
      // // Handle the response as needed
      // // Do something with the picked file
    }
  }

  void uploadFile(BuildContext context) async {
    try {
      setState(() {
        isLoading = true;
      });
      User? user = await authRepo.user;
      final loc = await getCurrentLocation(context);
      if (filePath.isNotEmpty) {
        FormData formData = FormData.fromMap({
          "user_id": user!.id,
          "longitude": loc!.longitude,
          "latitude": loc.latitude,
          "privacy_setting": dropdownValue,
          "content": _textEditingController.text,
          fileType: await MultipartFile.fromFile(filePath,
              contentType:
                  MediaType(mediaType.split(' ')[0], mediaType.split(' ')[1])),
        });
        print(formData);
        Response response = await Dio()
            .post("${AuthRepo.SERVER}/post/createPost", data: formData);
        print(response);
        // Handle the response as needed

        PersistentNavBarNavigator.pushNewScreen(context, screen: const FeedPage());
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print(e.toString());
      setState(() {
        isLoading = false;
        error = 'An error occurred while uploading the file';
      });
    }
  }

  void openFile() async {
    OpenFile.open(filePath);
  }

  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  final TextEditingController _textEditingController = TextEditingController();
  bool isLoading = false;
  String? error;
  @override
  void initState() {
    super.initState();

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
      appBar: AppHeader(context, "Create post"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              isLoading && error == null
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : error != null
                      ? Container(
                          color: Colors.red,
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Text(error!),
                        )
                      : Container(),
              TextField(
                controller: _textEditingController,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "what is in your mind",
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.7))),
              ),
              Row(
                children: [
                  const Text("Privacy setting"),
                  const SizedBox(
                    width: 20,
                  ),
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
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  button(() {
                    _showModalBottomSheet(context, true);
                  }, "image", Colors.green.shade400),
                  button(() {
                    _showModalBottomSheet(context, false);
                  }, "video", Colors.red.shade400),
                  button(pickAudio, "audio", Colors.yellow.shade400),
                  button(pickFile, "file", Colors.grey.shade400),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                child: Text(basename(filePath)),
              ),
              _ShowSelectedFile()
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          uploadFile(context);
        },
        child: const Icon(Icons.upload),
      ),
    );
  }

  Widget _ShowSelectedFile() {
    if (fileType == 'video') {
      _videoPlayerController = VideoPlayerController.file(File(filePath));

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
    } else if (fileType == 'image') {
      return Image.file(File(filePath));
    } else if (fileType == 'file') {
      return Container(
          child: ElevatedButton(
        onPressed: () {
          openFile();
        },
        child: const Text('Open file'),
      ));
    } else if (fileType == 'audio') {
      return Container(
          child: ElevatedButton(
        onPressed: () {
          openFile();
        },
        child: const Text('Open audio file'),
      ));
    } else {
      return const SizedBox.shrink();
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
                title: isImage ? const Text('Take a photo') : const Text('Take a video'),
                onTap: () {
                  if (isImage) {
                    pickImage(ImageSource.camera);
                  } else {
                    pickVideo(ImageSource.camera);
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  if (isImage) {
                    pickImage(ImageSource.gallery);
                  } else {
                    pickVideo(ImageSource.gallery);
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
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

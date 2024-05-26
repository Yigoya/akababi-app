import 'dart:io';

import 'package:akababi/bloc/auth/auth_state.dart';
import 'package:akababi/component/Header.dart';
import 'package:akababi/model/User.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:akababi/utility.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
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

  void uploadFile() async {
    try {
      User? user = await authRepo.user;
      final loc = await getCurrentLocation();
      if (filePath.isNotEmpty) {
        FormData formData = FormData.fromMap({
          "user_id": user!.id,
          "longitude": loc!.longitude,
          "latitude": loc.latitude,
          "privacy_setting": "public",
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
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void openFile() async {
    OpenFile.open(filePath);
  }

  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  final TextEditingController _textEditingController = TextEditingController();
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
            aspectRatio: 16 / 9,
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
              TextField(
                controller: _textEditingController,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "what is in your mind",
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.7))),
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
              SizedBox(
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
          uploadFile();
        },
        child: Icon(Icons.upload),
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
        child: Text('Open file'),
      ));
    } else if (fileType == 'audio') {
      return Container(
          child: ElevatedButton(
        onPressed: () {
          openFile();
        },
        child: Text('Open audio file'),
      ));
    } else {
      return SizedBox.shrink();
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
                leading: Icon(Icons.camera),
                title: Text('Take a photo'),
                onTap: () {
                  if (isImage) {
                    pickImage(ImageSource.camera);
                  } else {
                    pickVideo(ImageSource.camera);
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from gallery'),
                onTap: () {
                  if (isImage) {
                    pickImage(ImageSource.gallery);
                  } else {
                    pickVideo(ImageSource.gallery);
                  }
                },
              ),
              SizedBox(
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
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        decoration:
            BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;
  final String postedBy;
  final int likes;

  const VideoPlayerPage({
    super.key,
    required this.videoUrl,
    required this.postedBy,
    required this.likes,
  });

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  bool isLiked = false;
  int likeCount = 0;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    likeCount = widget.likes;

    // Initialize the video player controller
    _videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
          ..initialize().then((_) {
            setState(() {
              // Initialize Chewie controller once video is ready
              _chewieController = ChewieController(
                videoPlayerController: _videoPlayerController,
                aspectRatio: _videoPlayerController
                    .value.aspectRatio, // Use video aspect ratio
                autoPlay: true,
                looping: true,
                allowMuting: true,
              );
            });
          });

    // Animation for the heart icon
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.5).animate(_controller);
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    _controller.dispose();
    super.dispose();
  }

  // Double-tap to like
  void _onDoubleTapLike() {
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });
    _controller.forward().then((_) => _controller.reverse());
  }

  // Long press to download video
  Future<void> _onLongPressDownload() async {
    try {
      Dio dio = Dio();
      var dir = await getApplicationDocumentsDirectory();
      await dio.download(widget.videoUrl, "${dir.path}/video.mp4");
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onDoubleTap: _onDoubleTapLike,
        onLongPress: _onLongPressDownload,
        child: Stack(
          children: [
            Center(
              child: _videoPlayerController.value.isInitialized
                  ? Chewie(controller: _chewieController)
                  : const Center(child: CircularProgressIndicator()),
            ),
            // Heart animation on double-tap
            Center(
              child: IgnorePointer(
                // Ignore touches on heart animation
                ignoring: true,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Icon(
                    Icons.favorite,
                    size: 100,
                    color: isLiked ? Colors.red : Colors.transparent,
                  ),
                ),
              ),
            ),
            // Video details like posted by and likes
            Positioned(
              bottom: 20,
              left: 20,
              child: Row(
                children: [
                  const Icon(Icons.person, color: Colors.white),
                  const SizedBox(width: 5),
                  Text(
                    'Posted by ${widget.postedBy}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 20),
                  const Icon(Icons.favorite, color: Colors.white),
                  const SizedBox(width: 5),
                  Text(
                    '$likeCount likes',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class ImageViewingPage extends StatefulWidget {
  final String imageUrl;

  const ImageViewingPage({
    super.key,
    required this.imageUrl,
  });

  @override
  _ImageViewingPageState createState() => _ImageViewingPageState();
}

class _ImageViewingPageState extends State<ImageViewingPage>
    with SingleTickerProviderStateMixin {
  bool isLiked = false;
  int likeCount = 0;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller for the heart icon
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.5).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Like an image on double-tap
  void _onDoubleTapLike() {
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });
    _controller.forward().then((_) => _controller.reverse());
  }

  // Single tap to show the number of likes

  // Long press to download the image
  Future<void> _onLongPressDownload() async {
    try {
      Dio dio = Dio();
      var dir = await getApplicationDocumentsDirectory();
      await dio.download(widget.imageUrl, "${dir.path}/image.jpg");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Image downloaded successfully"),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            child: Center(
              child: PhotoView(
                imageProvider: NetworkImage(widget.imageUrl),
                backgroundDecoration: const BoxDecoration(color: Colors.black),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2.0,
                loadingBuilder: (context, progress) => Center(
                  child: CircularProgressIndicator(
                    value: progress == null
                        ? null
                        : progress.cumulativeBytesLoaded /
                            progress.expectedTotalBytes!,
                  ),
                ),
                errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.error, size: 50, color: Colors.red)),
              ),
            ),
          ),
          // Heart animation when liked
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Icon(
                Icons.favorite,
                size: 100,
                color: isLiked ? Colors.red : Colors.transparent,
              ),
            ),
          ),
          // Post details (Posted by and likes)
        ],
      ),
    );
  }
}

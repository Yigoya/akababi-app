// import 'package:flutter/material.dart';
// import 'package:better_player/better_player.dart';

// class VideoPlayerPage extends StatefulWidget {
//   final String videoUrl;

//   VideoPlayerPage({required this.videoUrl});

//   @override
//   _VideoPlayerPageState createState() => _VideoPlayerPageState();
// }

// class _VideoPlayerPageState extends State<VideoPlayerPage> {
//   late BetterPlayerController _betterPlayerController;

//   @override
//   void initState() {
//     super.initState();
//     BetterPlayerConfiguration betterPlayerConfiguration =
//         BetterPlayerConfiguration(
//       aspectRatio: 16 / 9,
//       autoPlay: true,
//       controlsConfiguration: BetterPlayerControlsConfiguration(
//         enableFullscreen: true,
//         enableMute: true,
//         enablePlaybackSpeed: true,
//       ),
//       errorBuilder: (context, errorMessage) {
//         return Center(
//           child: Text(
//             "Error: $errorMessage",
//             style: TextStyle(color: Colors.red),
//           ),
//         );
//       },
//     );

//     BetterPlayerDataSource dataSource = BetterPlayerDataSource(
//       BetterPlayerDataSourceType.network,
//       widget.videoUrl,
//       cacheConfiguration: const BetterPlayerCacheConfiguration(
//         useCache: true,
//         maxCacheSize: 200 * 1024 * 1024, // 200 MB
//         maxCacheFileSize: 50 * 1024 * 1024, // 50 MB per file
//       ),
//     );

//     _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
//     _betterPlayerController.setupDataSource(dataSource);
//   }

//   @override
//   void dispose() {
//     _betterPlayerController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Video Player"),
//         backgroundColor: Colors.black,
//       ),
//       body: Column(
//         children: [
//           AspectRatio(
//             aspectRatio: 16 / 9,
//             child: BetterPlayer(
//               controller: _betterPlayerController,
//             ),
//           ),
//           Expanded(
//             child: Container(
//               padding: EdgeInsets.all(16),
//               child: Text(
//                 "Video Description or Comments Section",
//                 style: TextStyle(fontSize: 16),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

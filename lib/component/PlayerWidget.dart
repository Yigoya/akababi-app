import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerScreen extends StatefulWidget {
  final String audioUrl;

  const AudioPlayerScreen({super.key, required this.audioUrl});
  @override
  _AudioPlayerScreenState createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late AudioPlayer _audioPlayer;
  late Stream<Duration?> _positionStream;
  late Stream<Duration?> _durationStream;
  late Future<void> _initializeFuture;
  late Stream<bool> _playingStream;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initializeFuture = _initializePlayer();
    _positionStream = _audioPlayer.positionStream;
    _durationStream = _audioPlayer.durationStream;
    _playingStream = _audioPlayer.playingStream;
  }

  Future<void> _initializePlayer() async {
    try {
      await _audioPlayer.setUrl(widget.audioUrl); // Replace with your audio URL
    } catch (e) {
      print("Error initializing audio player: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: FutureBuilder<void>(
      future: _initializeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder<Duration?>(
                stream: _positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  return StreamBuilder<Duration?>(
                    stream: _durationStream,
                    builder: (context, snapshot) {
                      final duration = snapshot.data ?? Duration.zero;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            StreamBuilder<bool>(
                              stream: _playingStream,
                              builder: (context, snapshot) {
                                final isPlaying = snapshot.data ?? false;
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Play/Pause Button
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const LinearGradient(
                                          colors: [
                                            Colors.deepPurpleAccent,
                                            Colors.purple
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          isPlaying
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                          color: Colors.white,
                                        ),
                                        iconSize: 30.0,
                                        onPressed: () {
                                          if (isPlaying) {
                                            _audioPlayer.pause();
                                          } else {
                                            _audioPlayer.play();
                                          }
                                        },
                                      ),
                                    ),
                                    // const SizedBox(
                                    //     width: 20), // Spacing between buttons
                                    // // Stop Button
                                    // Container(
                                    //   decoration: BoxDecoration(
                                    //     shape: BoxShape.circle,
                                    //     color: Colors.redAccent,
                                    //     boxShadow: [
                                    //       BoxShadow(
                                    //         color:
                                    //             Colors.black.withOpacity(0.2),
                                    //         blurRadius: 10,
                                    //         offset: const Offset(0, 5),
                                    //       ),
                                    //     ],
                                    //   ),
                                    //   child: IconButton(
                                    //     icon: const Icon(Icons.stop,
                                    //         color: Colors.white),
                                    //     iconSize: 40.0,
                                    //     onPressed: () {
                                    //       _audioPlayer.stop();
                                    //       _audioPlayer
                                    //           .seek(const Duration(seconds: 0));
                                    //     },
                                    //   ),
                                    // ),
                                  ],
                                );
                              },
                            ),
                            Expanded(
                              child: Slider(
                                value: position.inSeconds.toDouble(),
                                max: duration.inSeconds.toDouble(),
                                onChanged: (value) {
                                  _audioPlayer
                                      .seek(Duration(seconds: value.toInt()));
                                },
                              ),
                            ),
                            Text(
                              '${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')} / ${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),

              // Padding(
              //   padding: const EdgeInsets.all(16.0),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       const Icon(Icons.volume_up),
              //       Expanded(
              //         child: StreamBuilder<double>(
              //           stream: _audioPlayer.volumeStream,
              //           builder: (context, snapshot) {
              //             final volume = snapshot.data ?? 1.0;
              //             return Slider(
              //               value: volume,
              //               onChanged: (value) {
              //                 _audioPlayer.setVolume(value);
              //               },
              //               min: 0.0,
              //               max: 1.0,
              //             );
              //           },
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          );
        } else if (snapshot.hasError) {
          return const Text("Error loading audio");
        } else {
          return const CircularProgressIndicator();
        }
      },
    ));
  }
}

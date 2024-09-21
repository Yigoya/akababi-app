import 'package:akababi/bloc/cubit/post_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

class Reaction extends StatefulWidget {
  final bool? isSinglePost;
  final dynamic reaction;
  final int id;
  final int likes;
  const Reaction(
      {super.key,
      this.reaction,
      required this.id,
      required this.likes,
      this.isSinglePost});

  @override
  State<Reaction> createState() => _ReactionState();
}

class _ReactionState extends State<Reaction>
    with SingleTickerProviderStateMixin {
  List<String> emojis = [
    'assets/image/nonlike.png',
    'assets/image/like.png',
    'assets/image/love.png',
    'assets/image/haha.png',
    'assets/image/wow.png',
    'assets/image/sad.png',
    'assets/image/angry.png'
  ];
  List<String?> reactionType = [
    null,
    'like',
    'love',
    'haha',
    'wow',
    'sad',
    'angry'
  ];
  int index = 0;
  double iconSize = 30;
  double iconSize2 = 16;
  int like = 0;
  late Map<String, dynamic>? reaction;
  final logger = Logger();
  double _scale = 1.0;
  late AnimationController _controller;
  
  @override
  void initState() {
    setState(() {
      reaction = widget.reaction;
    });
    logger.i(reaction);
    _controller = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {
          _scale = 1 - _controller.value;
        });
      });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant Reaction oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      reaction = widget.reaction;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    if (reaction == null) {
      index = 0;
    } else {
      switch (reaction!['reaction_type']) {
        case 'like':
          index = 1;
          break;
        case 'love':
          index = 2;
          break;
        case 'haha':
          index = 3;
          break;
        case 'wow':
          index = 4;
          break;
        case 'sad':
          index = 5;
          break;
        case 'angry':
          index = 6;
          break;
        default:
          index = 0;
      }
    }

    return Stack(
      children: [
        GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onLongPress: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            react(1);
                            Navigator.of(context).pop();
                          },
                          child: Image.asset(
                            emojis[1],
                            width: iconSize,
                            height: iconSize,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            react(2);
                            Navigator.of(context).pop();
                          },
                          child: Image.asset(
                            emojis[2],
                            width: iconSize,
                            height: iconSize,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            react(3);
                            Navigator.of(context).pop();
                          },
                          child: Image.asset(
                            emojis[3],
                            width: iconSize,
                            height: iconSize,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            react(4);
                            Navigator.of(context).pop();
                          },
                          child: Image.asset(
                            emojis[4],
                            width: iconSize,
                            height: iconSize,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            react(5);
                            Navigator.of(context).pop();
                          },
                          child: Image.asset(
                            emojis[5],
                            width: iconSize,
                            height: iconSize,
                          ),
                        )
                        // Add more icons here
                      ],
                    ),
                  ),
                );
              },
            );
          },
          onTap: () {
            if (index == 0) {
              BlocProvider.of<PostCubit>(context).setReaction({
                'post_id': widget.id,
                'reaction_type': reactionType[1],
              });
              if (widget.isSinglePost == true) {
                setState(() {
                  reaction = {'reaction_type': reactionType[1]};
                  like += 1;
                });
              }

              BlocProvider.of<PostCubit>(context).updateMapInList(widget.id, {
                'num_likes': widget.likes + 1,
                'reaction': {
                  ...reaction ?? {},
                  'reaction_type': reactionType[1]
                }
              });
            } else {
              BlocProvider.of<PostCubit>(context).setReaction({
                'post_id': widget.id,
                'reaction_type': reactionType[0],
              });
              if (widget.isSinglePost == true) {
                setState(() {
                  reaction = {'reaction_type': null};
                  like -= 1;
                });
              }

              BlocProvider.of<PostCubit>(context).updateMapInList(widget.id, {
                'num_likes': widget.likes - 1,
                'reaction': {
                  ...reaction ?? {},
                  'reaction_type': reactionType[0]
                }
              });
            }
          },
          child: Transform.scale(
            scale: _scale,
            child: Container(
              margin: EdgeInsets.only(left: 16, top: 5, bottom: 5),
              padding: EdgeInsets.only(left: 24, right: 24, top: 5, bottom: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.12),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Image.asset(
                    emojis[index],
                    width: index == 0 || index == 1 ? iconSize2 : 24,
                    height: index == 0 || index == 1 ? iconSize2 : 24,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    (widget.likes + like).toString(),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w400),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void react(int i) {
    print(reaction);
    if (widget.isSinglePost == true) {
      if (reaction == null) {
        setState(() {
          reaction = {'reaction_type': reactionType[i]};
          like += 1;
        });
      } else {
        setState(() {
          if (reaction!['reaction_type'] == null) {
            like += 1;
          }
          reaction!['reaction_type'] = reactionType[i];
        });
      }
    }
    // setState(() {
    //   reaction!['reaction_type'] = reactionType[i];
    //   if (index == 0) {
    //     like += 1;
    //   }
    // });
    BlocProvider.of<PostCubit>(context).setReaction({
      'post_id': widget.id,
      'reaction_type': reactionType[i],
    });
    if (reaction == null) {
      BlocProvider.of<PostCubit>(context).updateMapInList(widget.id, {
        'num_likes': widget.likes + 1,
        'reaction': {'post_id': widget.id, 'reaction_type': null}
      });
    } else {
      BlocProvider.of<PostCubit>(context).updateMapInList(widget.id, {
        'num_likes': like == 0 && reactionType[i] == null
            ? widget.likes + 1
            : widget.likes,
        'reaction': {
          ...reaction as Map<String, dynamic>,
          'reaction_type': reactionType[i]
        }
      });
    }
  }
}

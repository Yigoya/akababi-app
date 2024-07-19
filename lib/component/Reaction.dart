import 'package:akababi/bloc/cubit/post_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Reaction extends StatefulWidget {
  final dynamic reaction;
  final int id;
  final int likes;
  const Reaction(
      {super.key, this.reaction, required this.id, required this.likes});

  @override
  State<Reaction> createState() => _ReactionState();
}

class _ReactionState extends State<Reaction> {
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
  double iconSize = 24;
  int like = 0;
  var reaction;
  @override
  void initState() {
    reaction = widget.reaction;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (reaction == null) {
    } else {
      switch (reaction['reaction_type']) {
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
        Container(
          child: Row(
            children: [
              GestureDetector(
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
                    print({
                      'post_id': widget.id,
                      'reaction_type': reactionType[1],
                    });
                    BlocProvider.of<PostCubit>(context).setReaction({
                      'post_id': widget.id,
                      'reaction_type': reactionType[1],
                    });

                    setState(() {
                      reaction = {'reaction_type': reactionType[1]};
                      like += 1;
                    });
                  } else {
                    BlocProvider.of<PostCubit>(context).setReaction({
                      'post_id': widget.id,
                      'reaction_type': reactionType[0],
                    });
                    like -= 1;
                    setState(() {
                      reaction['reaction_type'] = null;
                    });
                  }
                },
                child: Image.asset(
                  emojis[index],
                  width: iconSize,
                  height: iconSize,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                (widget.likes + like).toString(),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
              )
            ],
          ),
        ),
      ],
    );
  }

  void react(int i) {
    print(reaction);
    setState(() {
      reaction['reaction_type'] = reactionType[i];
      if (index == 0) {
        like += 1;
      }
    });
    BlocProvider.of<PostCubit>(context).setReaction({
      'post_id': widget.id,
      'reaction_type': reactionType[i],
    });
  }
}

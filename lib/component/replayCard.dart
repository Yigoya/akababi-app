import 'package:akababi/bloc/cubit/comment_cubit.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

class ReplyCards extends StatefulWidget {
  final Map<String, dynamic> reply;
  final void Function(int, String, int) editReply;
  final void Function(int, String, int) setReply;

  const ReplyCards(
      {super.key,
      required this.reply,
      required this.editReply,
      required this.setReply});

  @override
  State<ReplyCards> createState() => _ReplyCardsState();
}

class _ReplyCardsState extends State<ReplyCards> {
  bool isLiked = false;
  int likes = 0;

  void initState() {
    super.initState();
    setState(() {
      isLiked = widget.reply['liked'] ?? false;
      likes = widget.reply['likes'] ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 152,
      width: 300,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(
                '${AuthRepo.SERVER}/${widget.reply['profile_picture']}'),
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 240,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.reply['full_name'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(widget.reply['timeAgo']),
                    SizedBox(height: 10),
                    Text(widget.reply['content']),
                  ],
                ),
              ),
              Row(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: isLiked
                            ? Icon(
                                Icons.favorite_rounded,
                                color: Colors.red,
                              )
                            : Icon(Icons.favorite_border_rounded),
                        onPressed: () async {
                          final res =
                              await BlocProvider.of<CommentCubit>(context)
                                  .setLike(widget.reply['id'], 'reply');
                          if (res) {
                            setState(() {
                              isLiked = !isLiked;
                              if (isLiked) {
                                likes += 1;
                              } else {
                                likes -= 1;
                              }
                            });
                          }
                        },
                      ),
                      Text(likes.toString()),
                      IconButton(
                        icon: Icon(Icons.reply_outlined),
                        onPressed: () {
                          widget.setReply(
                              widget.reply['comment_id'],
                              widget.reply['full_name'],
                              widget.reply['user_id']);
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          FeatherIcons.edit,
                          size: 20,
                        ),
                        onPressed: () {
                          widget.editReply(
                              widget.reply['id'],
                              widget.reply['content'],
                              widget.reply['comment_id']);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          BlocProvider.of<CommentCubit>(context).deleteReply(
                              widget.reply['comment_id'], widget.reply['id']);
                        },
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

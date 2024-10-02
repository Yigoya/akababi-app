import 'package:akababi/bloc/cubit/comment_cubit.dart';
import 'package:akababi/component/replayCard.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

class CommentCards extends StatefulWidget {
  final Map<String, dynamic> comment;
  final List<Map<String, dynamic>>? replies;
  final void Function(int, String) editComment;
  final void Function(int, String, int) editReply;
  final void Function(int, String, int) setReply;

  const CommentCards(
      {super.key,
      required this.comment,
      this.replies,
      required this.editComment,
      required this.editReply,
      required this.setReply});

  @override
  State<CommentCards> createState() => _CommentCardsState();
}

class _CommentCardsState extends State<CommentCards> {
  bool isLiked = false;
  int likes = 0;
  int replies = 0;
  @override
  void initState() {
    super.initState();
    setState(() {
      isLiked = widget.comment['liked'] ?? false;
      likes = widget.comment['likes'] ?? 0;
      replies = widget.comment['replies'] ?? 0;
    });
  }

  @override
  void didUpdateWidget(covariant CommentCards oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      if (widget.replies != null) {
        replies = widget.replies!.length;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(
                '${AuthRepo.SERVER}/${widget.comment['profile_picture']}'),
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 310,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.comment['full_name'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(widget.comment['timeAgo']),
                    SizedBox(height: 10),
                    Text(widget.comment['content']),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    .setLike(widget.comment['id'], 'comment');
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
                            if (replies > 0) {
                              BlocProvider.of<CommentCubit>(context)
                                  .getReplies(widget.comment['id']);
                            }
                            widget.setReply(
                                widget.comment['id'],
                                widget.comment['full_name'],
                                widget.comment['user_id']);
                          },
                        ),
                        replies != 0
                            ? GestureDetector(
                                onTap: () {
                                  BlocProvider.of<CommentCubit>(context)
                                      .getReplies(widget.comment['id']);
                                },
                                child: Text('$replies replies'))
                            : SizedBox.shrink(),
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
                            widget.editComment(widget.comment['id'],
                                widget.comment['content']);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            BlocProvider.of<CommentCubit>(context)
                                .deleteComment(widget.comment['id']);
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
              widget.replies != null
                  ? SizedBox(
                      height: 152 * widget.replies!.length.toDouble(),
                      width: 300,
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: widget.replies!.length,
                          physics: ClampingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return ReplyCards(
                              reply: widget.replies![index],
                              setReply: widget.setReply,
                              editReply: widget.editReply,
                            );
                          }),
                    )
                  : SizedBox.shrink()
            ],
          ),
        ],
      ),
    );
  }
}

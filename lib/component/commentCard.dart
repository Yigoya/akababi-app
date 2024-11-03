import 'package:akababi/bloc/cubit/comment_cubit.dart';
import 'package:akababi/component/replayCard.dart';
import 'package:akababi/model/User.dart';
import 'package:akababi/pages/post/image_view.dart';
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
  bool isExpanded = false; // Track if the comment is expanded
  double replyExpandedLength = 0; // Track if the comment is expanded
  User? user;
  late List<double> replyExpanded;
  bool show_reply = false;

  @override
  void initState() {
    super.initState();
    replyExpanded =
        widget.replies != null ? List.filled(widget.replies!.length, 0) : [];
    initUser();
    setState(() {
      isLiked = widget.comment['liked'] ?? false;
      likes = widget.comment['likes'] ?? 0;
      replies = widget.comment['replies'] ?? 0;
    });
  }

  void initUser() async {
    User? u = await AuthRepo().user;
    setState(() {
      user = u;
    });
  }

  bool replyHasImage(Map<String, dynamic> reply) {
    return reply['image'] != null && reply['image'].isNotEmpty;
  }

  int countRepliesWithImages(List<Map<String, dynamic>> replies) {
    return replies.where(replyHasImage).length;
  }

  void relpyExpanded(int index, double value) {
    replyExpanded[index] = value;
    double total = replyExpanded.reduce((a, b) => a + b);
    setState(() {
      replyExpandedLength = total;
    });
  }

  @override
  void didUpdateWidget(covariant CommentCards oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      if (widget.replies != null) {
        replies = widget.replies!.length;
        replyExpanded = widget.replies != null
            ? List.filled(widget.replies!.length, 0)
            : [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String content = widget.comment['content'];
    bool shouldShowSeeMore = content.length > 100; // Set the character limit

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(
                '${AuthRepo.SERVER}/${widget.comment['profile_picture']}'),
          ),
          const SizedBox(width: 10),
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
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(widget.comment['timeAgo']),
                    const SizedBox(height: 10),
                    shouldShowSeeMore && !isExpanded
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${content.substring(0, 100)}...',
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isExpanded = true; // Expand the text
                                  });
                                },
                                child: const Text(
                                  'See more',
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(content),
                              if (shouldShowSeeMore)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isExpanded = false; // Collapse the text
                                    });
                                  },
                                  child: const Text(
                                    'See less',
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                    if (widget.comment['image'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(
                                    builder: (context) => ImageViewingPage(
                                        imageUrl:
                                            '${AuthRepo.SERVER}/${widget.comment['image']}')));
                          },
                          child: Image.network(
                            '${AuthRepo.SERVER}/${widget.comment['image']}',
                            height: 300,
                            width: 300,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: isLiked
                              ? const Icon(
                                  Icons.favorite_rounded,
                                  color: Colors.red,
                                )
                              : const Icon(Icons.favorite_border_rounded),
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
                          icon: const Icon(Icons.reply_outlined),
                          onPressed: () {
                            if (replies > 0) {
                              if (!show_reply) {
                                BlocProvider.of<CommentCubit>(context)
                                    .getReplies(widget.comment['id']);
                              }

                              setState(() {
                                show_reply = !show_reply;
                              });
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
                                  if (!show_reply) {
                                    BlocProvider.of<CommentCubit>(context)
                                        .getReplies(widget.comment['id']);
                                  }

                                  setState(() {
                                    show_reply = !show_reply;
                                  });
                                },
                                child: Row(
                                  children: [
                                    Text('$replies replies'),
                                    Icon(
                                      show_reply
                                          ? Icons.arrow_drop_up_outlined
                                          : Icons.arrow_drop_down_outlined,
                                      size: 20,
                                    ),
                                  ],
                                ))
                            : const SizedBox.shrink(),
                      ],
                    ),
                    (user != null) && (user!.id == widget.comment['user_id'])
                        ? Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  FeatherIcons.edit,
                                  size: 20,
                                ),
                                onPressed: () {
                                  widget.editComment(widget.comment['id'],
                                      widget.comment['content']);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  BlocProvider.of<CommentCubit>(context)
                                      .deleteComment(widget.comment['id']);
                                },
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
              widget.replies != null
                  ? SizedBox(
                      height: show_reply
                          ? (152 * widget.replies!.length.toDouble()) +
                              (200 * countRepliesWithImages(widget.replies!)) +
                              replyExpandedLength
                          : 0,
                      width: 300,
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: widget.replies!.length,
                          physics: const ClampingScrollPhysics(),
                          itemBuilder: (context, index) {
                            if (show_reply) {
                              return ReplyCards(
                                index: index,
                                replyExpanded: relpyExpanded,
                                hasImage: replyHasImage(widget.replies![index]),
                                reply: widget.replies![index],
                                setReply: widget.setReply,
                                editReply: widget.editReply,
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          }),
                    )
                  : const SizedBox.shrink()
            ],
          ),
        ],
      ),
    );
  }
}

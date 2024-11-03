import 'package:akababi/bloc/cubit/comment_cubit.dart';
import 'package:akababi/pages/post/image_view.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:akababi/model/User.dart';

class ReplyCards extends StatefulWidget {
  final bool hasImage;
  final int index;
  final Map<String, dynamic> reply;
  final void Function(int, String, int) editReply;
  final void Function(int, String, int) setReply;
  final void Function(int, double) replyExpanded;
  const ReplyCards(
      {super.key,
      required this.reply,
      required this.editReply,
      required this.setReply,
      required this.hasImage,
      required this.replyExpanded,
      required this.index});

  @override
  State<ReplyCards> createState() => _ReplyCardsState();
}

class _ReplyCardsState extends State<ReplyCards> {
  bool isLiked = false;
  int likes = 0;
  User? user;
  bool isExpanded = false;
  @override
  void initState() {
    super.initState();
    initUser();
    setState(() {
      isLiked = widget.reply['liked'] ?? false;
      likes = widget.reply['likes'] ?? 0;
    });
  }

  void initUser() async {
    User? u = await AuthRepo().user;
    setState(() {
      user = u;
    });
  }

  @override
  Widget build(BuildContext context) {
    String content = widget.reply['content'];
    bool shouldShowSeeMore = content.length > 100;

    return SizedBox(
      // Dynamically adjust height
      width: 300,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(
                '${AuthRepo.SERVER}/${widget.reply['profile_picture']}'),
          ),
          const SizedBox(width: 10),
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
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(widget.reply['timeAgo']),
                    const SizedBox(height: 10),
                    shouldShowSeeMore && !isExpanded
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    height: 1.3,
                                    fontSize:
                                        12.0, // Add a default font size and color
                                    color: Colors
                                        .black, // Make sure text is visible
                                  ),
                                  children: [
                                    TextSpan(
                                      text: widget.reply['reply_to'] + '  ',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '${content.substring(0, 100)}...',
                                    ),
                                  ],
                                ),
                                softWrap: true, // Allow wrapping if needed
                                overflow:
                                    TextOverflow.ellipsis, // Handle overflow
                              ),
                              GestureDetector(
                                onTap: () {
                                  double length = calculateTextHeight(
                                    content,
                                    230,
                                    const TextStyle(
                                      height: 1.3,
                                      fontSize:
                                          12.0, // Add a default font size and color
                                      color: Colors
                                          .black, // Make sure text is visible
                                    ),
                                  );
                                  widget.replyExpanded(widget.index, length);
                                  setState(() {
                                    isExpanded = true;
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
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    height: 1.3,
                                    fontSize: 12.0,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: widget.reply['reply_to'] + '  ',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: content,
                                    ),
                                  ],
                                ),
                                softWrap: true,
                              ),
                              if (shouldShowSeeMore)
                                GestureDetector(
                                  onTap: () {
                                    widget.replyExpanded(widget.index, 0);
                                    setState(() {
                                      isExpanded = false;
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
                    if (widget.reply['image'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(
                                    builder: (context) => ImageViewingPage(
                                        imageUrl:
                                            '${AuthRepo.SERVER}/${widget.reply['image']}')));
                          },
                          child: Image.network(
                            '${AuthRepo.SERVER}/${widget.reply['image']}',
                            height: 200,
                            width: 240,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                  ],
                ),
              ),
              Row(
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
                        icon: const Icon(Icons.reply_outlined),
                        onPressed: () {
                          widget.setReply(
                              widget.reply['comment_id'],
                              widget.reply['full_name'],
                              widget.reply['user_id']);
                        },
                      ),
                    ],
                  ),
                  (user != null) && (user!.id == widget.reply['user_id'])
                      ? Row(
                          children: [
                            IconButton(
                              icon: const Icon(
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
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                BlocProvider.of<CommentCubit>(context)
                                    .deleteReply(widget.reply['comment_id'],
                                        widget.reply['id']);
                              },
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  double calculateTextHeight(String text, double maxWidth, TextStyle style) {
    // Create a TextSpan with the given text and style
    final TextSpan textSpan = TextSpan(text: text, style: style);

    // Create a TextPainter object to measure the text
    final TextPainter textPainter = TextPainter(
      text: textSpan,
      maxLines: null, // Allow unlimited lines for the calculation
      textDirection: TextDirection.ltr,
    );

    // Layout the text within the specified width constraint
    textPainter.layout(maxWidth: maxWidth);

    // Return the calculated height
    return textPainter.size.height;
  }
}

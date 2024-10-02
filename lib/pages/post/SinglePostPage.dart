import 'package:akababi/bloc/cubit/post_cubit.dart' as PostCubit;
import 'package:akababi/bloc/cubit/single_post_cubit.dart';
import 'package:akababi/component/PostItem.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:akababi/skeleton/postItemSkeleton.dart';
import 'package:akababi/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SinglePostPage extends StatefulWidget {
  final int id;
  final bool? isRepost;
  const SinglePostPage({super.key, required this.id, this.isRepost});

  @override
  State<SinglePostPage> createState() => _SinglePostPageState();
}

class _SinglePostPageState extends State<SinglePostPage> {
  String title = 'Post';
  int commentCount = 0;
  @override
  void initState() {
    super.initState();
    if (widget.isRepost != null && widget.isRepost == true) {
      context.read<SinglePostCubit>().getRepostById(widget.id);
    } else {
      context.read<SinglePostCubit>().getPostById(widget.id);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  var longitute = 7.49508;
  var latitude = 9.05785;
  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(title),
        ),
        body: SingleChildScrollView(
          child: BlocConsumer<SinglePostCubit, SinglePostState>(
            listener: (context, state) {
              if (state is SinglePostLoaded) {
                setState(() {
                  commentCount = state.post['comment'].length;
                });
              }
            },
            builder: (context, state) {
              if (state is SinglePostLoaded) {
                var comments = state.post['comment'] as List<dynamic>;
                return Column(
                  children: [
                    PostItem(post: state.post, isSinglePost: true),
                    (state.post['latitude'] != null) &&
                            (state.post['longitude'] != null)
                        ? GestureDetector(
                            onTap: () {
                              openGoogleMaps(
                                state.post['longitude'],
                                state.post['latitude'],
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(
                                  left: 16, right: 16, bottom: 16),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "See in map",
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(
                                    Icons.map,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                    state.post['comment'] != null
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              return CommentCard(comment: comments[index]);
                            })
                        : Container(),
                  ],
                );
              } else if (state is SinglePostLoading) {
                return PostItemSkeleton();
              } else if (state is PostError) {
                return Center(
                  child: Text(state.error),
                );
              }
              return PostItemSkeleton(); // Placeholder widget if the state is not SinglePostLoaded
            },
          ),
        ),
        bottomNavigationBar: Container(
          padding: MediaQuery.of(context).viewInsets,
          decoration: BoxDecoration(
            color: Colors
                .grey.shade900, // Background color for the comment section
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      filled: true,
                      fillColor: Colors.grey.shade800,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    maxLines:
                        null, // Allows the comment box to expand with input
                  ),
                ),
                const SizedBox(width: 8.0),
                CircleAvatar(
                  backgroundColor: Colors.deepPurpleAccent,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      // context.read<SinglePostCubit>().setComment({
                      //   'post_id': widget.id,
                      //   'content': controller.text,
                      // });
                      // BlocProvider.of<PostCubit.PostCubit>(context)
                      //     .updateMapInList(widget.id, {
                      //   'comments': commentCount + 1,
                      // });
                      controller.clear();
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

class CommentCard extends StatelessWidget {
  final Map<String, dynamic> comment; // comment data passed from backend

  const CommentCard({Key? key, required this.comment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20.0,
            backgroundImage: comment['user']['profile_picture'] != null
                ? NetworkImage(
                    '${AuthRepo.SERVER}/${comment['user']['profile_picture']}',
                  ) as ImageProvider
                : AssetImage('assets/image/defaultprofile.png'), // User avatar
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '@${comment['user']['username']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  comment['content'], // Comment content
                  style: const TextStyle(fontSize: 15.0),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    // Text(
                    //   'Like',
                    //   style: TextStyle(
                    //     fontSize: 14.0,
                    //     color: Theme.of(context).primaryColor,
                    //   ),
                    // ),
                    // const SizedBox(width: 16.0),
                    // Text(
                    //   'Reply',
                    //   style: TextStyle(
                    //     fontSize: 14.0,
                    //     color: Theme.of(context).primaryColor,
                    //   ),
                    // ),
                    // const SizedBox(width: 16.0),
                    Text(
                      formatDateTime(
                          comment['created_at']), // Timestamp, e.g., '2h ago'
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

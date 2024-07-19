import 'package:akababi/bloc/cubit/single_post_cubit.dart';
import 'package:akababi/component/PostItem.dart';
import 'package:akababi/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SinglePostPage extends StatefulWidget {
  final int id;
  const SinglePostPage({super.key, required this.id});

  @override
  State<SinglePostPage> createState() => _SinglePostPageState();
}

class _SinglePostPageState extends State<SinglePostPage> {
  String title = 'Post';
  @override
  void initState() {
    super.initState();
    context.read<SinglePostCubit>().getPostById(widget.id);
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
          child: BlocBuilder<SinglePostCubit, SinglePostState>(
            builder: (context, state) {
              if (state is PostLoaded) {
                var comments = state.post['comment'] as List<dynamic>;
                return Column(
                  children: [
                    PostItem(post: state.post),
                    GestureDetector(
                      onTap: () {
                        openGoogleMaps(
                          state.post['longitude'],
                          state.post['latitude'],
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "See in map",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            ),
                            SizedBox(width: 10),
                            Icon(
                              Icons.map,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                    state.post['comment'] != null
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(comments[index]['content']),
                                subtitle: Text(comments[index]['created_at']),
                              );
                            })
                        : Container(),
                  ],
                );
              } else if (state is PostLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Container(); // Placeholder widget if the state is not SinglePostLoaded
            },
          ),
        ),
        bottomNavigationBar: Container(
          padding: MediaQuery.of(context).viewInsets,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Add a comment',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  context.read<SinglePostCubit>().setComment({
                    'post_id': widget.id,
                    'content': controller.text,
                  });
                },
              ),
            ],
          ),
        ));
  }
}

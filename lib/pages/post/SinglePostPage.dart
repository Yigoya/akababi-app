import 'package:akababi/bloc/cubit/post_cubit.dart';
import 'package:akababi/component/PostItem.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SinglePostPage extends StatefulWidget {
  final int id;
  const SinglePostPage({super.key, required this.id});

  @override
  State<SinglePostPage> createState() => _SinglePostPageState();
}

class _SinglePostPageState extends State<SinglePostPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<PostCubit>()
        .getPostById(widget.id); // Replace 1 with the actual post ID
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('Single Post Page'),
        ),
        body: SingleChildScrollView(
          child: BlocBuilder<PostCubit, PostState>(
            builder: (context, state) {
              if (state is SinglePostLoaded) {
                var comments = state.post['comment'] as List<dynamic>;
                return Column(
                  children: [
                    PostItem(post: state.post),
                    state.post['comment'] != null
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
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
                return Center(
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
                  decoration: InputDecoration(
                    hintText: 'Add a comment',
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  context.read<PostCubit>().setComment({
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

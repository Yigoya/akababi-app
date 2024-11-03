import 'package:akababi/bloc/cubit/post_cubit.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:flutter/material.dart';
import 'package:akababi/model/User.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditPost extends StatefulWidget {
  final Map<String, dynamic> post;
  final bool? isRepost;
  const EditPost({super.key, required this.post, this.isRepost});

  @override
  State<EditPost> createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {
  // Define the missing variables and classes
  User? user;
  final TextEditingController controller = TextEditingController();
  String dropdownValue = 'public';

  @override
  void initState() {
    super.initState();
    controller.text = widget.isRepost == true
        ? widget.post['repost_content']
        : widget.post['content'];
    getUser();
  }

  void getUser() async {
    final u = await AuthRepo().user;

    setState(() {
      user = u;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isRepost == true ? 'Edit Repost' : 'Edit Post'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 16.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      (user != null) && (user?.profile_picture != null)
                          ? NetworkImage(
                              '${AuthRepo.SERVER}/${user!.profile_picture!}')
                          : const AssetImage('assets/image/defaultprofile.png')
                              as ImageProvider,
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(user?.fullname ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 22,
                          color: Colors.grey[800],
                        )),
                    Row(
                      children: [
                        widget.isRepost != true
                            ? Container(
                                height: 30,
                                padding: const EdgeInsets.only(left: 15),
                                decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8)),
                                child: DropdownButton<String>(
                                  dropdownColor: Colors.amber,
                                  iconSize: 35,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(16)),
                                  value: dropdownValue,
                                  underline: const SizedBox(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      dropdownValue = newValue!;
                                    });
                                  },
                                  items: <String>[
                                    'public',
                                    'private',
                                    'friends_only'
                                  ].map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18),
                                      ),
                                    );
                                  }).toList(),
                                ))
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              autofocus: true,
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Enter your post',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                if (widget.isRepost != true) {
                  final res =
                      await BlocProvider.of<PostCubit>(context).editPost({
                    'post_id': widget.post['post_id'],
                    'content': controller.text,
                    'privacy_setting': dropdownValue
                  });
                  if (res) {
                    BlocProvider.of<PostCubit>(context).updateMapInList(
                        widget.post['post_id'], {
                      'content': controller.text,
                      'privacy_setting': dropdownValue
                    });
                    Navigator.pop(context);
                  }
                } else {
                  final res =
                      await BlocProvider.of<PostCubit>(context).editRepost({
                    'post_id': widget.post['repost_id'],
                    'content': controller.text,
                  });
                  if (res) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Post edited'),
                        padding: EdgeInsets.only(bottom: 20, top: 10, left: 10),
                      ),
                    );
                    BlocProvider.of<PostCubit>(context).updateMapInList(
                        widget.post['repost_id'],
                        {
                          'repost_content': controller.text,
                        },
                        isRepost: true);
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('Modify'),
            ),
          ],
        ),
      ),
    );
  }
}

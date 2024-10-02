import 'package:akababi/bloc/cubit/person_cubit.dart';
import 'package:akababi/model/User.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostFollowButton extends StatefulWidget {
  final String friendshipStatus;
  final int id;

  PostFollowButton({required this.friendshipStatus, required this.id});

  @override
  State<PostFollowButton> createState() => _PostFollowButtonState();
}

class _PostFollowButtonState extends State<PostFollowButton> {
  String status = 'Follow';
  User? _user;
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    final user = await AuthRepo().user;
    setState(() {
      _user = user;
      status = widget.friendshipStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _user != null && _user!.id != widget.id
        ? GestureDetector(
            onTap: () async {
              if (status == 'Follow') {
                final res = await BlocProvider.of<PersonCubit>(context)
                    .friendRequest(widget.id);
                setState(() {
                  status = res;
                });
              } else if (status == 'Follow Back') {
                final res = await BlocProvider.of<PersonCubit>(context)
                    .friendRequestRespond(id: widget.id, response: 'accepted');
                setState(() {
                  status = res;
                });
              } else if (status == 'Friends') {
                final res = await BlocProvider.of<PersonCubit>(context)
                    .friendRequestRespond(id: widget.id, response: 'pending');
                setState(() {
                  status = res;
                });
              } else if (status == 'Following') {
                final res = await BlocProvider.of<PersonCubit>(context)
                    .removeFriendRequest(
                  widget.id,
                );
                setState(() {
                  status = res;
                });
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: status == 'Follow' ? Colors.red : null,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: Colors.red,
                ),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: status == 'Follow' ? Colors.white : Colors.red,
                ),
              ),
            ),
          )
        : SizedBox.shrink();
  }
}

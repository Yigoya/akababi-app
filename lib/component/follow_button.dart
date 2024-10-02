import 'package:akababi/bloc/cubit/person_cubit.dart';
import 'package:akababi/model/User.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FollowButton extends StatefulWidget {
  final String friendshipStatus;
  final int id;

  FollowButton({required this.friendshipStatus, required this.id});

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
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
        ? ElevatedButton(
            onPressed: () async {
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Red color for the button
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Rounded corners
              ),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          )
        : SizedBox.shrink();
  }
}

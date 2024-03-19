import 'package:akababi/bloc/auth/auth_bloc.dart';
import 'package:akababi/bloc/auth/auth_event.dart';
import 'package:akababi/bloc/auth/auth_state.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context);
    return Scaffold(body: BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Container(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 100,
                ),
                state.user!.profile_picture != null
                    ? ClipOval(
                        child: Image.network(
                          '${AuthRepo.SERVER}/files/${state.user!.profile_picture}',
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              IconButton(
                                  onPressed: () {
                                    authBloc.add(ProfileEvent(context));
                                  },
                                  icon: Icon(
                                    Icons.image,
                                    size: 50,
                                  )),
                        ),
                      )
                    : IconButton(
                        onPressed: () {
                          authBloc.add(ProfileEvent(context));
                        },
                        icon: Icon(
                          Icons.image,
                          size: 50,
                        )),
                SizedBox(
                  height: 10,
                ),
                Text(
                  state.user!.fullname,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                Text(
                  '@${state.user!.username}',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
                )
              ],
            ),
          ),
        );
      },
    ));
  }
}

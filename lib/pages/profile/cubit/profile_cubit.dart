import 'package:akababi/model/User.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:akababi/repositiory/UserRepo.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());
  final authRepo = AuthRepo();
  final userRepo = UserRepo();

  Future<void> logOut(BuildContext context) async {
    final pref = await SharedPreferences.getInstance();
    pref.remove('imagePath');
    emit(ProfileInitial());
    await Navigator.pushNamedAndRemoveUntil(
        context, '/login', (route) => false);
    await authRepo.removeUser();
  }

  Future<void> getUser() async {
    User? user = await authRepo.user;
    if (user != null) {
      final friends = await userRepo.getUserFriend();

      final posts = await userRepo.getUserPost();
      final likedPosts = await userRepo.getUserLikedPost();
      print(friends);
      emit(ProfileLoaded(user, posts, friends, likedPosts));
    } else {
      emit(ProfileError());
    }
  }

  Future<void> editProfile({
    required String fullname,
    required String username,
    required String bio,
    required String phonenumber,
    required String gender,
    required String birthday,
  }) async {
    var first_name = fullname.split(' ')[0];
    var last_name = fullname.split(' ')[1];
    var user = await userRepo.editProfile(
        first_name, last_name, username, bio, phonenumber, gender, birthday);
    await authRepo.setUser(user!);
    emit(ProfileLoaded(user, [], [], []));
  }

  @override
  void onChange(Change<ProfileState> change) {
    print(change);
    super.onChange(change);
  }
}

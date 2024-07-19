import 'package:akababi/model/User.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:akababi/repositiory/UserRepo.dart';
import 'package:akababi/utility.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());
  final authRepo = AuthRepo();
  final userRepo = UserRepo();

  Future<bool> deleteUser(String password) async {
    final res = await authRepo.deleteUser(password);
    return res;
  }

  Future<bool> deactivateUser(String password) async {
    final res = await authRepo.deactivateUser(password);
    return res;
  }

  Future<bool> reactivateUser(Map<String, dynamic> data) async {
    final res = await authRepo.reactivateUser(data);
    return res;
  }

  Future<void> logOut(BuildContext context) async {
    final pref = await SharedPreferences.getInstance();
    pref.remove('imagePath');
    emit(ProfileInitial());
    await authRepo.removeUser();
    await Navigator.pushNamedAndRemoveUntil(
        context, '/login', (route) => false);
  }

  Future<void> getUser() async {
    User? user = await authRepo.user;
    if (user != null) {
      int id = user.id;
      final friends = await userRepo.getUserFriend(id);
      final posts = await userRepo.getUserPost(id);
      final likedPosts = await userRepo.getUserLikedPost();
      final reposted = await userRepo.getUserReposted(id);
      final saved = await userRepo.getUserSaved(id);
      print(reposted.length);
      emit(ProfileLoaded(user, posts, friends, likedPosts, reposted, saved));
    } else {
      emit(ProfileError());
    }
  }

  Future<bool> editProfile({
    required String fullname,
    required String username,
    required String bio,
    required String phonenumber,
    required String gender,
    required String birthday,
  }) async {
    try {
      var firstName = fullname.split(' ')[0];
      var lastName = fullname.split(' ')[1];
      var birth = birthday == '' ? null : birthday;
      var user = await userRepo.editProfile(
          firstName, lastName, username, bio, phonenumber, gender, birth);
      await authRepo.setUser(user!);
      final state = super.state as ProfileLoaded;
      emit(ProfileLoaded(user, state.posts, state.friends, state.likedPosts,
          state.reposted, state.saved));
      return true;
    } catch (e) {
      if (e is DioException) {
        String error = handleDioError(e);
        print(error);
        final state = super.state as ProfileLoaded;
        emit(ProfileLoaded(state.user, state.posts, state.friends,
            state.likedPosts, state.reposted, state.saved,
            error: error));
      }
      return false;
    }
  }

  @override
  void onChange(Change<ProfileState> change) {
    print(change);
    super.onChange(change);
  }
}

import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:akababi/repositiory/postRepo.dart';
import 'package:akababi/utility.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';

part 'post_state.dart';

class PostCubit extends Cubit<PostState> {
  final authRepo = AuthRepo();
  PostCubit() : super(PostInitial());

  Future<void> loadPostById(BuildContext context) async {
    emit(PostLoading());
    final user = await authRepo.user;
    if (user == null) {
      Navigator.of(context, rootNavigator: true).pushNamed('/login');
      return;
    }
    final location = await getCurrentLocation(context);
    final post = await PostRepo()
        .getPostsByUserId(user!.id, location!.longitude, location.latitude);
    emit(PostLoaded(post));
  }

  void setReaction(Map<String, dynamic> data) async {
    final user = await authRepo.user;
    data['user_id'] = user!.id;
    await PostRepo().setReaction(data);
  }

  Future<bool> repostPost(Map<String, dynamic> data) async {
    final user = await authRepo.user;
    data['user_id'] = user!.id;
    return await PostRepo().repostPost(data);
  }

  Future<bool> savePost(Map<String, dynamic> data) async {
    final user = await authRepo.user;
    data['user_id'] = user!.id;
    return await PostRepo().savePost(data);
  }

  Future<bool> reportPost(Map<String, dynamic> data) async {
    final user = await authRepo.user;
    data['reported_by'] = user!.id;
    return await PostRepo().reportPost(data);
  }

  Future<bool> deletePost(int id) async {
    return await PostRepo().deletePost(id);
  }

  Future<bool> editPost(Map<String, dynamic> data) async {
    final user = await authRepo.user;
    data['user_id'] = user!.id;
    return await PostRepo().editPost(data);
  }
}

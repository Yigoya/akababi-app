import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:akababi/repositiory/postRepo.dart';
import 'package:bloc/bloc.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

part 'single_post_state.dart';

class SinglePostCubit extends Cubit<SinglePostState> {
  SinglePostCubit() : super(SinglePostInitial());
  final authRepo = AuthRepo();
  final postRepo = PostRepo();
  void getPostById(int id) async {
    Logger().d('get post by id $id');
    try {
      if (state is SinglePostLoaded) {
        final post = (state as SinglePostLoaded).post;
        if (post['id'] != id) {
          emit(SinglePostLoading());
        }
      }

      final post = await postRepo.getPostById(id);
      emit(SinglePostLoaded(post));
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  void getRepostById(int id) async {
    try {
      if (state is SinglePostLoaded) {
        final post = (state as SinglePostLoaded).post;
        if (post['id'] != id) {
          emit(SinglePostLoading());
        }
      }

      final post = await postRepo.getRepostById(id);
      emit(SinglePostLoaded(post));
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  void setReaction(Map<String, dynamic> data) async {
    final user = await authRepo.user;
    data['user_id'] = user!.id;
    await postRepo.setReaction(data);
  }

  void getReaction(int id) async {
    emit(SinglePostLoading());
    final likes = await postRepo.getPostReaction(id);
    emit(PostLikesLoaded(likes));
  }
}

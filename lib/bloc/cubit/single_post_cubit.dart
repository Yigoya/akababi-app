import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:akababi/repositiory/postRepo.dart';
import 'package:bloc/bloc.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

part 'single_post_state.dart';

class SinglePostCubit extends Cubit<SinglePostState> {
  SinglePostCubit() : super(SinglePostInitial());
  final authRepo = AuthRepo();
  void getPostById(int id) async {
    Logger().d('get post by id $id');
    try {
      if (this.state is PostLoaded) {
        final post = (this.state as PostLoaded).post;
        if (post['id'] != id) {
          emit(PostLoading());
        }
      }

      final post = await PostRepo().getPostById(id);
      emit(PostLoaded(post));
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  void getRepostById(int id) async {
    try {
      if (this.state is PostLoaded) {
        final post = (this.state as PostLoaded).post;
        if (post['id'] != id) {
          emit(PostLoading());
        }
      }

      final post = await PostRepo().getRepostById(id);
      emit(PostLoaded(post));
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  void setReaction(Map<String, dynamic> data) async {
    final user = await authRepo.user;
    data['user_id'] = user!.id;
    await PostRepo().setReaction(data);
  }

  void setComment(Map<String, dynamic> data) async {
    final user = await authRepo.user;
    data['user_id'] = user!.id;

    final post = await PostRepo().setComment(data);
    emit(PostLoaded(post));
  }
}

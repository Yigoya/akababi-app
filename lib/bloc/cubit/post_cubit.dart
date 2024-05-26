import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:akababi/repositiory/postRepo.dart';
import 'package:akababi/utility.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'post_state.dart';

class PostCubit extends Cubit<PostState> {
  final authRepo = AuthRepo();
  PostCubit() : super(PostInitial());

  void loadPostById() async {
    emit(PostLoading(posts: []));
    final user = await authRepo.user;
    final location = await getCurrentLocation();
    final post = await PostRepo()
        .getPostsByUserId(user!.id, location!.longitude, location.latitude);
    emit(PostLoaded(post));
  }

  void setReaction(Map<String, dynamic> data) async {
    final user = await authRepo.user;
    data['user_id'] = user!.id;
    await PostRepo().setReaction(data);
  }

  void getPostById(int id) async {
    if (state is PostLoaded) {
      final posts = (state as PostLoaded).posts;
      emit(PostLoading(posts: posts));
      final post = await PostRepo().getPostById(id);
      emit(SinglePostLoaded(post, posts));
    } else {
      final post = await PostRepo().getPostById(id);
      emit(SinglePostLoaded(post, []));
    }
  }

  void setComment(Map<String, dynamic> data) async {
    final user = await authRepo.user;
    data['user_id'] = user!.id;
    if (state is SinglePostLoaded) {
      final posts = (state as SinglePostLoaded).posts;
      emit(PostLoading(posts: posts));
      final post = await PostRepo().setComment(data);
      emit(SinglePostLoaded(post, posts));
    }
  }
}

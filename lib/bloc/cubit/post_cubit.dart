import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:akababi/repositiory/postRepo.dart';
import 'package:akababi/utility.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';

part 'post_state.dart';

class PostCubit extends Cubit<PostState> {
  final authRepo = AuthRepo();
  final logger = Logger();
  PostCubit() : super(PostInitial());

  Future<void> getFeed(BuildContext context, {bool? refreach}) async {
    emit(PostLoading());
    final user = await authRepo.user;
    if (user == null) {
      Navigator.of(context, rootNavigator: true).pushNamed('/login');
      return;
    }
    final location = await getCurrentLocation(context);
    final post = await PostRepo().getPostsByUserId(
        id: user.id,
        longitude: location!.longitude,
        latitude: location.latitude,
        refreach: refreach);
    if (post == null) return;
    // final listPost = post["posts"] as List<dynamic>;
    // final posts = listPost.map((e) => e as Map<String, dynamic>).toList();
    final posts = post["posts"].cast<Map<String, dynamic>>().toList();
    emit(
        PostLoaded(posts: posts, recommendedPeople: post["recommendedPeople"]));
  }

  Future<void> getNewPost() async {
    final post = await PostRepo().getNewPost();
    if (post == null) return;
    if (state is PostLoaded) {
      final posts = (state as PostLoaded).posts;
      posts.insert(0, post);
      logger.i(posts);
      emit(PostLoaded(posts: posts));
    }
  }

  Future<void> getNewRePost() async {
    final post = await PostRepo().getNewRePost();
    if (post == null) return;
    if (state is PostLoaded) {
      final posts = (state as PostLoaded).posts;
      posts.insert(0, post);
      logger.i(posts);
      emit(PostLoaded(posts: posts));
    }
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

  Future<bool> unsavePost(Map<String, dynamic> data) async {
    final user = await authRepo.user;
    data['user_id'] = user!.id;
    return await PostRepo().unsavePost(data);
  }

  Future<bool> reportPost(Map<String, dynamic> data) async {
    final user = await authRepo.user;
    data['reported_by'] = user!.id;
    return await PostRepo().reportPost(data);
  }

  Future<bool> deletePost(int id) async {
    final res = await PostRepo().deletePost(id);
    if (state is PostLoaded && res) {
      final posts = (state as PostLoaded).posts;
      final index = findAllIndicesById(id);
      for (var i = 0; i < index.length; i++) {
        posts.removeAt(index[i]);
      }
      emit(PostLoaded(posts: posts));
    }
    return res;
  }

  Future<bool> deleteRepost(int id, {bool isRepost = false}) async {
    final res = await PostRepo().deleteRepost(id);
    if (state is PostLoaded && res) {
      final posts = (state as PostLoaded).posts;
      final index =
          isRepost ? findAllIndicesByRepostId(id) : findAllIndicesById(id);
      for (var i = 0; i < index.length; i++) {
        posts.removeAt(index[i]);
      }
      emit(PostLoaded(posts: posts));
    }
    return res;
  }

  Future<bool> editPost(Map<String, dynamic> data) async {
    final user = await authRepo.user;
    data['user_id'] = user!.id;
    return await PostRepo().editPost(data);
  }

  Future<bool> editRepost(Map<String, dynamic> data) async {
    final user = await authRepo.user;
    data['user_id'] = user!.id;
    return await PostRepo().editRepost(data);
  }

  void updateMapInList(int id, Map<String, dynamic> updatedData,
      {bool isRepost = false}) {
    if (state is PostLoaded) {
      final posts = (state as PostLoaded).posts;
      var index =
          isRepost ? findAllIndicesByRepostId(id) : findAllIndicesById(id);
      for (var i = 0; i < index.length; i++) {
        posts[index[i]] = {...posts[index[i]], ...updatedData};
      }
      // logger.d(posts[index[0]]);
      emit(PostLoaded(posts: posts));
    }
  }

  void deleteMapById(int id) {
    if (state is PostLoaded) {
      final posts = (state as PostLoaded).posts;
      final index = findAllIndicesById(id);
      for (var i = 0; i < index.length; i++) {
        posts.removeAt(index[i]);
      }
      emit(PostLoaded(posts: posts));
    }
  }

  List<int> findAllIndicesById(int id) {
    final List<int> indices = [];
    if (state is PostLoaded) {
      final posts = (state as PostLoaded).posts;
      for (var i = 0; i < posts.length; i++) {
        if (posts[i]['id'] == id) {
          indices.add(i);
        }
      }
    }
    return indices;
  }

  List<int> findAllIndicesByRepostId(int id) {
    final List<int> indices = [];
    if (state is PostLoaded) {
      final posts = (state as PostLoaded).posts;
      for (var i = 0; i < posts.length; i++) {
        if (posts[i]['repost_id'] == id) {
          indices.add(i);
        }
      }
    }
    return indices;
  }
}

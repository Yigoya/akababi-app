part of 'single_post_cubit.dart';

@immutable
sealed class SinglePostState {}

final class SinglePostInitial extends SinglePostState {}

class SinglePostLoading extends SinglePostState {
  SinglePostLoading();
}

class SinglePostLoaded extends SinglePostState {
  final Map<String, dynamic> post;

  SinglePostLoaded(this.post);
}

class PostLikesLoaded extends SinglePostState {
  final List<Map<String, dynamic>> likes;

  PostLikesLoaded(this.likes);
}

class PostError extends SinglePostState {
  final String error;

  PostError(this.error);
}

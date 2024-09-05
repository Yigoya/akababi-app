part of 'single_post_cubit.dart';

@immutable
sealed class SinglePostState {}

final class SinglePostInitial extends SinglePostState {}

class PostLoading extends SinglePostState {
  PostLoading();
}

class PostLoaded extends SinglePostState {
  final Map<String, dynamic> post;

  PostLoaded(this.post);
}

class PostError extends SinglePostState {
  final String error;

  PostError(this.error);
}

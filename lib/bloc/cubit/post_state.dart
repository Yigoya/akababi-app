part of 'post_cubit.dart';

@immutable
sealed class PostState {}

final class PostInitial extends PostState {}

class PostLoading extends PostState {
  final List<Map<String, dynamic>> posts;

  PostLoading({required this.posts});
}

class PostLoaded extends PostState {
  final List<Map<String, dynamic>> posts;

  PostLoaded(this.posts);
}

class SinglePostLoaded extends PostState {
  final Map<String, dynamic> post;
  final List<Map<String, dynamic>> posts;

  SinglePostLoaded(this.post, this.posts);
}

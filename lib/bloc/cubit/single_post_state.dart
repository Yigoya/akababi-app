part of 'single_post_cubit.dart';

@immutable
sealed class SinglePostState {}

final class SinglePostInitial extends SinglePostState {}

class PostLoading extends SinglePostState {
  final List<Map<String, dynamic>> post;

  PostLoading({required this.post});
}

class PostLoaded extends SinglePostState {
  final Map<String, dynamic> post;

  PostLoaded(this.post);
}

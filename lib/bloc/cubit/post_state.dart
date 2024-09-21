part of 'post_cubit.dart';

@immutable
sealed class PostState {}

final class PostInitial extends PostState {}

class PostLoading extends PostState {}

class PostLoaded extends PostState {
  final List<Map<String, dynamic>> posts;
  final List<Map<String, dynamic>> recommendedPeople;

  PostLoaded({required this.posts, this.recommendedPeople = const []});
}

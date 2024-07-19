part of 'profile_cubit.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

final class ProfileError extends ProfileState {}

final class ProfileLoaded extends ProfileState {
  final User user;
  final List<Map<String, dynamic>> posts;
  final List<Map<String, dynamic>> friends;
  final List<Map<String, dynamic>> likedPosts;
  final List<Map<String, dynamic>> reposted;
  final List<Map<String, dynamic>> saved;
  final String? error;
  ProfileLoaded(this.user, this.posts, this.friends, this.likedPosts,
      this.reposted, this.saved,
      {this.error});
}

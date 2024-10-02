part of 'people_cubit.dart';

sealed class PeopleState {}

final class PeopleInitial extends PeopleState {}

final class PeopleLoading extends PeopleState {
  final List<dynamic> peoples;

  PeopleLoading({required this.peoples});
}

final class PeopleLoaded extends PeopleState {
  final List<Map<String, dynamic>> peoples;
  final List<Map<String, dynamic>> posts;

  PeopleLoaded({required this.posts, required this.peoples});
}

// final class SinglePeopleLoaded extends PeopleState {
//   final Map<String, dynamic> people;
//   final List<Map<String, dynamic>> peoples;
//   final List<Map<String, dynamic>> posts;
//   final List<Map<String, dynamic>> friends;

//   SinglePeopleLoaded(this.people, this.peoples, this.posts, this.friends);
// }

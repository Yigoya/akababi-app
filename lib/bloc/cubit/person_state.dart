part of 'person_cubit.dart';

@immutable
sealed class PersonState {}

final class PersonInitial extends PersonState {}

final class PersonLoading extends PersonState {}

final class PersonLoaded extends PersonState {
  final Map<String, dynamic> person;
  final List<Map<String, dynamic>> posts;
  final List<Map<String, dynamic>> friends;
  PersonLoaded(this.person, this.posts, this.friends);
}

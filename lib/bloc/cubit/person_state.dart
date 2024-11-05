part of 'person_cubit.dart';

@immutable
sealed class PersonState {}

final class PersonInitial extends PersonState {}

final class PersonLoading extends PersonState {}

final class PersonLoaded extends PersonState {
  final Map<String, dynamic> person;
  final List<Map<String, dynamic>> posts;
  final List<Map<String, dynamic>> friends;
  final List<Map<String, dynamic>> recommendedPeople;
  PersonLoaded(
      {required this.person,
      required this.posts,
      required this.friends,
      required this.recommendedPeople});
}

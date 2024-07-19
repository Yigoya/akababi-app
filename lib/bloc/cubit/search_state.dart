part of 'search_cubit.dart';

@immutable
sealed class SearchState {}

final class SearchInitial extends SearchState {}

final class SearchLoading extends SearchState {}

final class SearchLoaded extends SearchState {
  final Map<String, List<Map<String, dynamic>>> search;
  SearchLoaded(this.search);
}

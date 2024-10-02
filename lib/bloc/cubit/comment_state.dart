part of 'comment_cubit.dart';

sealed class CommentState extends Equatable {
  const CommentState();

  @override
  List<Object> get props => [];
}

final class CommentInitial extends CommentState {}

final class CommentLoading extends CommentState {}

final class ReplyLoading extends CommentState {
  final List<Map<String, dynamic>> comments;
  final Map<int, List<Map<String, dynamic>>> replies;

  ReplyLoading({required this.comments, required this.replies});
}

final class CommentLoaded extends CommentState {
  final List<Map<String, dynamic>> comments;

  CommentLoaded({required this.comments});
}

final class ReplyLoaded extends CommentState {
  final List<Map<String, dynamic>> comments;
  final Map<int, List<Map<String, dynamic>>> replies;

  ReplyLoaded({required this.comments, required this.replies});
}

final class CommentAdded extends CommentState {
  final List<Map<String, dynamic>> comments;

  CommentAdded({required this.comments});
}

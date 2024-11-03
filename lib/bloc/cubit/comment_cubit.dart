import 'package:akababi/repositiory/postRepo.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';

part 'comment_state.dart';

class CommentCubit extends Cubit<CommentState> {
  CommentCubit() : super(CommentInitial());
  PostRepo postRepo = PostRepo();

  void getComments(int id) async {
    emit(CommentLoading());
    final comments = await postRepo.getPostComments(id);
    if (comments == null) return;
    emit(CommentLoaded(comments: comments));
  }

  void getReplies(int commentId) async {
    if (state is ReplyLoaded) {
      final state = this.state as ReplyLoaded;
      final replies = await postRepo.getCommentReplies(commentId);
      if (replies == null) return;
      emit(ReplyLoading(
          comments: state.comments,
          replies: {...state.replies, commentId: replies}));
    } else if (state is CommentLoaded) {
      final state = this.state as CommentLoaded;
      final replies = await postRepo.getCommentReplies(commentId);
      if (replies == null) return;

      emit(
          ReplyLoaded(comments: state.comments, replies: {commentId: replies}));
    } else if (state is ReplyLoading) {
      final state = this.state as ReplyLoading;
      final replies = await postRepo.getCommentReplies(commentId);
      if (replies == null) return;
      emit(ReplyLoaded(
          comments: state.comments,
          replies: {...state.replies, commentId: replies}));
    } else if (state is CommentAdded) {
      final state = this.state as CommentLoaded;
      final replies = await postRepo.getCommentReplies(commentId);
      if (replies == null) return;

      emit(
          ReplyLoaded(comments: state.comments, replies: {commentId: replies}));
    }
  }

  void addComment(int postId, String content, String? imagePath) async {
    final comment = await postRepo.setComment(
        postId: postId, content: content, imagePath: imagePath);
    if (comment == null) return;
    if (state is ReplyLoaded) {
      final state = this.state as ReplyLoaded;
      emit(ReplyLoading(
          comments: state.comments..insert(0, comment),
          replies: state.replies));
    } else if (state is CommentLoaded) {
      final state = this.state as CommentLoaded;
      emit(CommentAdded(
        comments: state.comments..insert(0, comment),
      ));
    } else if (state is ReplyLoading) {
      final state = this.state as ReplyLoading;
      emit(ReplyLoaded(
          comments: state.comments..insert(0, comment),
          replies: state.replies));
    } else if (state is CommentAdded) {
      final state = this.state as CommentAdded;
      emit(CommentLoaded(
        comments: state.comments..insert(0, comment),
      ));
    }
  }

  void deleteComment(int commentId) async {
    final isDeleted = await postRepo.deleteComment(commentId);
    if (!isDeleted) return;
    if (state is CommentLoaded) {
      final comments = (state as CommentLoaded).comments;
      int index = 0;
      for (int i = 0; i < comments.length; i++) {
        if (comments[i]['id'] == commentId) {
          index = i;
        }
      }
      comments.removeAt(index);
      emit(CommentAdded(comments: comments));
    } else if (state is ReplyLoaded) {
      final state = this.state as ReplyLoaded;
      final comments = state.comments;
      int index = 0;
      for (int i = 0; i < comments.length; i++) {
        if (comments[i]['id'] == commentId) {
          index = i;
        }
      }
      comments.removeAt(index);
      emit(ReplyLoading(comments: comments, replies: state.replies));
    } else if (state is ReplyLoading) {
      final state = this.state as ReplyLoading;
      final comments = state.comments;
      int index = 0;
      for (int i = 0; i < comments.length; i++) {
        if (comments[i]['id'] == commentId) {
          index = i;
        }
      }
      comments.removeAt(index);
      emit(ReplyLoaded(comments: comments, replies: state.replies));
    } else if (state is CommentAdded) {
      final state = this.state as CommentAdded;
      final comments = state.comments;
      int index = 0;
      for (int i = 0; i < comments.length; i++) {
        if (comments[i]['id'] == commentId) {
          index = i;
        }
      }
      comments.removeAt(index);
      emit(CommentLoaded(comments: comments));
    }
  }

  void updateComment(int commentId, String content) async {
    final comment =
        await postRepo.updateComment(id: commentId, content: content);
    if (comment == null) return;
    if (state is CommentLoaded) {
      final comments = (state as CommentLoaded).comments;
      int index = 0;
      for (int i = 0; i < comments.length; i++) {
        if (comments[i]['id'] == commentId) {
          index = i;
        }
      }
      Logger().d(comment);
      comments[index] = comment;
      emit(CommentAdded(comments: comments));
    } else if (state is ReplyLoaded) {
      final state = this.state as ReplyLoaded;
      final comments = state.comments;
      int index = 0;
      for (int i = 0; i < comments.length; i++) {
        if (comments[i]['id'] == commentId) {
          index = i;
        }
      }
      comments[index] = comment;
      emit(ReplyLoading(comments: comments, replies: state.replies));
    } else if (state is ReplyLoading) {
      final state = this.state as ReplyLoading;
      final comments = state.comments;
      int index = 0;
      for (int i = 0; i < comments.length; i++) {
        if (comments[i]['id'] == commentId) {
          index = i;
        }
      }
      comments[index] = comment;
      emit(ReplyLoaded(comments: comments, replies: state.replies));
    } else if (state is CommentAdded) {
      final state = this.state as CommentAdded;
      final comments = state.comments;
      int index = 0;
      for (int i = 0; i < comments.length; i++) {
        if (comments[i]['id'] == commentId) {
          index = i;
        }
      }
      comments[index] = comment;
      emit(CommentLoaded(comments: comments));
    }
  }

  void addReply(
      {required int commentId,
      required String content,
      required String replyTo,
      required int repliedUserId,
      String? imagePath}) async {
    final reply = await postRepo.setCommentReply(
        commentId: commentId,
        content: content,
        replyTo: replyTo,
        repliedUserId: repliedUserId,
        imagePath: imagePath);
    if (reply == null) return;
    if (state is ReplyLoaded) {
      final state = this.state as ReplyLoaded;
      final replies = state.replies[commentId]!;
      replies.insert(0, reply);
      emit(ReplyLoading(comments: state.comments, replies: state.replies));
    } else if (state is CommentLoaded) {
      final state = this.state as CommentLoaded;
      emit(ReplyLoaded(comments: state.comments, replies: {
        commentId: [reply]
      }));
    } else if (state is ReplyLoading) {
      final state = this.state as ReplyLoading;
      final replies = state.replies[commentId]!;
      replies.insert(0, reply);
      emit(ReplyLoaded(comments: state.comments, replies: state.replies));
    } else if (state is CommentAdded) {
      final state = this.state as CommentAdded;
      emit(ReplyLoaded(comments: state.comments, replies: {
        commentId: [reply]
      }));
    }
  }

  void deleteReply(int commentId, int replyId) async {
    final isDeleted = await postRepo.deleteCommentReply(replyId);
    if (!isDeleted) return;
    if (state is ReplyLoaded) {
      final replies = (state as ReplyLoaded).replies;
      final comments = (state as ReplyLoaded).comments;
      int index = 0;
      for (int i = 0; i < replies[commentId]!.length; i++) {
        if (replies[commentId]![i]['id'] == replyId) {
          index = i;
        }
      }

      replies[commentId]!.removeAt(index);
      emit(ReplyLoading(comments: comments, replies: replies));
    } else if (state is ReplyLoading) {
      final replies = (state as ReplyLoading).replies;
      final comments = (state as ReplyLoading).comments;
      int index = 0;
      for (int i = 0; i < replies[commentId]!.length; i++) {
        if (replies[commentId]![i]['id'] == replyId) {
          index = i;
        }
      }

      replies[commentId]!.removeAt(index);
      emit(ReplyLoaded(comments: comments, replies: replies));
    }
  }

  void updateReply(int replyId, String content, int commentId) async {
    final reply =
        await postRepo.updateCommentReply(id: replyId, content: content);
    if (reply == null) return;
    if (state is ReplyLoaded) {
      final replies = (state as ReplyLoaded).replies;
      final comments = (state as ReplyLoaded).comments;
      int index = 0;
      for (int i = 0; i < replies[commentId]!.length; i++) {
        if (replies[commentId]![i]['id'] == replyId) {
          index = i;
        }
      }

      replies[commentId]![index] = reply;
      emit(ReplyLoading(comments: comments, replies: replies));
    } else if (state is ReplyLoading) {
      final replies = (state as ReplyLoading).replies;
      final comments = (state as ReplyLoading).comments;
      int index = 0;
      for (int i = 0; i < replies[commentId]!.length; i++) {
        if (replies[commentId]![i]['id'] == replyId) {
          index = i;
        }
      }

      replies[commentId]![index] = reply;
      emit(ReplyLoaded(comments: comments, replies: replies));
    }
  }

  Future<bool> setLike(int id, String type) async {
    return await postRepo.setCommentLike(id, type);
  }

  // void likeComment(int commentId) async {
  //   emit(CommentLoading());
  //   final comment = await postRepo.likeComment(commentId);
  //   if (comment == null) return;
  //   emit(CommentLiked(comment: comment));
  // }

  // void likeReply(int replyId) async {
  //   emit(CommentLoading());
  //   final reply = await postRepo.likeReply(replyId);
  //   if (reply == null) return;
  //   emit(ReplyLiked(reply: reply));
  // }

  // }

  // void clear() {
  //   emit(CommentInitial());
  // }

  // void clearReplies() {
  //   emit(RepliesInitial());
  // }
}

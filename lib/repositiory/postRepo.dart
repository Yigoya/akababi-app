import 'package:akababi/model/User.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:akababi/utility.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class PostRepo {
  final Dio _dio = Dio();
  String server = AuthRepo.SERVER;
  final logger = Logger();

  /// Searches for users and their associated posts based on a given query.
  ///
  /// Returns a [Future] that completes with a [Map] containing two lists:
  /// - "post": a list of maps representing the posts found.
  /// - "user": a list of maps representing the users found.
  ///
  /// Throws an [Exception] if the search fails or if there is a connection issue.
  Future<Map<String, List<Map<String, dynamic>>>> searchUser(
      String query) async {
    try {
      final response = await _dio
          .get('$server/search/user', queryParameters: {'query': query});
      print(response.data);
      if (response.statusCode! < 400) {
        final user = response.data['user'] as List<dynamic>;
        final post = response.data['post'] as List<dynamic>;
        final users = user.map((json) {
          return json as Map<String, dynamic>;
        }).toList();
        final posts = post.map((json) {
          return json as Map<String, dynamic>;
        }).toList();
        return {"post": posts, "user": users};
      } else {
        throw Exception('Failed to search posts by user');
      }
    } catch (e) {
      throw Exception('Failed to connect to the backend');
    }
  }

  /// Retrieves a list of posts by user ID, latitude, and longitude.
  ///
  /// The [id] parameter specifies the user ID.
  /// The [latitude] parameter specifies the latitude coordinate.
  /// The [longitude] parameter specifies the longitude coordinate.
  ///
  /// Returns a [Future] that completes with a list of maps, where each map represents a post.
  /// Each map contains key-value pairs of post data, with the keys being strings and the values being dynamic.
  /// Throws an [Exception] if the request fails or if there is a connection issue.
  Future<Map<String, dynamic>> getPostsByUserId(
      {required int id,
      required double latitude,
      required double longitude,
      bool? refreach}) async {
    int index = refreach != true ? 0 : getFeedIndex();
    print({
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
    });
    try {
      final response = await _dio.get('$server/post/$id', queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'index': index,
      });
      logger.d({
        'latitude': latitude,
        'longitude': longitude,
        'index': feedIndex,
      });

      if (response.statusCode! < 400) {
        final postData = response.data["posts"] as List<dynamic>;
        final posts = postData.map((json) {
          return json as Map<String, dynamic>;
        }).toList();

        final peopleData = response.data["posts"] as List<dynamic>;
        final peoples = peopleData.map((json) {
          return json as Map<String, dynamic>;
        }).toList();

        return {"posts": posts, "recommendedPeople": peoples};
      } else {
        throw Exception('Failed to search posts by user');
      }
    } catch (e) {
      throw Exception('Failed to connect to the backend');
    }
  }

  /// Sets the reaction for a post.
  ///
  /// The [data] parameter is a map containing the necessary data for setting the reaction.
  /// This method sends a POST request to the server to set the reaction for a post.
  /// If the request is successful (status code >= 400), an exception is thrown.
  /// If there is an error connecting to the backend, an exception is thrown.
  ///
  /// Example usage:
  /// ```dart
  /// final data = {
  ///   'postId': 123,
  ///   'reactionType': 'like',
  /// };
  /// await setReaction(data);
  /// ```
  Future<void> setReaction(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('$server/post/setReaction', data: data);

      logger.d(response.data);
      if (response.statusCode! > 400) {
        throw Exception('Failed to like post');
      }
    } catch (e) {
      throw Exception('Failed to connect to the backend');
    }
  }

  /// Retrieves a post by its ID from the server.
  ///
  /// Returns a [Future] that completes with a [Map] containing the post data.
  /// Throws an [Exception] if the request fails or if the response status code is 400 or higher.
  Future<Map<String, dynamic>> getPostById(int id) async {
    User? user = await AuthRepo().user;
    try {
      final response =
          await _dio.get('$server/post/getPostById/$id/${user!.id}');
      logger.d(response.data);
      if (response.statusCode! < 400) {
        final data = response.data as Map<String, dynamic>;

        return data;
      } else {
        throw Exception('Failed to search posts by user');
      }
    } catch (e) {
      throw Exception('Failed to connect to the backend');
    }
  }

  Future<Map<String, dynamic>> getRepostById(int id) async {
    User? user = await AuthRepo().user;
    try {
      final response =
          await _dio.get('$server/post/getRepostById/$id/${user!.id}');
      logger.d(response.data);
      if (response.statusCode! < 400) {
        final data = response.data as Map<String, dynamic>;

        return data;
      } else {
        throw Exception('Failed to search posts by user');
      }
    } catch (e) {
      throw Exception('Failed to connect to the backend');
    }
  }

  /// Reposts a post with the given [data].
  ///
  /// Returns `true` if the post is successfully reposted, otherwise `false`.
  /// Throws an [Exception] if the post creation fails.
  Future<bool> repostPost(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('$server/post/repost', data: data);
      logger.d(response.data);
      if (response.statusCode! < 400) {
        final data = response.data as Map<String, dynamic>;

        return true;
      } else {
        throw Exception('Failed to create post');
      }
    } catch (e) {
      logger.e('error $e');
      return false;
    }
  }

  /// Saves a post with the given [data] to the server.
  ///
  /// Returns `true` if the post is successfully saved, otherwise returns `false`.
  /// Throws an [Exception] if the post creation fails.
  Future<bool> savePost(Map<String, dynamic> data) async {
    try {
      logger.d(data);
      final response = await _dio.post('$server/post/save', data: data);
      logger.d(response.data);
      if (response.statusCode! < 300) {
        final data = response.data as Map<String, dynamic>;

        return true;
      } else {
        throw Exception('Failed to create post');
      }
    } catch (e) {
      logger.e('error $e');
      return false;
    }
  }

  Future<bool> unsavePost(Map<String, dynamic> data) async {
    try {
      logger.d(data);
      final response = await _dio.post('$server/post/unsave', data: data);
      logger.d(response.data);
      if (response.statusCode! < 300) {
        final data = response.data as Map<String, dynamic>;

        return true;
      } else {
        throw Exception('Failed to create post');
      }
    } catch (e) {
      logger.e('error $e');
      return false;
    }
  }

  /// Reports a post with the given [data].
  ///
  /// Returns `true` if the post is successfully reported, otherwise returns `false`.
  /// Throws an [Exception] if there was a failure in reporting the post.
  Future<bool> reportPost(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('$server/post/report', data: data);
      logger.d(response.data);
      if (response.statusCode! < 300) {
        final data = response.data as Map<String, dynamic>;

        return true;
      } else {
        throw Exception('Failed to create post');
      }
    } catch (e) {
      logger.e('error $e');
      return false;
    }
  }

  /// Sends a comment to the server and returns the response data.
  ///
  /// The [data] parameter is a map containing the comment data.
  /// The returned value is a map containing the response data from the server.
  /// Throws an exception if the request fails or if there is a connection issue.
  Future<Map<String, dynamic>> setComment(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('$server/post/setComment', data: data);
      logger.d(response.data);
      if (response.statusCode! < 400) {
        final data = response.data as Map<String, dynamic>;

        return data;
      } else {
        throw Exception('Failed to create post');
      }
    } catch (e) {
      throw Exception('Failed to connect to the backend');
    }
  }

  /// Retrieves a list of notifications for a user with the given [id].
  ///
  /// Returns a [Future] that completes with a list of [Map<String, dynamic>]
  /// representing the notifications.
  ///
  /// Throws an [Exception] if there is a failure to connect to the backend.
  Future<List<Map<String, dynamic>>> getNotificationByUserId(int id) async {
    try {
      final response =
          await _dio.get('$server/notification/getNotificationByUserId/$id');
      logger.d(response.data);

      final data = response.data as List<dynamic>;
      final posts = data.map((json) {
        return json as Map<String, dynamic>;
      }).toList();
      return posts;
    } catch (e) {
      throw Exception('Failed to connect to the backend');
    }
  }

  /// Deletes a notification with the given [id].
  ///
  /// Returns a [Future] that completes with a [Map] containing the response data.
  /// Throws an [Exception] if there is a failure to connect to the backend.
  Future<Map<String, dynamic>> deleteNotification(int id) async {
    try {
      final response =
          await _dio.delete('$server/notification/deleteNotification/$id');
      logger.d(response.data);

      final data = response.data as Map<String, dynamic>;

      return data;
    } catch (e) {
      throw Exception('Failed to connect to the backend');
    }
  }

  /// Edits a post with the given [data].
  ///
  /// Returns `true` if the post is successfully edited, otherwise `false`.
  /// Throws an [Exception] if the post creation fails.
  Future<bool> editPost(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('$server/post/editPost', data: data);
      logger.d(response.data);
      if (response.statusCode! < 300) {
        return true;
      } else {
        throw Exception('Failed to create post');
      }
    } catch (e) {
      logger.e('error $e');
      return false;
    }
  }

  Future<bool> editRepost(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('$server/post/editRepost', data: data);
      logger.d(response.data);
      if (response.statusCode! < 300) {
        return true;
      } else {
        throw Exception('Failed to create post');
      }
    } catch (e) {
      logger.e('error $e');
      return false;
    }
  }

  /// Deletes a post with the given [id].
  ///
  /// Returns `true` if the post is successfully deleted, otherwise returns `false`.
  /// Throws an [Exception] if the deletion fails.
  Future<bool> deletePost(int id) async {
    try {
      final response = await _dio.delete('$server/post/deletePost/$id');
      logger.d(response.data);
      if (response.statusCode! < 300) {
        return true;
      } else {
        throw Exception('Failed to create post');
      }
    } catch (e) {
      logger.e('error $e');
      return false;
    }
  }

  Future<bool> deleteRepost(int id) async {
    try {
      final response = await _dio.delete('$server/post/deleteRepost/$id');
      logger.d(response.data);
      if (response.statusCode! < 300) {
        return true;
      } else {
        throw Exception('Failed to create post');
      }
    } catch (e) {
      logger.e('error $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getNewPost() async {
    User? user = await AuthRepo().user;
    try {
      final response =
          await _dio.get('$server/post/getNewPostedPost/${user!.id}');
      logger.d(response.data);
      if (response.statusCode! < 400) {
        final data = response.data as Map<String, dynamic>;

        return data;
      } else {
        throw Exception('Failed to search posts by user');
      }
    } catch (e) {
      logger.e(e);
      return null;
    }
  }

  Future<Map<String, dynamic>?> getNewRePost() async {
    User? user = await AuthRepo().user;
    try {
      final response =
          await _dio.get('$server/post/getNewRePostedPost/${user!.id}');
      logger.d(response.data);
      if (response.statusCode! < 400) {
        final data = response.data as Map<String, dynamic>;

        return data;
      } else {
        throw Exception('Failed to search posts by user');
      }
    } catch (e) {
      print(e);
      return null;
    }
  }
}

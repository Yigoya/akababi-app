import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class PostRepo {
  final Dio _dio = Dio();
  String server = AuthRepo.SERVER;
  final logger = Logger();
  Future<List<Map<String, dynamic>>> searchUser(String query) async {
    try {
      final response = await _dio
          .get('$server/search/user', queryParameters: {'query': query});
      print(response.data);
      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        final posts = data.map((json) {
          return json as Map<String, dynamic>;
        }).toList();
        return posts;
      } else {
        throw Exception('Failed to search posts by user');
      }
    } catch (e) {
      throw Exception('Failed to connect to the backend');
    }
  }

  Future<List<Map<String, dynamic>>> getPostsByUserId(
      int id, double latitude, double longitude) async {
    try {
      final response = await _dio.get('$server/post/$id', queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
      });
      logger.d(response.data);
      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        final posts = data.map((json) {
          return json as Map<String, dynamic>;
        }).toList();

        return posts;
      } else {
        throw Exception('Failed to search posts by user');
      }
    } catch (e) {
      throw Exception('Failed to connect to the backend');
    }
  }

  Future<void> setReaction(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('$server/post/setReaction', data: data);
      if (response.statusCode != 200) {
        throw Exception('Failed to like post');
      }
    } catch (e) {
      throw Exception('Failed to connect to the backend');
    }
  }

  Future<Map<String, dynamic>> getPostById(int id) async {
    try {
      final response = await _dio.get('$server/post/getPostById/$id');
      logger.d(response.data);
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        return data;
      } else {
        throw Exception('Failed to search posts by user');
      }
    } catch (e) {
      throw Exception('Failed to connect to the backend');
    }
  }

  Future<Map<String, dynamic>> setComment(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('$server/post/setComment', data: data);
      logger.d(response.data);
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        return data;
      } else {
        throw Exception('Failed to create post');
      }
    } catch (e) {
      throw Exception('Failed to connect to the backend');
    }
  }

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
}

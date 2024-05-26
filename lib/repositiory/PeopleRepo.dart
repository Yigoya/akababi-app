import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class PeopleRepo {
  final authRepo = AuthRepo();
  final dio = Dio();
  final logger = Logger();
  Future<List<Map<String, dynamic>>> getPeopleSuggestions(
      Map<String, dynamic> formData) async {
    try {
      // const data = {'userId': 1};
      final response = await dio.post(
          AuthRepo.SERVER + "/algorithm/getUserSuggestions",
          data: formData);

      logger.d(response.data);
      final data = response.data as List<dynamic>;
      final peoples = data.map((json) {
        return json as Map<String, dynamic>;
      }).toList();
      return peoples;
    } catch (err) {
      print('Error $err');
      return [];
    }
  }

  Future<void> friendRequest(int id) async {
    try {
      final _user = await authRepo.user;
      final data = {'user_id': _user!.id, 'friend_id': id};
      final res =
          await dio.post('${AuthRepo.SERVER}/user/friendRequest', data: data);
      logger.d(res.data);
    } catch (e) {
      logger.e(e);
    }
  }

  Future<void> friendRequestRespond(
      String response, Map<String, dynamic> data) async {
    try {
      final _user = await authRepo.user;
      final formData = {...data, 'respond': response};
      logger.d(formData);
      final res = await dio.post('${AuthRepo.SERVER}/user/friendRequestRespond',
          data: formData);
      logger.d(res.data);
    } catch (e) {
      logger.e(e);
    }
  }

  Future<Map<String, dynamic>> getPeopleById(int userId, personId) async {
    try {
      final res = await dio
          .get('${AuthRepo.SERVER}/user/getUserById/$userId/$personId');
      logger.d(res.data);
      return res.data;
    } catch (e) {
      logger.e(e);
      return {};
    }
  }
}

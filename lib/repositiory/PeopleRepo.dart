import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class PeopleRepo {
  final authRepo = AuthRepo();
  final dio = Dio();
  final logger = Logger();

  /// Retrieves a list of people suggestions based on the provided form data.
  ///
  /// The [formData] parameter is a map containing the necessary data for the request.
  /// It should include the user ID as a key-value pair.
  ///
  /// Returns a future that completes with a list of maps, where each map represents a person.
  /// The maps contain dynamic key-value pairs representing the person's attributes.
  /// If an error occurs during the request, an empty list is returned.
  Future<List<Map<String, dynamic>>> getPeopleSuggestions(
      Map<String, dynamic> formData) async {
    try {
      final response = await dio.post(
          "${AuthRepo.SERVER}/algorithm/getUserSuggestions",
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

  /// Sends a friend request to a user with the specified [id].
  /// Returns `true` if the friend request was successfully sent, `false` otherwise.
  Future<bool> friendRequest(int id) async {
    try {
      final user = await authRepo.user;
      final data = {'user_id': user!.id, 'friend_id': id};
      final res =
          await dio.post('${AuthRepo.SERVER}/user/friendRequest', data: data);
      logger.d(res.data);
      return true;
    } catch (e) {
      logger.e(e);
      return false;
    }
  }

  /// Responds to a friend request.
  ///
  /// This method sends a response to a friend request. It takes in the [response] as a string
  /// which can be either 'accept' or 'reject'. The [data] parameter is a map containing additional
  /// data related to the friend request. The map should include the necessary information to
  /// process the response.
  ///
  /// The method first retrieves the current user using the [authRepo.user] method. It then creates
  /// a new map called [formData] by merging the [data] map with the 'respond' field set to the
  /// [response] value. The [logger.d] method is called to log the [formData].
  ///
  /// Finally, the method sends a POST request to the server endpoint '/user/friendRequestRespond'
  /// with the [formData] as the request body using the [dio.post] method. The response data is
  /// logged using the [logger.d] method and the method returns true if the request is successful,
  /// otherwise it returns false.
  ///
  /// Throws an error if an exception occurs during the process.
  Future<bool> friendRequestRespond(
      String response, Map<String, dynamic> data) async {
    try {
      final user = await authRepo.user;
      final formData = {...data, 'respond': response};
      logger.d(formData);
      final res = await dio.post('${AuthRepo.SERVER}/user/friendRequestRespond',
          data: formData);
      logger.d(res.data);
      return true;
    } catch (e) {
      logger.e(e);
      return false;
    }
  }

  /// Retrieves information about a person by their user ID and person ID.
  ///
  /// The [userId] parameter specifies the user ID of the person.
  /// The [personId] parameter specifies the person ID of the person.
  ///
  /// Returns a [Future] that completes with a [Map] containing the retrieved person's information.
  /// If an error occurs during the retrieval process, an empty [Map] is returned.
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

  /// Blocks a user based on the provided data.
  ///
  /// The [data] parameter is a map containing the necessary information to block the user.
  /// It should include the user's details such as ID, username, etc.
  ///
  /// Returns a [Future] that completes with a [bool] value indicating whether the user was successfully blocked or not.
  /// If the user is blocked successfully, the returned value is true. Otherwise, it is false.
  ///
  /// Throws an exception if an error occurs during the blocking process.
  Future<bool> blockUser(Map<String, dynamic> data) async {
    try {
      final res =
          await dio.post('${AuthRepo.SERVER}/user/blockUser', data: data);
      logger.d(res.data);
      return true;
    } catch (e) {
      logger.e(e);
      return false;
    }
  }

  /// Removes a friend request between two users.
  ///
  /// The [data] parameter is a map containing the user ID and friend ID.
  /// Returns `true` if the friend request was successfully removed, `false` otherwise.
  Future<bool> removeFriendRequest(Map<String, dynamic> data) async {
    try {
      final res = await dio.delete(
          '${AuthRepo.SERVER}/user/removeFriendRequest/${data['user_id']}/${data['friend_id']}');
      logger.d(res.data);
      return true;
    } catch (e) {
      logger.e(e);
      return false;
    }
  }
}

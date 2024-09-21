import 'dart:io';

import 'package:akababi/model/User.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:logger/logger.dart';

class UserRepo {
  final authRepo = AuthRepo();
  final dio = Dio();
  final logger = Logger();

  /// Sets the profile picture for the user.
  ///
  /// Takes a [filePath] as input and uploads the image file to the server.
  /// Returns a [Future] that completes with a [User] object if the operation is successful,
  /// otherwise returns `null`.
  ///
  /// Throws an exception if an error occurs during the process.
  Future<User?> setProfilePic(String filePath) async {
    try {
      final user = await authRepo.user;
      final file = await MultipartFile.fromFile(filePath,
          filename: basename(filePath), contentType: MediaType('image', 'png'));
      Map<String, dynamic> data = {'file': file, 'id': user!.id};
      FormData formData = FormData.fromMap(data);

      Response res = await dio.put('${AuthRepo.SERVER}/user/uploadProfileImage',
          data: formData);
      print(res.data);
      return User.fromMap(res.data['user']);
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// Retrieves the list of friends for a given user ID.
  ///
  /// Returns a list of maps, where each map represents a friend and contains
  /// their information.
  ///
  /// The [id] parameter specifies the user ID for which to retrieve the friends.
  /// Throws an exception if an error occurs during the API call.
  Future<List<Map<String, dynamic>>> getUserFriend(int id) async {
    try {
      Response res = await dio.get('${AuthRepo.SERVER}/user/getUserFriend/$id');
      List<dynamic> friends = res.data;
      List<Map<String, dynamic>> friendList =
          friends.map((friend) => friend as Map<String, dynamic>).toList();
      return friendList;
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<Map<String, dynamic>> getProfile(int id) async {
    try {
      Response res = await dio.get('${AuthRepo.SERVER}/user/getProfile/$id');

      return res.data;
    } catch (e) {
      print(e);
      return {};
    }
  }

  /// Retrieves the posts of a user with the specified [id].
  ///
  /// Returns a [Future] that completes with a list of maps, where each map represents a post.
  /// Each map contains key-value pairs where the keys are strings and the values are dynamic.
  /// If an error occurs during the retrieval process, an empty list is returned.
  Future<List<Map<String, dynamic>>> getUserPost(int id) async {
    try {
      Response res = await dio.get('${AuthRepo.SERVER}/post/getUserPost/$id');
      List<dynamic> posts = res.data;
      List<Map<String, dynamic>> postList =
          posts.map((post) => post as Map<String, dynamic>).toList();
      return postList;
    } catch (e) {
      print(e);
      return [];
    }
  }

  /// Retrieves the list of posts that a user has reposted.
  ///
  /// The [id] parameter specifies the user ID.
  /// Returns a [Future] that resolves to a list of [Map<String, dynamic>]
  /// representing the reposted posts.
  /// If an error occurs during the API call, an empty list is returned.
  Future<List<Map<String, dynamic>>> getUserReposted(int id) async {
    try {
      Response res = await dio.get('${AuthRepo.SERVER}/post/getReposted/$id');
      List<dynamic> posts = res.data;
      List<Map<String, dynamic>> postList =
          posts.map((post) => post as Map<String, dynamic>).toList();
      return postList;
    } catch (e) {
      print(e);
      return [];
    }
  }

  /// Retrieves the saved posts of a user with the given [id].
  ///
  /// Returns a [Future] that completes with a list of maps, where each map represents a post.
  /// Each map contains the post data as key-value pairs, with the keys being strings and the values being dynamic.
  /// If an error occurs during the retrieval process, an empty list is returned.
  Future<List<Map<String, dynamic>>> getUserSaved(int id) async {
    try {
      Response res = await dio.get('${AuthRepo.SERVER}/post/getSavedPost/$id');
      List<dynamic> posts = res.data;
      List<Map<String, dynamic>> postList =
          posts.map((post) => post as Map<String, dynamic>).toList();
      // logger.d(postList);
      return postList;
    } catch (e) {
      print(e);
      return [];
    }
  }

  /// Retrieves the list of posts that the user has liked.
  ///
  /// This method makes an HTTP GET request to the server to fetch the liked posts
  /// for the currently authenticated user. It returns a list of maps, where each
  /// map represents a liked post and contains the post's data.
  ///
  /// If an error occurs during the request or processing, an empty list is returned.
  Future<List<Map<String, dynamic>>> getUserLikedPost() async {
    try {
      User? user = await authRepo.user;
      var id = user!.id;
      Response res =
          await dio.get('${AuthRepo.SERVER}/post/getUserLikedPost/$id');
      List<dynamic> likedPosts = res.data;
      List<Map<String, dynamic>> likedPostList =
          likedPosts.map((post) => post as Map<String, dynamic>).toList();
      return likedPostList;
    } catch (e) {
      print(e);
      return [];
    }
  }

  /// Edits the user profile with the provided information.
  ///
  /// The [firstName], [lastName], [username], [bio], [phonenumber], [gender], and [birthday] parameters
  /// are used to update the user's profile information.
  ///
  /// Returns a [Future] that completes with a [User] object if the profile is successfully edited,
  /// or `null` if an error occurs.
  Future<User?> editProfile(String firstName, String lastName, String username,
      String bio, String phonenumber, String gender, String? birthday) async {
    final user = await authRepo.user;
    Map<String, dynamic> data = {
      'id': user!.id,
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'bio': bio,
      'phonenumber': phonenumber,
      'gender': gender,
      'birthday': birthday,
    };
    Response res =
        await dio.put('${AuthRepo.SERVER}/user/editProfile', data: data);
    if (res.statusCode == 200) {
      return User.fromMap(res.data['user']);
    }
  }

  /// Retrieves an image from the device's gallery.
  ///
  /// Uses the [ImagePicker] package to open the device's gallery and allow the user to select an image.
  /// Once an image is selected, it is saved locally and the file path is returned.
  /// If no image is selected, null is returned.
  Future<String?> getImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    print(file);
    if (file != null) {
      final savedImage = await _saveLocally(File(file.path));
      return file.path;
    }
    return null;
  }

  /// Picks a file using the FilePicker plugin.
  /// Returns a Future that completes with void.
  Future<void> pickFile() async {
    final file = await FilePicker.platform.pickFiles();
    if (file != null) {}
  }

  /// Saves the given image file locally and updates the profile picture path in SharedPreferences.
  /// Returns a Future that completes with the saved image file.
  ///
  /// Parameters:
  /// - image: The image file to be saved locally.
  ///
  /// Returns:
  /// - The saved image file.
  Future<File> _saveLocally(File image) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final dirc = await getApplicationDocumentsDirectory();
    final filename = basename(image.path);
    final savedImage = File('${dirc.path}/$filename');
    await prefs.setString('profilepic', savedImage.path);
    await image.copy(savedImage.path);

    return savedImage;
  }

  /// Uploads an image and file for a user with the specified [id].
  ///
  /// This method allows the user to pick an image from the gallery and upload it along with a file to the server.
  /// The image and file are sent as multipart form data using the Dio library.
  ///
  /// The [id] parameter represents the user's ID.
  ///
  /// Returns a [Future] that completes with a [User] object if the image and file are uploaded successfully.
  /// Returns `null` if the user cancels the image or file selection.
  /// Throws an [Exception] if there is an error during the upload process.
  Future<User?> uploadImageAndFile(int id) async {
    final imagePicker = ImagePicker();
    final dio = Dio();

    // Pick image and file
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final imagePath = pickedImage.path;
      // final filePath = pickedFile.files.single.path;
      final url =
          '${AuthRepo.SERVER}/user/uploadProfileImage'; // Replace with your Node.js server endpoint

      try {
        final formData = FormData.fromMap({
          'id': id,
          'file': await MultipartFile.fromFile(imagePath,
              filename: 'image.jpg'), // Assuming JPEG format
          // 'file': await MultipartFile.fromFile(filePath!),
        });

        final response = await dio.put(url, data: formData,
            onSendProgress: (progress, index) {
          print('Upload progress: ${progress.toStringAsFixed(2)}%');
        });

        if (response.statusCode == 200) {
          print('Image and file uploaded successfully!');
          print(response
              .data); // Handle the response from the server (e.g., success message)
        } else {
          print('Error uploading: ${response.statusCode}');
          throw Exception('Failed to upload image and file');
        }
        return User.fromMap(response.data['user']);
      } on Exception catch (e) {
        print('Error during upload: $e');
      }
    } else {
      print('User canceled image or file selection.');
    }
    return null;
  }
}

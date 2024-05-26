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

  Future<User?> setProfilePic(String filePath) async {
    try {
      final _user = await authRepo.user;
      print(basename(filePath));
      final file = await MultipartFile.fromFile(filePath,
          filename: basename(filePath), contentType: MediaType('image', 'png'));
      print(file);
      Map<String, dynamic> data = {'file': file, 'id': _user!.id};
      FormData formData = FormData.fromMap(data);

      Response res = await dio.put('${AuthRepo.SERVER}/user/uploadProfileImage',
          data: formData);
      print(res.data);
      return User.fromMap(res.data['user']);
    } catch (e) {
      print(e);
    }
  }

  Future<List<Map<String, dynamic>>> getUserFriend() async {
    try {
      User? user = await authRepo.user;
      var id = user!.id;
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

  Future<List<Map<String, dynamic>>> getUserPost() async {
    try {
      User? user = await authRepo.user;
      var id = user!.id;
      Response res = await dio.get('${AuthRepo.SERVER}/user/getUserPost/$id');
      List<dynamic> posts = res.data;
      List<Map<String, dynamic>> postList =
          posts.map((post) => post as Map<String, dynamic>).toList();
      return postList;
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getUserLikedPost() async {
    try {
      User? user = await authRepo.user;
      var id = user!.id;
      Response res =
          await dio.get('${AuthRepo.SERVER}/user/getUserLikedPost/$id');
      List<dynamic> likedPosts = res.data;
      List<Map<String, dynamic>> likedPostList =
          likedPosts.map((post) => post as Map<String, dynamic>).toList();
      return likedPostList;
    } catch (e) {
      print(e);
      return [];
    }
  }

// write a function for getUserFriend in 'getUserFriend/:id' and return in List<Map<String, dynamic>> type

  Future<User?> editProfile(
      String first_name,
      String last_name,
      String username,
      String bio,
      String phonenumber,
      String gender,
      String birthday) async {
    try {
      final _user = await authRepo.user;
      Map<String, dynamic> data = {
        'id': _user!.id,
        'first_name': first_name,
        'last_name': last_name,
        'username': username,
        'bio': bio,
        'phonenumber': phonenumber,
        'gender': gender,
        'birthday': birthday,
      };
      Response res =
          await dio.put('${AuthRepo.SERVER}/user/editProfile', data: data);
      print(res.data['user']);
      return User.fromMap(res.data['user']);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<String?> getImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    print(file);
    if (file != null) {
      final savedImage = await _saveLocally(File(file.path));
      return file.path;
    }
  }

  Future<void> pickFile() async {
    final file = await FilePicker.platform.pickFiles();
    if (file != null) {}
  }

  Future<File> _saveLocally(File image) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final dirc = await getApplicationDocumentsDirectory();
    final filename = basename(image.path);
    final savedImage = File('${dirc.path}/$filename');
    await prefs.setString('profilepic', savedImage.path);
    await image.copy(savedImage.path);

    return savedImage;
  }

  Future<User?> uploadImageAndFile(int id) async {
    final imagePicker = ImagePicker();
    final dio = Dio();

    // Pick image and file
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);
    // final pickedFile =
    //     await FilePicker.platform.pickFiles(allowMultiple: false);
//  && pickedFile!.files.isNotEmpty
    if (pickedImage != null) {
      final imagePath = pickedImage.path;
      // final filePath = pickedFile.files.single.path;
      final url = AuthRepo.SERVER +
          '/user/uploadProfileImage'; // Replace with your Node.js server endpoint

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
  }
}

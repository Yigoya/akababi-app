import 'dart:io';

import 'package:akababi/model/User.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepo {
  final authRepo = AuthRepo();
  final dio = Dio();

  Future<User?> setProfilePic(int id) async {
    try {
      print("object");
      final _user = await authRepo.user;
      String? filePath = await getImage();
      print(filePath);
      if (filePath != null) {
        print(basename(filePath));
        final file = await MultipartFile.fromFile(filePath,
            filename: basename(filePath));
        print(file);
        Map<String, dynamic> data = {'file': file, 'id': id};
        FormData formData = FormData.fromMap(data);

        Response res = await dio
            .put('${AuthRepo.SERVER}/user/uploadProfileImage', data: formData);
        print(res.data['user']);
        return User.fromMap(res.data['user']);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<String?> getImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    print(file);
    if (file != null) {
      // await setProfilePic();
      final savedImage = await _saveLocally(File(file.path));
      return file.path;
      // return savedImage.path;
    }
  }

  Future<void> pickFile() async {
    final file = await FilePicker.platform.pickFiles();
    if (file != null) {
      // setState(() {
      //   _file = File(file.files.first.path!);
      //   filetype = 'file';
      //   filePath = file.files.first.path!;
      // });
    }
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

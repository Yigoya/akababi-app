// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class Profile extends StatefulWidget {
//   const Profile({super.key});

//   @override
//   State<Profile> createState() => _ProfileState();
// }

// class _ProfileState extends State<Profile> {
//   File? _image;
//   @override
//   void initState() {
//     super.initState();
//     getprofilepic();
//   }

//   Future<File?> getImage() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     final value = prefs.getString('profilepic') ?? '';
//     print(value);
//     if (value == '') return null;
//     return File(value);
//   }

//   void getprofilepic() async {
//     File? image = await getImage();
//     setState(() {
//       _image = image;
//     });
//   }

//   Future<void> setProfilePic(String filePath) async {
//     User? _user = await user();
//     Dio dio = Dio();
//     Map<String, dynamic> data = await getSignedUser();

//     data['avatar'] =
//         await MultipartFile.fromFile(filePath, filename: basename(filePath));
//     print('CHECK: $data');
//     FormData formData = FormData.fromMap(data);
//     try {
//       Response res = await dio.put('${server}/api/setprofile/${_user!.id}',
//           data: formData);
//     } catch (e) {
//       print("Error $e");
//     }
//   }

//   Future<void> getImage() async {
//     final picker = ImagePicker();
//     final file = await picker.pickImage(source: ImageSource.gallery);
//     if (file != null) {
//       await setProfilePic(file.path);
//       final savedImage = await _saveLocally(File(file.path));

//       setState(() {
//         _image = savedImage;
//       });
//     }
//   }

//   Future<void> pickFile() async {
//     final file = await FilePicker.platform.pickFiles();
//     if (file != null) {
//       setState(() {
//         _file = File(file.files.first.path!);
//         filetype = 'file';
//         filePath = file.files.first.path!;
//       });
//     }
//   }

//   Future<File> _saveLocally(File image) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();

//     final dirc = await getApplicationDocumentsDirectory();
//     final filename = basename(image.path);
//     final savedImage = File('${dirc.path}/$filename');
//     await prefs.setString('profilepic', savedImage.path);
//     await image.copy(savedImage.path);

//     return savedImage;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Profile'),
//       ),
//       body: Container(
//         child: Column(
//           children: [
//             // Image.asset('assets/image/profile.jpeg'),
//             Text('profile'),
//             cricleAvatar(),
//             IconButton(
//                 onPressed: () async {
//                   await getImage();
//                 },
//                 icon: Icon(Icons.image))
//           ],
//         ),
//       ),
//     );
//   }

//   Widget cricleAvatar() {
//     return ClipOval(
//       child: _image == null
//           ? Image.asset(
//               'assets/image/profile.jpeg',
//               width: 100,
//               height: 100,
//               fit: BoxFit.cover,
//             )
//           : Image.file(
//               _image!,
//               width: 100,
//               height: 100,
//               fit: BoxFit.cover,
//             ),
//     );
//   }
// }

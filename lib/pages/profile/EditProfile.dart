import 'dart:io';

import 'package:akababi/pages/profile/cubit/picture_cubit.dart';
import 'package:akababi/pages/profile/cubit/profile_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfile extends StatefulWidget {
  final String name;
  const EditProfile({super.key, required this.name});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController bioController = TextEditingController();

  final TextEditingController codeController = TextEditingController();

  final TextEditingController birthController = TextEditingController();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  final TextEditingController genderController = TextEditingController();

  // @override
  // void initState() {
  //   super.initState();
  //   BlocProvider.of<PictureCubit>(context).getImage();
  //   BlocProvider.of<ProfileCubit>(context).getUser();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Profile'),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/setting');
                },
                icon: Icon(Icons.settings)),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                BlocConsumer<PictureCubit, PictureState>(
                    builder: ((context, state) {
                      if (state is PictureLoaded) {
                        return Stack(
                          children: [
                            Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                  color: Colors.white, shape: BoxShape.circle),
                              child: ClipOval(
                                  child: Image.file(
                                File(state.imagePath),
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                              )),
                            ),
                            Positioned(
                                bottom: 1,
                                right: 1,
                                child: IconButton(
                                    onPressed: () {
                                      BlocProvider.of<PictureCubit>(context)
                                          .setImage();
                                    },
                                    icon: Container(
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle),
                                        child: Icon(Icons.camera))))
                          ],
                        );
                      } else if (state is PictureEmpty) {
                        return Center(
                          child: Text("no picture"),
                        );
                      } else {
                        return Center(
                          child: Text("loading ..."),
                        );
                      }
                    }),
                    listener: ((context, state) {})),
                SizedBox(
                  height: 40,
                ),
                BlocConsumer<ProfileCubit, ProfileState>(
                    builder: ((context, state) {
                      if (state is ProfileLoaded) {
                        print(state.user.date_of_birth);
                        birthController.text = state.user.date_of_birth ?? '';
                        return Column(
                          children: [
                            InputField(state.user.fullname, 'Full Name',
                                nameController, 'fullname'),
                            InputField(state.user.username, 'User Name',
                                usernameController, 'username'),
                            InputField(state.user.bio, 'Edit your bio',
                                bioController, 'bio'),
                            InputField(state.user.phonenumber, 'Phone Number',
                                phoneController, 'phonenumber'),
                            InputField(state.user.gender, 'Gender',
                                genderController, 'gender'),
                            Container(
                              padding: EdgeInsets.only(left: 10),
                              margin: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                              ),
                              child: TextField(
                                onTap: () {
                                  _selectDate();
                                },
                                readOnly: true,
                                controller: birthController,
                                decoration: InputDecoration(
                                  labelText: 'BIRTH DATE',
                                  filled: true,
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 10),
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                              ),
                            ),
                          ],
                        );
                      } else if (state is PictureEmpty) {
                        return Center(
                          child: Text("no picture"),
                        );
                      } else {
                        return Center(
                          child: Text("loading ..."),
                        );
                      }
                    }),
                    listener: ((context, state) {})),

                ElevatedButton(
                    onPressed: () {
                      BlocProvider.of<ProfileCubit>(context).editProfile(
                        fullname: nameController.text,
                        username: usernameController.text,
                        bio: bioController.text,
                        phonenumber: phoneController.text,
                        gender: genderController.text,
                        birthday: birthController.text,
                      );
                      Navigator.pop(context);
                    },
                    child: Text("save change")),
                // ElevatedButton(
                //     onPressed: () async {
                //       // final pref = await SharedPreferences.getInstance();
                //       // pref.remove('imagePath');
                //     },
                //     child: Text("delete image"))
              ],
            ),
          ),
        ));
  }

  Widget InputField(String? text, String hint, TextEditingController controller,
      String name) {
    controller.text = text ?? '';
    return Container(
      padding: EdgeInsets.only(left: 10),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: Colors.white,
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(0.5),
          //     offset: Offset(0, 1),
          //     blurRadius: 1,
          //   )
          // ],
          // border: Border.all(color: Colors.black.withOpacity(0.3), width: 1),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(hint),
          TextField(
            autofocus: widget.name == name,
            controller: controller,
            decoration: InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              border: OutlineInputBorder(),
              isDense: true,
              labelText: hint,
              hintStyle: TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    DateTime? _picked = await showDatePicker(
        context: context,
        initialDate: DateTime(2000),
        firstDate: DateTime(1960),
        lastDate: DateTime(2050));
    if (_picked != null) {
      print(_picked.toString());

      birthController.text = _picked.toString().split(" ")[0];
    }
  }
}

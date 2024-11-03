import 'dart:io';

import 'package:akababi/component/Error.dart';
import 'package:akababi/pages/profile/cubit/picture_cubit.dart';
import 'package:akababi/pages/profile/cubit/profile_cubit.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
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
          title: const Text('Profile'),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/setting');
                },
                icon: const Icon(Icons.settings)),
          ],
        ),
        body: SingleChildScrollView(
          child: SizedBox(
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
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
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
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle),
                                        child: const Icon(Icons.camera))))
                          ],
                        );
                      } else if (state is PictureEmpty) {
                        if (state.imagePath != '') {
                          return Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle),
                                child: ClipOval(
                                    child: Image(
                                  image: NetworkImage(
                                      "${AuthRepo.SERVER}/${state.imagePath}"),
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
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle),
                                          child: const Icon(Icons.camera))))
                            ],
                          );
                        }
                        return ClipOval(
                          child: IconButton(
                            onPressed: () {
                              BlocProvider.of<PictureCubit>(context).setImage();
                            },
                            icon: Container(
                              decoration:
                                  const BoxDecoration(color: Colors.black),
                              child: const Icon(
                                Icons.person,
                                size: 150,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      } else {
                        return const Center(
                          child: Text("loading ..."),
                        );
                      }
                    }),
                    listener: ((context, state) {})),
                const SizedBox(
                  height: 40,
                ),
                BlocConsumer<ProfileCubit, ProfileState>(
                    builder: ((context, state) {
                      if (state is ProfileLoaded) {
                        print(state.user.date_of_birth);
                        birthController.text = state.user.date_of_birth ?? '';
                        return Column(
                          children: [
                            ErrorItem(error: state.error),
                            InputField(state.user.fullname, 'Full Name',
                                nameController, 'fullname'),
                            InputField(state.user.bio, 'Edit your bio',
                                bioController, 'bio'),
                            InputField(state.user.phonenumber, 'Phone Number',
                                phoneController, 'phonenumber'),
                            InputField(state.user.gender, 'Gender',
                                genderController, 'gender'),
                            Container(
                              padding: const EdgeInsets.only(left: 10),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                              ),
                              child: TextField(
                                onTap: () {
                                  _selectDate();
                                },
                                readOnly: true,
                                controller: birthController,
                                decoration: const InputDecoration(
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
                        return const Center(
                          child: Text("no picture"),
                        );
                      } else {
                        return const Center(
                          child: Text("loading ..."),
                        );
                      }
                    }),
                    listener: ((context, state) {})),

                ElevatedButton(
                    onPressed: () async {
                      final res = await BlocProvider.of<ProfileCubit>(context)
                          .editProfile(
                        fullname: nameController.text,
                        bio: bioController.text,
                        phonenumber: phoneController.text,
                        gender: genderController.text.toLowerCase(),
                        birthday: birthController.text,
                      );
                      if (res) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("save change")),
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
      padding: const EdgeInsets.only(left: 10),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              border: const OutlineInputBorder(),
              isDense: true,
              labelText: hint,
              hintStyle: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime(2000),
        firstDate: DateTime(1960),
        lastDate: DateTime(2050));
    if (picked != null) {
      print(picked.toString());

      birthController.text = picked.toString().split(" ")[0];
    }
  }
}

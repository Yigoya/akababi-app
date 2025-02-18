import 'dart:io';

import 'package:akababi/pages/auth/components/common_button.dart';
import 'package:akababi/pages/profile/cubit/picture_cubit.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePicturePage extends StatefulWidget {
  const ProfilePicturePage({super.key});

  @override
  State<ProfilePicturePage> createState() => _ProfilePicturePageState();
}

class _ProfilePicturePageState extends State<ProfilePicturePage> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<PictureCubit>(context).getImage();
  }

  bool isLeading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Add a profile picture",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Add a profile picture so that your friends know it's you.\nEveryone will be able to see your picture",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 30),
              BlocBuilder<PictureCubit, PictureState>(
                builder: ((context, state) {
                  if (state is PictureLoaded) {
                    return Column(
                      children: [
                        Stack(
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
                        ),
                        const SizedBox(height: 30),
                        CommonButton(
                          active: true,
                          buttonText: "Get Started",
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                                context, "/", (route) => false);
                          },
                        ),
                      ],
                    );
                  } else {
                    // if (state.imagePath != '') {
                    //   return Column(
                    //     children: [
                    //       Stack(
                    //         children: [
                    //           Container(
                    //             padding: const EdgeInsets.all(4),
                    //             decoration: const BoxDecoration(
                    //                 color: Colors.white,
                    //                 shape: BoxShape.circle),
                    //             child: ClipOval(
                    //                 child: Image(
                    //               image: NetworkImage(
                    //                   "${AuthRepo.SERVER}/${state.imagePath}"),
                    //               width: 150,
                    //               height: 150,
                    //               fit: BoxFit.cover,
                    //             )),
                    //           ),
                    //           Positioned(
                    //               bottom: 1,
                    //               right: 1,
                    //               child: IconButton(
                    //                   onPressed: () {
                    //                     BlocProvider.of<PictureCubit>(context)
                    //                         .setImage();
                    //                   },
                    //                   icon: Container(
                    //                       padding: const EdgeInsets.all(4),
                    //                       decoration: const BoxDecoration(
                    //                           color: Colors.white,
                    //                           shape: BoxShape.circle),
                    //                       child: const Icon(Icons.camera))))
                    //         ],
                    //       ),
                    //       const SizedBox(height: 30),
                    //       CommonButton(
                    //         active: true,
                    //         buttonText: "Add Picture",
                    //         onPressed: () {
                    //           BlocProvider.of<PictureCubit>(context).setImage();
                    //         },
                    //       ),
                    //       const SizedBox(height: 10),
                    //       TextButton(
                    //         onPressed: () {
                    //           // Skip
                    //           Navigator.pushNamedAndRemoveUntil(
                    //               context, "/", (route) => false);
                    //         },
                    //         child: const Text(
                    //           "Skip",
                    //           style: TextStyle(fontSize: 18, color: Colors.red),
                    //         ),
                    //       ),
                    //     ],
                    //   );
                    // }
                    return Column(
                      children: [
                        ClipOval(
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                isLeading = true;
                              });
                              BlocProvider.of<PictureCubit>(context).setImage();
                              setState(() {
                                isLeading = false;
                              });
                            },
                            icon: Container(
                              decoration:
                                  const BoxDecoration(color: Colors.black),
                              child: isLeading
                                  ? CircularProgressIndicator()
                                  : const Icon(
                                      Icons.person,
                                      size: 150,
                                      color: Colors.white,
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        CommonButton(
                          active: true,
                          buttonText: "Skip",
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                                context, "/", (route) => false);
                          },
                        ),
                      ],
                    );
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore_for_file: use_build_context_synchronously

import 'package:akababi/component/GoogleLogin.dart';
import 'package:akababi/pages/profile/cubit/profile_cubit.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeactivatedPage extends StatefulWidget {
  const DeactivatedPage({super.key});

  @override
  State<DeactivatedPage> createState() => _DeactivatedPageState();
}

class _DeactivatedPageState extends State<DeactivatedPage> {
  String? selectedReason;

  String? googleId;

  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initFunction();
  }

  void initFunction() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      googleId = prefs.getString('googleId');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deactivated Account'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Your account has been deactivated.',
                style: GoogleFonts.kodchasan(
                  textStyle: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                      color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.7)),
                )),
            const SizedBox(height: 20),
            googleId != null
                ? GoogleLogin(
                    func: () => signIn(context), text: "Reactivate with Google")
                : Column(
                    children: [
                      const Text(
                        'Confirm by Password',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Enter Password',
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            final res =
                                await BlocProvider.of<ProfileCubit>(context)
                                    .deactivateUser(passwordController.text);
                            if (res) {
                              BlocProvider.of<ProfileCubit>(context)
                                  .logOut(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: const Text('Confirm'),
                        ),
                      ),
                    ],
                  )
          ],
        ),
      ),
    );
  }

  Future signIn(BuildContext context) async {
    AuthRepo authRepo = AuthRepo();
    await GoogleSignIn().signOut();
    GoogleSignInAccount? googleSignIn = await GoogleSignIn().signIn();

    if (googleSignIn != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var googleId = prefs.getString('googleId');
      print('googleId: $googleId');
      if (googleSignIn.id == googleId) {
        final res = await BlocProvider.of<ProfileCubit>(context).reactivateUser(
            {'password': googleId, "email": googleSignIn.email});
        if (res) {
          BlocProvider.of<ProfileCubit>(context).logOut(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Email not verified'),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Email not verified'),
        ));
      }
    }
  }
}

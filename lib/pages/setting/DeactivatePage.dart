import 'package:akababi/component/GoogleLogin.dart';
import 'package:akababi/pages/profile/cubit/profile_cubit.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeactivatePage extends StatefulWidget {
  const DeactivatePage({super.key});

  @override
  _DeactivatePageState createState() => _DeactivatePageState();
}

class _DeactivatePageState extends State<DeactivatePage> {
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
        title: const Text('Deactivate account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.grey[200],
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Are you sure you want to deactivate your account?',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Deactivating your account will disable your profile and remove your name and photos from most things you have shared on the platform. Some information may still be visible to others, such as your name in their friends list and messages you sent. Your account will be reactivated if you log in to the platform again. If you are sure you want to proceed, please confirm by typing your password and clicking on the \'Deactivate Account\' button below.',
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              googleId != null
                  ? GoogleLogin(
                      func: () => signIn(context), text: "verify your Email")
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
      if (googleSignIn.id == googleId) {
        final res = await BlocProvider.of<ProfileCubit>(context)
            .deactivateUser(googleId!);
        if (res) {
          BlocProvider.of<ProfileCubit>(context).logOut(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Email not verified'),
          ));
        }
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        //   content: Text('Email Verified'),
        // ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Email not verified'),
        ));
      }
    }
  }
}

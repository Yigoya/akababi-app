import 'package:akababi/component/Error.dart';
import 'package:akababi/pages/auth/DeactivatedPage.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:akababi/utility.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:akababi/bloc/auth/auth_bloc.dart';
import 'package:akababi/bloc/auth/auth_event.dart';
import 'package:akababi/bloc/auth/auth_state.dart';
import 'package:akababi/component/Button.dart';
import 'package:akababi/component/GoogleLogin.dart';
import 'package:akababi/component/OptionText.dart';
import 'package:akababi/component/TextInput.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context)..add(InitialEvent());
    return Scaffold(body: BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        print(state);
        if (state is InitialState) {
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/image/login.png"),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      const Text(
                        "Welcome back",
                        style: TextStyle(
                            fontSize: 40,
                            color: Color.fromARGB(255, 255, 156, 7)),
                      ),
                      Text(
                        "enter your information and enjoy your ride",
                        style: TextStyle(
                            fontSize: 15, color: Colors.black.withOpacity(0.7)),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      ErrorItem(
                        error: state.error,
                        isLoading: state.isLoading,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextInput(
                          controller: emailController,
                          hint: "Enter your email or phone number",
                          isPass: false),
                      const SizedBox(
                        height: 15,
                      ),
                      TextInput(
                          controller: passwordController,
                          hint: "Enter your password",
                          isPass: true),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OptionText(
                              func: () {
                                Navigator.pushNamed(context, '/forgetpassword');
                              },
                              text: 'forgot your password ?'),
                          Button(
                              func: () => authBloc.add(LoginEvent(
                                  emailController.text.trim(),
                                  passwordController.text,
                                  context)),
                              text: "Login"),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      GoogleLogin(
                          text: "sign in with google",
                          func: () => signIn(context)),
                      const SizedBox(
                        height: 10,
                      ),
                      OptionText(
                          func: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          text: 'create new account'),
                      const SizedBox(
                        height: 30,
                      ),
                      // BlocListener<AuthBloc, AuthState>(
                      //   listener: (context, state) {
                      //     if (state is LoginState) {
                      //       print("login is triggered");
                      //     }
                      //   },
                      //   child: Text("data"),
                      // )
                    ],
                  ),
                )
              ],
            ),
          );
        } else if (state is LoadingState) {
          return const Center(child: CircularProgressIndicator.adaptive());
          // } else if (state is LoginState) {
          //   return Center(child: Text(state.token));
        } else {
          return const Text("error");
        }
      },
    ));
  }

  Future signIn(BuildContext context) async {
    AuthRepo authRepo = AuthRepo();
    await GoogleSignIn().signOut();
    GoogleSignInAccount? googleSignIn = await GoogleSignIn().signIn();

    if (googleSignIn != null) {
      print(googleSignIn.id);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('googleId', googleSignIn.id);
      try {
        final user = await authRepo.signinWithGoogle(
            googleSignIn.id,
            googleSignIn.email,
            googleSignIn.displayName!,
            googleSignIn.photoUrl);
        if (user != null) {
          if (user.status == 'deactivated') {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const DeactivatedPage()));
          } else if (user.status == 'deleted') {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('User deleted'),
            ));
          } else {
            final res = await authRepo.setUser(user);
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          }
        } else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('User not found'),
          ));
        }
      } catch (err) {
        if (err is DioException) {
          String error = handleDioError(err);
          print(error);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Email Account already exist Signed in with email'),
          ));
        }
        // print('The error $err');
      }
    } else {
      print(googleSignIn!.photoUrl);
    }
  }
}

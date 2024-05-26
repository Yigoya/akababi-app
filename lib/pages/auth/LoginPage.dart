import 'package:akababi/api/google_signin_api.dart';
import 'package:akababi/component/Error.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
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
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      Text(
                        "Welcome back",
                        style: TextStyle(
                            fontSize: 40,
                            color: const Color.fromARGB(255, 255, 156, 7)),
                      ),
                      Text(
                        "enter your information and enjoy your ride",
                        style: TextStyle(
                            fontSize: 15, color: Colors.black.withOpacity(0.7)),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      ErrorItem(
                        error: state.error,
                        isLoading: state.isLoading,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextInput(
                          controller: emailController,
                          hint: "Enter your email or phone number",
                          isPass: false),
                      SizedBox(
                        height: 15,
                      ),
                      TextInput(
                          controller: passwordController,
                          hint: "Enter your password",
                          isPass: true),
                      SizedBox(
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
                                  emailController.text,
                                  passwordController.text,
                                  context)),
                              text: "Login"),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GoogleLogin(func: () => signIn(context)),
                      SizedBox(
                        height: 10,
                      ),
                      OptionText(
                          func: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          text: 'create new account'),
                      SizedBox(
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
          return Center(child: const CircularProgressIndicator.adaptive());
          // } else if (state is LoginState) {
          //   return Center(child: Text(state.token));
        } else {
          return Text("error");
        }
      },
    ));
  }

  Future signIn(BuildContext context) async {
    AuthRepo authRepo = AuthRepo();
    await GoogleSignIn().signOut();
    GoogleSignInAccount? _googleSignIn = await GoogleSignIn().signIn();

    if (_googleSignIn != null) {
      print('###############');
      print(_googleSignIn.email);
      final auth = await _googleSignIn.authentication;
      try {
        final user = await authRepo.signinWithGoogle(
            _googleSignIn.id,
            _googleSignIn.email,
            _googleSignIn.displayName!,
            _googleSignIn.photoUrl);
        final res = await authRepo.setUser(user!);
      } catch (err) {
        print('The error $err');
      }
      Navigator.pushNamed(context, '/');
    } else {
      print(
          '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@2');
      // print(auth.accessToken);
      print(_googleSignIn!.photoUrl);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:akababi/bloc/auth/auth_bloc.dart';
import 'package:akababi/bloc/auth/auth_event.dart';
import 'package:akababi/bloc/auth/auth_state.dart';
import 'package:akababi/component/Button.dart';
import 'package:akababi/component/GoogleLogin.dart';
import 'package:akababi/component/OptionText.dart';
import 'package:akababi/component/TextInput.dart';

class SignupPage extends StatelessWidget {
  SignupPage({super.key});

  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context);
    return Scaffold(body: BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        print('sign in $state');
        if (state is InitialState) {
          print(state.error);

          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/image/login.png",
                  width: 250,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      Text(
                        "Welcome",
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
                      state.error != null
                          ? Container(
                              child: Text(state.error!),
                            )
                          : Container(),
                      TextInput(
                          controller: fullnameController,
                          hint: "Enter your full Name",
                          isPass: false),
                      SizedBox(
                        height: 15,
                      ),
                      TextInput(
                          controller: emailController,
                          hint: "Enter your email",
                          isPass: false),
                      SizedBox(
                        height: 15,
                      ),
                      TextInput(
                          controller: phoneController,
                          hint: "Enter your phone number",
                          isPass: false),
                      SizedBox(
                        height: 15,
                      ),
                      TextInput(
                          controller: passwordController,
                          hint: "Enter your password",
                          isPass: true),
                      SizedBox(
                        height: 15,
                      ),
                      TextInput(
                          controller: confirmController,
                          hint: "Confirm password",
                          isPass: true),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Container(),
                          // Button(
                          //     func: () => authBloc.add(SignUpEvent(
                          //         fullnameController.text,
                          //         emailController.text,
                          //         phoneController.text,
                          //         passwordController.text,
                          //         confirmController.text,
                          //         context)),
                          //     text: "SignUp"),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GoogleLogin(func: () {}),
                      SizedBox(
                        height: 10,
                      ),
                      OptionText(func: () {}, text: 'already have account'),
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
          // } else if (state is SignUpState) {
          //   return Center(child: Text(state.token ?? "no token"));
        } else {
          return Center(child: Text("error"));
        }
      },
    ));
  }
}

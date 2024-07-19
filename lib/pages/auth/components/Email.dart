import 'package:akababi/component/Button.dart';
import 'package:akababi/component/Error.dart';
import 'package:akababi/component/OptionText.dart';
import 'package:akababi/component/TextInput.dart';
import 'package:flutter/material.dart';

class Email extends StatelessWidget {
  final TextEditingController emailController;
  final String? error;
  final bool? isLoading;
  final bool isForForgetPassword;
  final void Function() fun;
  const Email(
      {super.key,
      required this.emailController,
      required this.error,
      this.isForForgetPassword = false,
      required this.fun,
      required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/image/bgauth.jpg'), fit: BoxFit.cover)),
      child: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: !isForForgetPassword
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              isForForgetPassword
                  ? const SizedBox(
                      height: 120,
                    )
                  : const SizedBox(
                      height: 0,
                    ),
              !isForForgetPassword
                  ? const Text(
                      "Sign Up",
                      style: TextStyle(
                          fontSize: 40,
                          color: Color.fromARGB(255, 255, 156, 7)),
                    )
                  : Container(),
              !isForForgetPassword
                  ? Text(
                      "enter your information and enjoy your ride",
                      style: TextStyle(
                          fontSize: 15, color: Colors.black.withOpacity(0.7)),
                    )
                  : Text(
                      "enter email address to get verification code",
                      style: TextStyle(
                          fontSize: 15, color: Colors.black.withOpacity(0.7)),
                    ),
              !isForForgetPassword
                  ? const SizedBox(
                      height: 30,
                    )
                  : const SizedBox(
                      height: 0,
                    ),
              ErrorItem(
                error: error,
                isLoading: isLoading,
              ),

              const SizedBox(
                height: 15,
              ),
              TextInput(
                  controller: emailController,
                  hint: "Enter your email",
                  isPass: false),

              const SizedBox(
                height: 20,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(),
                  Button(
                      func: fun,
                      // func: () => authBloc
                      //     .add(EmailVarifyEvent(emailController.text.trip(), context)),
                      text: "Next"),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              const SizedBox(
                height: 10,
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
        ),
      ),
    );
  }
}

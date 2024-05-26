import 'package:akababi/component/Button.dart';
import 'package:akababi/component/Error.dart';
import 'package:akababi/component/GoogleLogin.dart';
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
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/image/bgauth.jpg'), fit: BoxFit.cover)),
      child: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: !isForForgetPassword
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              isForForgetPassword
                  ? SizedBox(
                      height: 120,
                    )
                  : SizedBox(
                      height: 0,
                    ),
              !isForForgetPassword
                  ? Text(
                      "Sign Up",
                      style: TextStyle(
                          fontSize: 40,
                          color: const Color.fromARGB(255, 255, 156, 7)),
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
                  ? SizedBox(
                      height: 30,
                    )
                  : SizedBox(
                      height: 0,
                    ),
              ErrorItem(
                error: error,
                isLoading: isLoading,
              ),

              SizedBox(
                height: 15,
              ),
              TextInput(
                  controller: emailController,
                  hint: "Enter your email",
                  isPass: false),

              SizedBox(
                height: 20,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(),
                  Button(
                      func: fun,
                      // func: () => authBloc
                      //     .add(EmailVarifyEvent(emailController.text, context)),
                      text: "Next"),
                ],
              ),
              SizedBox(
                height: 20,
              ),
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
        ),
      ),
    );
  }
}

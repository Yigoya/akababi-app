import 'package:akababi/bloc/auth/auth_bloc.dart';
import 'package:akababi/bloc/auth/auth_event.dart';
import 'package:akababi/component/Button.dart';
import 'package:akababi/component/Error.dart';
import 'package:akababi/component/PasswordTextField.dart';
import 'package:akababi/component/TextInput.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserPass extends StatefulWidget {
  final TextEditingController phoneController;

  final TextEditingController passwordController;

  final TextEditingController confirmController;
  final TextEditingController usernameController;
  final bool isForForgetPassword;
  final void Function() fun;
  final void Function()? funPassForget;
  final String? error;
  final bool? isLoading;
  const UserPass({
    super.key,
    required this.confirmController,
    required this.passwordController,
    required this.phoneController,
    required this.usernameController,
    this.isForForgetPassword = false,
    this.funPassForget,
    required this.fun,
    required this.error,
    required this.isLoading,
  });

  @override
  State<UserPass> createState() => _UserPassState();
}

class _UserPassState extends State<UserPass> {
  bool isChecked = false;
  bool isPasswordValide = false;
  void setPasswordValide() {
    setState(() {
      isPasswordValide = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        print("object");
        BlocProvider.of<AuthBloc>(context).add(BackEvent());
      },
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 150,
            ),
            Text(
              "Enter relevant Information",
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.black.withOpacity(0.5),
                  fontWeight: FontWeight.bold),
            ),
            ErrorItem(
              error: widget.error,
              isLoading: widget.isLoading,
            ),
            const SizedBox(
              height: 10,
            ),
            !widget.isForForgetPassword
                ? Column(
                    children: [
                      TextInput(
                          controller: widget.usernameController,
                          hint: "Enter user name",
                          isPass: false),
                      const SizedBox(
                        height: 20,
                      ),
                      // TextInput(
                      //     controller: phoneController,
                      //     hint: "Phone Number ",
                      //     isPass: false),
                    ],
                  )
                : Container(),
            PasswordTextField(
              fun: setPasswordValide,
              controller: widget.passwordController,
              hint: !widget.isForForgetPassword
                  ? "Enter password"
                  : "New Password",
            ),
            const SizedBox(
              height: 20,
            ),
            TextInput(
                controller: widget.confirmController,
                hint: "Confirm a password",
                isPass: true),
            const SizedBox(
              height: 20,
            ),
            !widget.isForForgetPassword
                ? Row(
                    children: [
                      Checkbox(
                          value: isChecked,
                          onChanged: (value) {
                            setState(() {
                              isChecked = value!;
                            });
                          }),
                      const Text("i accept the "),
                      GestureDetector(
                        onTap: () async {
                          await Navigator.pushNamed(context, '/policy');
                          BlocProvider.of<AuthBloc>(context)
                              .add(GetUserInfoEvent());
                        },
                        child: const Text(
                          "terms and conditions",
                          style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline),
                        ),
                      )
                    ],
                  )
                : Container(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(),
                Button(
                    isEnabled: isChecked || widget.isForForgetPassword,
                    func: widget.funPassForget != null
                        ? widget.funPassForget!
                        : widget.fun,
                    text: widget.isForForgetPassword
                        ? "Change Password"
                        : "Sign Up"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

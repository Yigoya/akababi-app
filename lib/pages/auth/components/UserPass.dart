import 'package:akababi/bloc/auth/auth_bloc.dart';
import 'package:akababi/bloc/auth/auth_event.dart';
import 'package:akababi/component/Button.dart';
import 'package:akababi/component/Error.dart';
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
            SizedBox(
              height: 10,
            ),
            !widget.isForForgetPassword
                ? Column(
                    children: [
                      TextInput(
                          controller: widget.usernameController,
                          hint: "Enter user name",
                          isPass: false),
                      SizedBox(
                        height: 20,
                      ),
                      // TextInput(
                      //     controller: phoneController,
                      //     hint: "Phone Number ",
                      //     isPass: false),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  )
                : Container(),
            TextInput(
                controller: widget.passwordController,
                hint: !widget.isForForgetPassword
                    ? "Enter password"
                    : "New Password",
                isPass: true),
            SizedBox(
              height: 20,
            ),
            TextInput(
                controller: widget.confirmController,
                hint: "Confirm a password",
                isPass: true),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Checkbox(
                    value: isChecked,
                    onChanged: (value) {
                      setState(() {
                        isChecked = value!;
                      });
                    }),
                Text("i accept the "),
                GestureDetector(
                  onTap: () async {
                    await Navigator.pushNamed(context, '/policy');
                    BlocProvider.of<AuthBloc>(context).add(GetUserInfoEvent());
                  },
                  child: Text(
                    "terms and conditions",
                    style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(),
                Button(
                    isEnabled: isChecked,
                    func: widget.funPassForget != null
                        ? widget.funPassForget!
                        : widget.fun,
                    text: "Sign Up"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

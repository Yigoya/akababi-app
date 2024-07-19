import 'package:akababi/bloc/auth/auth_bloc.dart';
import 'package:akababi/bloc/auth/auth_event.dart';
import 'package:akababi/component/Button.dart';
import 'package:akababi/component/Error.dart';
import 'package:akababi/component/TextInput.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CodeVerify extends StatelessWidget {
  final TextEditingController codeController;
  final TextEditingController emailController;
  final String? error;
  final bool? isLoading;
  final void Function() fun;
  const CodeVerify(
      {super.key,
      required this.codeController,
      required this.emailController,
      required this.fun,
      required this.error,
      required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        print("object");
        BlocProvider.of<AuthBloc>(context).add(InitialEvent());
      },
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 200,
            ),
            Text(
              "Check your Gmail App to find varification code",
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.black.withOpacity(0.5),
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            ErrorItem(
              error: error,
              isLoading: isLoading,
            ),
            const SizedBox(
              height: 10,
            ),
            TextInput(
                controller: codeController,
                hint: "Enter 6 digit code ",
                isPass: false),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(),
                Button(func: fun, text: "Verify"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:akababi/pages/auth/components/CodeVerify.dart';
import 'package:akababi/pages/auth/components/Email.dart';
import 'package:akababi/pages/auth/components/UserPass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:akababi/bloc/auth/auth_bloc.dart';
import 'package:akababi/bloc/auth/auth_event.dart';
import 'package:akababi/bloc/auth/auth_state.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

enum Gender { male, female }

class _ForgetPasswordState extends State<ForgetPassword> {
  final TextEditingController usernameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmController = TextEditingController();

  final TextEditingController codeController = TextEditingController();

  final TextEditingController birthController = TextEditingController();

  final TextEditingController fnController = TextEditingController();

  final TextEditingController lnController = TextEditingController();

  final TextEditingController genderController = TextEditingController();

  String genderValue = 'male';

  final Gender _gender = Gender.female;

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context);
    return Scaffold(body: SingleChildScrollView(
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          print('sign in $state');
          if (state is InitialState) {
            print(state.error);

            return Email(
              isLoading: state.isLoading,
              emailController: emailController,
              error: state.error,
              isForForgetPassword: true,
              fun: () => authBloc.add(ForgetPassEmailVarifyEvent(
                  emailController.text.trim(), context)),
            );
          } else if (state is LoadingState) {
            return const SizedBox(
                height: 400,
                child: Center(child: CircularProgressIndicator.adaptive()));
            // } else if (state is SignUpState) {
            //   return Center(child: Text(state.token));
          } else if (state is EmailVarifyState) {
            return CodeVerify(
                isLoading: state.isLoading,
                error: state.error,
                codeController: codeController,
                emailController: emailController,
                fun: () => authBloc.add(CodeVarifyEvent(codeController.text,
                    emailController.text.trim(), context)));
          } else if (state is CodeVarifyState) {
            return UserPass(
                isLoading: state.isLoading,
                error: state.error,
                isForForgetPassword: true,
                confirmController: confirmController,
                passwordController: passwordController,
                phoneController: phoneController,
                usernameController: usernameController,
                fun: () => authBloc.add(NewPasswordEvent(
                    emailController.text.trim(),
                    codeController.text,
                    passwordController.text,
                    confirmController.text,
                    context)));
          } else {
            return const Center(child: Text("error"));
          }
        },
      ),
    ));
  }
}

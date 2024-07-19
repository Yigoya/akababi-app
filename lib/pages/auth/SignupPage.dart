import 'package:akababi/pages/auth/components/CodeVerify.dart';
import 'package:akababi/pages/auth/components/Email.dart';
import 'package:akababi/pages/auth/components/UserInfo.dart';
import 'package:akababi/pages/auth/components/UserPass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:akababi/bloc/auth/auth_bloc.dart';
import 'package:akababi/bloc/auth/auth_event.dart';
import 'package:akababi/bloc/auth/auth_state.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

enum Gender { male, female }

class _SignupPageState extends State<SignupPage> {
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
            print(state.isLoading);

            return Email(
              isLoading: state.isLoading,
              error: state.error,
              emailController: emailController,
              fun: () => authBloc
                  .add(EmailVarifyEvent(emailController.text.trim(), context)),
            );
          } else if (state is EmailVarifyState) {
            return CodeVerify(
                isLoading: state.isLoading,
                error: state.error,
                codeController: codeController,
                emailController: emailController,
                fun: () => authBloc.add(CodeVarifyEvent(codeController.text,
                    emailController.text.trim(), context)));
          } else if (state is CodeVarifyState) {
            return UserInfo(
                fnController: fnController,
                lnController: lnController,
                birthController: birthController,
                fun: () => authBloc.add(GetUserInfoEvent()));
          } else if (state is GetInfoState) {
            return UserPass(
                isLoading: state.isLoading,
                error: state.error,
                confirmController: confirmController,
                passwordController: passwordController,
                phoneController: phoneController,
                usernameController: usernameController,
                fun: () => authBloc.add(SignUpEvent(
                    usernameController.text,
                    fnController.text,
                    lnController.text,
                    emailController.text.trim(),
                    phoneController.text,
                    passwordController.text,
                    confirmController.text,
                    genderValue,
                    birthController.text,
                    context)));
          } else {
            authBloc.add(InitialEvent());
            return const Center(child: Text("error"));
          }
        },
      ),
    ));
  }
}

// Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Container(),
//                         Button(
//                             func: () => authBloc.add(SignUpEvent(
//                                 fullnameController.text,
//                                 emailController.text.trim(),
//                                 phoneController.text,
//                                 passwordController.text,
//                                 confirmController.text,
//                                 context)),
//                             text: "SignUp"),
//                       ],
//                     ),
//                     TextInput(
//                         controller: fullnameController,
//                         hint: "Enter your full Name",
//                         isPass: false),
// SizedBox(
//                       height: 15,
//                     ),
//                     TextInput(
//                         controller: phoneController,
//                         hint: "Enter your phone number",
//                         isPass: false),
//                     SizedBox(
//                       height: 15,
//                     ),
//                     TextInput(
//                         controller: passwordController,
//                         hint: "Enter your password",
//                         isPass: true),
//                     SizedBox(
//                       height: 15,
//                     ),
//                     TextInput(
//                         controller: confirmController,
//                         hint: "Confirm password",
//                         isPass: true),
import 'package:akababi/bloc/cubit/signup_cubit.dart';
import 'package:akababi/component/loader.dart';
import 'package:akababi/pages/auth/components/common_button.dart' as cb;
import 'package:akababi/pages/auth/components/common_text_field.dart';
import 'package:akababi/pages/auth/signup/signup_terms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpPasswordPage extends StatefulWidget {
  const SignUpPasswordPage({super.key});

  @override
  State<SignUpPasswordPage> createState() => _SignUpPasswordPageState();
}

class _SignUpPasswordPageState extends State<SignUpPasswordPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  bool active = false;
  void _onChanged(String value) {
    if (passwordController.text.length >= 6) {
      setState(() {
        active = true;
      });
    } else {
      setState(() {
        active = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Create a password",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Choose a strong password to secure your account.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            BlocBuilder<SignupCubit, SignupState>(
              builder: (context, state) {
                if (state is SignupLoading) {
                  return const BeautifulLoader(isLoading: true);
                } else if (state is SignupFailed) {
                  return BeautifulLoader(
                      isLoading: false, errorMessage: state.message);
                }
                return Container();
              },
            ),
            const SizedBox(height: 10),
            CommonTextField(
              onChanged: _onChanged,
              labelText: 'username',
              controller: usernameController,
            ),
            const SizedBox(height: 20),
            CommonTextField(
              onChanged: _onChanged,
              labelText: 'Password',
              controller: passwordController,
              obscureText: true,
            ),
            const SizedBox(height: 30),
            cb.CommonButton(
              active: active,
              buttonText: 'Next',
              onPressed: () async {
                // Handle next action
                final res =
                    await BlocProvider.of<SignupCubit>(context).getData({
                  'password': passwordController.text,
                  'username': usernameController.text,
                });
                if (!res) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignUpTermsPage(),
                  ),
                );
              },
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                // Handle already have an account action
              },
              child: const Text(
                'I already have an account',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

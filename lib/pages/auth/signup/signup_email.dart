import 'package:akababi/bloc/cubit/signup_cubit.dart';
import 'package:akababi/component/loader.dart';
import 'package:akababi/pages/auth/components/common_button.dart';
import 'package:akababi/pages/auth/components/common_text_field.dart';
import 'package:akababi/pages/auth/signup/signup_code.dart';
import 'package:akababi/pages/auth/signup/signup_number.dart';
import 'package:akababi/pages/auth/signup/signup_password.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpEmailPage extends StatefulWidget {
  const SignUpEmailPage({super.key});

  @override
  State<SignUpEmailPage> createState() => _SignUpEmailPageState();
}

class _SignUpEmailPageState extends State<SignUpEmailPage> {
  final TextEditingController emailController = TextEditingController();

  bool active = false;
  void _onChanged(String value) {
    if (emailController.text.length > 9) {
      setState(() {
        active = true;
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
              "What's your email address?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Enter the email address on which you can be contacted. No one will see this on your profile.',
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
              labelText: 'Email address',
              controller: emailController,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonButton(
                  active: active,
                  buttonText: 'Next',
                  onPressed: () async {
                    // Handle next action
                    final res =
                        await BlocProvider.of<SignupCubit>(context).getData({
                      'email': emailController.text,
                    });
                    if (!res) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CodeVerificationPage(),
                      ),
                    );
                  },
                ),
                OutlinedButton(
                  onPressed: () {
                    // Handle signup with mobile number action
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignUpMobilePage()));
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20),
                  ),
                  child: const Text(
                    'Sign up with Mobile number',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              ],
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

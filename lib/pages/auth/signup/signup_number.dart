import 'package:akababi/bloc/cubit/signup_cubit.dart';
import 'package:akababi/pages/auth/components/common_button.dart';
import 'package:akababi/pages/auth/components/common_text_field.dart';
import 'package:akababi/pages/auth/signup/signup_email.dart';
import 'package:akababi/pages/auth/signup/signup_password.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpMobilePage extends StatefulWidget {
  const SignUpMobilePage({super.key});

  @override
  State<SignUpMobilePage> createState() => _SignUpMobilePageState();
}

class _SignUpMobilePageState extends State<SignUpMobilePage> {
  final TextEditingController mobileController = TextEditingController();
  bool active = false;
  void _onChanged(String value) {
    if (mobileController.text.length > 9) {
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
              "What's your mobile number?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Enter the mobile number where you can be contacted. This will not be visible on your profile.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              'You can always change who can see this later.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),
            CommonTextField(
              onChanged: _onChanged,
              labelText: 'Mobile number',
              controller: mobileController,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonButton(
                  active: active,
                  buttonText: 'Next',
                  onPressed: () {
                    // Handle next action
                  },
                ),
                OutlinedButton(
                  onPressed: () {
                    // Handle signup with mobile number action
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignUpEmailPage()));
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
                    'Sign up with Email',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              ],
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                // Handle already have an account action
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignUpEmailPage(),
                  ),
                );
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

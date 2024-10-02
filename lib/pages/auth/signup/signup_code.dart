import 'package:akababi/bloc/cubit/signup_cubit.dart';
import 'package:akababi/component/loader.dart';
import 'package:akababi/pages/auth/components/common_button.dart';
import 'package:akababi/pages/auth/components/common_text_field.dart';
import 'package:akababi/pages/auth/signup/signup_email.dart';
import 'package:akababi/pages/auth/signup/signup_password.dart';
import 'package:akababi/pages/auth/signup/signup_profile_picture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CodeVerificationPage extends StatefulWidget {
  @override
  State<CodeVerificationPage> createState() => _CodeVerificationPageState();
}

class _CodeVerificationPageState extends State<CodeVerificationPage> {
  final TextEditingController codeController = TextEditingController();

  bool active = false;
  void _onChanged(String value) {
    if (codeController.text.length > 4) {
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
            Text(
              "Enter verification code",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'We have sent a verification code to your email address.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            BlocBuilder<SignupCubit, SignupState>(
              builder: (context, state) {
                if (state is SignupLoading) {
                  return BeautifulLoader(isLoading: true);
                } else if (state is SignupFailed) {
                  return BeautifulLoader(
                      isLoading: false, errorMessage: state.message);
                }
                return Container();
              },
            ),
            SizedBox(height: 10),
            CommonTextField(
              onChanged: _onChanged,
              labelText: 'Verification code',
              controller: codeController,
            ),
            SizedBox(height: 20),
            CommonButton(
              active: active,
              buttonText: 'Verify',
              onPressed: () async {
                final res = await context
                    .read<SignupCubit>()
                    .verifyCode(codeController.text);
                if (!res) {
                  return;
                }
                // Handle verify action
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SignUpPasswordPage()));
              },
            ),
            Spacer(),
            TextButton(
              onPressed: () {
                // Handle resend code action
                context.read<SignupCubit>().resendCode();
                codeController.clear();
              },
              child: Text(
                'Resend code',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                // Handle already have an account action
              },
              child: Text(
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

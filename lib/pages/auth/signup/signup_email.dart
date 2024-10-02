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
            Text(
              "What's your email address?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Enter the email address on which you can be contacted. No one will see this on your profile.',
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
              labelText: 'Email address',
              controller: emailController,
            ),
            SizedBox(height: 30),
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
                        builder: (context) => CodeVerificationPage(),
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
                            builder: (context) => SignUpMobilePage()));
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  ),
                  child: Text(
                    'Sign up with Mobile number',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              ],
            ),
            Spacer(),
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

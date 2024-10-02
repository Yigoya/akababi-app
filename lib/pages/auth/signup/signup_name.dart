import 'package:akababi/bloc/cubit/signup_cubit.dart';
import 'package:akababi/pages/auth/components/common_button.dart';
import 'package:akababi/pages/auth/components/common_text_field.dart';
import 'package:akababi/pages/auth/signup/signup_birthdate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpNamePage extends StatefulWidget {
  @override
  State<SignUpNamePage> createState() => _SignUpNamePageState();
}

class _SignUpNamePageState extends State<SignUpNamePage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  bool active = false;
  void _onChanged(String value) {
    if (firstNameController.text.length > 2 &&
        lastNameController.text.length > 2) {
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
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "What's Your name?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Enter the name you use in real life.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              'First and last name have to be more than 2 character.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),
            CommonTextField(
              onChanged: _onChanged,
              labelText: 'First Name',
              controller: firstNameController,
            ),
            SizedBox(height: 20),
            CommonTextField(
              onChanged: _onChanged,
              labelText: 'Last Name',
              controller: lastNameController,
            ),
            SizedBox(height: 30),
            CommonButton(
              active: active,
              buttonText: 'Next',
              onPressed: () {
                // Handle next action
                BlocProvider.of<SignupCubit>(context).getData({
                  'firstName': firstNameController.text,
                  'lastName': lastNameController.text,
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BirthDatePage(),
                  ),
                );
              },
            ),
            Spacer(),
            TextButton(
              onPressed: () {
                // Handle already have an account action
                Navigator.pop(context);
              },
              child: const Center(
                child: Text(
                  'I already have an account',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:akababi/bloc/cubit/signup_cubit.dart';
import 'package:akababi/pages/auth/components/common_button.dart';
import 'package:akababi/pages/auth/signup/signup_email.dart';
import 'package:akababi/pages/auth/signup/signup_number.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GenderSelectionPage extends StatefulWidget {
  @override
  _GenderSelectionPageState createState() => _GenderSelectionPageState();
}

class _GenderSelectionPageState extends State<GenderSelectionPage> {
  String? _selectedGender;

  bool active = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "What's Your Gender?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "You can change who sees your gender on profile later",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: Text("Female"),
                    value: "female",
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                        active = true;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text("Male"),
                    value: "male",
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                        active = true;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            CommonButton(
              active: active,
              buttonText: "Next",
              onPressed: () {
                // Handle the next button click
                BlocProvider.of<SignupCubit>(context).getData({
                  'gender': _selectedGender ?? 'male',
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignUpEmailPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

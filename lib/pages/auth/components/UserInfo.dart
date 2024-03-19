import 'package:akababi/bloc/auth/auth_bloc.dart';
import 'package:akababi/bloc/auth/auth_event.dart';
import 'package:akababi/component/Button.dart';
import 'package:akababi/component/TextInput.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum Gender { male, female }

class UserInfo extends StatefulWidget {
  final TextEditingController lnController;
  final TextEditingController fnController;
  final TextEditingController birthController;
  final void Function() fun;
  const UserInfo(
      {super.key,
      required this.fnController,
      required this.lnController,
      required this.birthController,
      required this.fun});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  String genderValue = 'male';

  Gender? _gender = Gender.female;

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
            Text(
              "Enter relevant Information",
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.black.withOpacity(0.5),
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            TextInput(
                controller: widget.fnController,
                hint: "First name ",
                isPass: false),
            SizedBox(
              height: 20,
            ),
            TextInput(
                controller: widget.lnController,
                hint: "Last Name ",
                isPass: false),
            SizedBox(
              height: 20,
            ),
            TextInput(
                controller: widget.birthController,
                hint: "Enter birth date dd/mm/yyyy",
                isPass: false),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 200,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "male: ",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                  ),
                  Radio<Gender>(
                    value: Gender.male,
                    groupValue: _gender,
                    onChanged: (Gender? value) {
                      setState(() {
                        _gender = value;
                        genderValue = 'male';
                      });
                    },
                  ),
                  Text("female: ",
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                  Radio<Gender>(
                    value: Gender.female,
                    groupValue: _gender,
                    onChanged: (Gender? value) {
                      setState(() {
                        _gender = value;
                        genderValue = 'female';
                      });
                    },
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(),
                Button(func: widget.fun, text: "Next"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

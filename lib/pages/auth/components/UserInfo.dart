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
            const SizedBox(
              height: 200,
            ),
            Text(
              "Enter relevant Information",
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.black.withOpacity(0.5),
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            TextInput(
                controller: widget.fnController,
                hint: "First name ",
                isPass: false),
            const SizedBox(
              height: 20,
            ),
            TextInput(
                controller: widget.lnController,
                hint: "Last Name ",
                isPass: false),
            const SizedBox(
              height: 20,
            ),
            TextField(
              onTap: () {
                _selectDate();
              },
              readOnly: true,
              controller: widget.birthController,
              decoration: const InputDecoration(
                  labelText: 'BIRTH DATE',
                  filled: true,
                  prefixIcon: Icon(Icons.calendar_today),
                  enabledBorder:
                      OutlineInputBorder(borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue))),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 200,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
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
                  const Text("female: ",
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

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (picked != null) {
      setState(() {
        widget.birthController.text = picked.toString().split(" ")[0];
      });
    }
  }
}

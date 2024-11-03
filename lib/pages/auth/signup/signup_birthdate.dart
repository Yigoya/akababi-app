import 'package:akababi/bloc/cubit/signup_cubit.dart';
import 'package:akababi/pages/auth/components/common_button.dart';
import 'package:akababi/pages/auth/signup/signup_gender.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';

class BirthDatePage extends StatefulWidget {
  const BirthDatePage({super.key});

  @override
  _BirthDatePageState createState() => _BirthDatePageState();
}

class _BirthDatePageState extends State<BirthDatePage> {
  DateTime selectedDate = DateTime.now();

  bool active = false;
  void _onChanged(DateTime value) {
    if (selectedDate.year != 12) {
      setState(() {
        active = true;
      });
    }
  }

  // Future<void> _selectDate(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: selectedDate,
  //     firstDate: DateTime(1900),
  //     lastDate: DateTime.now(),
  //   );
  //   if (picked != null && picked != selectedDate) {
  //     setState(() {
  //       selectedDate = picked;
  //     });
  //     if (DateTime.now().year - selectedDate.year >= 12) {
  //       setState(() {
  //         active = true;
  //       });
  //     } else {
  //       setState(() {
  //         active = false;
  //       });
  //     }
  //   }
  // }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await DatePicker.showSimpleDatePicker(
      context,
      // initialDate: DateTime(2020),
      firstDate: DateTime(1900),
      lastDate: DateTime(2090),
      dateFormat: "dd-MMMM-yyyy",
      locale: DateTimePickerLocale.en_us,
      looping: true,
    );
    // final DateTime? picked = await showDatePicker(
    //   context: context,
    //   initialDate: selectedDate,
    //   firstDate: DateTime(1900),
    //   lastDate: DateTime.now(),
    // );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      if (DateTime.now().year - selectedDate.year >= 12) {
        setState(() {
          active = true;
        });
      } else {
        setState(() {
          active = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "What's Your Date of Birth?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text:
                        "Choose your date of birth. You can always make this private later. ",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const TextSpan(
                    text: "minimum age is 12 years.",
                    style: TextStyle(color: Colors.red),
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      DateTime.now().year - selectedDate.year < 12
                          ? "Select Date of Birth"
                          : "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                      style: const TextStyle(fontSize: 17),
                    ),
                    const Icon(Icons.calendar_today, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            CommonButton(
              active: active,
              buttonText: "Next",
              onPressed: () {
                // Handle next action
                BlocProvider.of<SignupCubit>(context).getData({
                  'birthDate': selectedDate.toString().split(" ")[0],
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GenderSelectionPage(),
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

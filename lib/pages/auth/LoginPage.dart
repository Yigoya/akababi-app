import 'dart:math';

import 'package:akababi/pages/auth/components/common_text_field.dart';
import 'package:akababi/pages/auth/signup/signup_name.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:akababi/utility.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool active = false;
  void _onChanged(String value) {
    if (passwordController.text.length > 6) {
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
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 140,
              ),
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.grey[500],
                ),
              ),
              SizedBox(height: 120),
              CommonTextField(
                onChanged: _onChanged,
                controller: emailController,
                labelText: "Email address or Mobile number",
              ),
              SizedBox(height: 20),
              CommonTextField(
                onChanged: _onChanged,
                controller: passwordController,
                labelText: "Password",
                obscureText: true,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // Handle login action
                  logIn();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: active ? Colors.red : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  'Log In',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  // Handle forgotten password action
                },
                child: Text(
                  'Forgotten Password?',
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ),
              Spacer(),
              OutlinedButton(
                onPressed: () {
                  // Handle create new account action
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SignUpNamePage()));
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  'Create new Account',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> logIn() async {
    print("login");
    final authRepo = AuthRepo();
    try {
      final response = await authRepo.login(
          email: emailController.text, password: passwordController.text);
      await authRepo.setToken(response['token']);
      await authRepo.setUser(response['user']);
      print(await authRepo.token);

      trigerNotification('Login Success', 'The process of Login is sucessfull');
      await requestLocationPermission();
      Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
    } catch (e) {
      if (e is DioException) {
        String error = handleDioError(e);
        print('$error this is error');
      }
    }
  }
}

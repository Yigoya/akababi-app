import 'dart:math';

import 'package:akababi/component/GoogleLogin.dart';
import 'package:akababi/pages/auth/DeactivatedPage.dart';
import 'package:akababi/pages/auth/components/common_text_field.dart';
import 'package:akababi/pages/auth/signup/signup_name.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:akababi/utility.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool active = false;
  bool isLeading = false;
  String error = '';
  void _onChanged(String value) {
    if (passwordController.text.length >= 6) {
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
              const SizedBox(
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
              const SizedBox(height: 80),
              error.isNotEmpty
                  ? Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            error,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
              const SizedBox(height: 20),
              CommonTextField(
                onChanged: _onChanged,
                controller: emailController,
                labelText: "Email address or Mobile number",
              ),
              const SizedBox(height: 20),
              CommonTextField(
                onChanged: _onChanged,
                controller: passwordController,
                labelText: "Password",
                obscureText: true,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (isValidEmail(emailController.text) && active) {
                    logIn();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isValidEmail(emailController.text) && active
                      ? Colors.red
                      : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: isLeading
                    ? const CircularProgressIndicator()
                    : Text(
                        'Log In',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  // Handle forgotten password action
                  Navigator.pushNamed(context, '/forgetpassword');
                },
                child: const Text(
                  'Forgotten Password?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
              ),
              const Spacer(),
              // GoogleLogin(
              //     func: () => signIn(context), text: 'Sign in with Google'),
              // const SizedBox(
              //   height: 12,
              // ),
              OutlinedButton(
                onPressed: () {
                  // Handle create new account action
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignUpNamePage()));
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  'Create new Account',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  Future<void> logIn() async {
    print("login");
    final authRepo = AuthRepo();
    setState(() {
      isLeading = true;
    });
    try {
      final response = await authRepo.login(
          email: emailController.text.trim(),
          password: passwordController.text);
      await authRepo.setToken(response['token']);
      await authRepo.setUser(response['user']);
      print(await authRepo.token);

      trigerNotification('Login Success', 'The process of Login is sucessfull');
      await requestLocationPermission();
      Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
    } catch (e) {
      if (e is DioException) {
        String error = handleDioError(e);
        setState(() {
          this.error = error;
        });
        print('$error this is error');
      }
    }

    setState(() {
      isLeading = false;
    });
  }

  Future<void> signIn(BuildContext context) async {
    final logger = Logger();
    logger.d("Google Sign-In Started");

    // Initialize repositories and shared preferences
    final AuthRepo authRepo = AuthRepo();
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      // Attempt Google Sign-In
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser != null) {
        // Store Google ID in shared preferences
        await prefs.setString('googleId', googleUser.id);

        // Sign in with the backend using Google details
        final user = await authRepo.signinWithGoogle(
          googleUser.id,
          googleUser.email,
          googleUser.displayName ?? 'No Name',
          googleUser.photoUrl,
        );

        logger.d(user);

        if (user != null) {
          // Handle user status
          switch (user.status) {
            case 'deactivated':
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const DeactivatedPage()),
              );
              break;
            case 'deleted':
              _showSnackBar(context, 'User deleted');
              break;
            default:
              await authRepo.setUser(user);
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          }
        } else {
          _showSnackBar(context, 'User not found');
        }
      } else {
        logger.d('Google Sign-In failed');
      }
    } catch (err) {
      _handleSignInError(context, err);
    }
  }

// Utility function to handle errors
  void _handleSignInError(BuildContext context, dynamic err) {
    if (err is DioException) {
      String error = handleDioError(err);
      print(error);
      _showSnackBar(
          context, 'Email account already exists, signed in with email');
    } else {
      print('Error: $err');
    }
  }

// Utility function to show snack bars
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

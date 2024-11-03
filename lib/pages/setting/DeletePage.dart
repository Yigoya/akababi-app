import 'package:akababi/component/GoogleLogin.dart';
import 'package:akababi/pages/profile/cubit/profile_cubit.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  _DeleteAccountPageState createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  String? selectedReason;
  String? googleId;
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initFunction();
  }

  void initFunction() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      googleId = prefs.getString('googleId');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.grey[200],
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Are you sure you want to delete your account?',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Deleting your account is a permanent action and cannot be undone. This will result in the loss of all your data, including your profile information, posts, messages, and any other content associated with your account. If you are sure you want to proceed, please confirm by typing your password and clicking on the \'Delete Account\' button below.',
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Give us the reason why are you deleting account',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...[
                'Privacy Concerns: Users may worry about how their data is being used or shared.',
                'Security Issues: Concerns about account security or past security breaches.',
                'Lack of Use: The platform is no longer useful or relevant to them.',
                'Unwanted Notifications: Receiving too many emails or notifications.',
                'Too Time-Consuming: Finding the platform too distracting or a waste of time.',
                'Better Alternatives: Finding a better or more suitable platform.',
                'Poor User Experience: Difficulty navigating the platform or dissatisfaction with its features.',
                'Change in Interests: No longer interested in the services or content the platform offers.',
              ].map((reason) => RadioListTile<String>(
                    title: Text(reason),
                    value: reason,
                    groupValue: selectedReason,
                    onChanged: (String? value) {
                      setState(() {
                        selectedReason = value;
                      });
                    },
                  )),
              const SizedBox(height: 20),
              googleId != null
                  ? GoogleLogin(
                      func: () => signIn(context), text: "verify your Email")
                  : Column(
                      children: [
                        const Text(
                          'Confirm by Password',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Enter Password',
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              final res =
                                  await BlocProvider.of<ProfileCubit>(context)
                                      .deleteUser(passwordController.text);
                              if (res) {
                                BlocProvider.of<ProfileCubit>(context)
                                    .logOut(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            child: const Text('Confirm'),
                          ),
                        ),
                      ],
                    )
            ],
          ),
        ),
      ),
    );
  }

  Future signIn(BuildContext context) async {
    AuthRepo authRepo = AuthRepo();
    await GoogleSignIn().signOut();
    GoogleSignInAccount? googleSignIn = await GoogleSignIn().signIn();

    if (googleSignIn != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var googleId = prefs.getString('googleId');
      if (googleSignIn.id == googleId) {
        final res =
            await BlocProvider.of<ProfileCubit>(context).deleteUser(googleId!);
        if (res) {
          BlocProvider.of<ProfileCubit>(context).logOut(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Email not verified'),
          ));
        }
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        //   content: Text('Email Verified'),
        // ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Email not verified'),
        ));
      }
    }
  }
}

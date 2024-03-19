import 'package:akababi/bloc/auth/auth_bloc.dart';
import 'package:akababi/bloc/auth/auth_event.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:flutter/material.dart';
import 'package:akababi/component/Header.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> checkExist() async {
    final authRepo = AuthRepo();
    final user = await authRepo.user;
    if (user == null) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  void initState() {
    super.initState();
    checkExist();
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context)
      ..add(LoadUserInfoEvent(context));
    return Scaffold(
        appBar: AppHeader(context),
        body: Center(
          child: Text("Welcome",
              style: TextStyle(color: Colors.deepOrange, fontSize: 30)),
        ));
  }
}

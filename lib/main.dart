import 'package:akababi/bloc/auth/auth_bloc.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:akababi/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

String initialRoute = '/login';

Future<void> checkExist() async {
  final authRepo = AuthRepo();
  final user = await authRepo.user;
  if (user != null) {
    initialRoute = '/';
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await checkExist();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
        ],
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          onGenerateRoute: generateRoute,
          initialRoute: initialRoute,
        ));
  }
}

// class MyPage extends StatefulWidget {
//   const MyPage({super.key, required this.title});

//   final String title;

//   @override
//   State<MyPage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyPage> {


//   @override
//   Widget build(BuildContext context) {
//     if
//   }
// }

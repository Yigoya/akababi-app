import 'package:flutter/material.dart';

PreferredSizeWidget? AppHeader(BuildContext context) {
  return AppBar(
    title: Text("title"),
    actions: [
      IconButton(
          onPressed: () {
            Navigator.pushNamed(context, "/profile");
          },
          icon: Icon(Icons.person))
    ],
  );
}

// class AppHeader extends StatelessWidget {
//   const AppHeader({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//     title: Text("title"),
//     actions: [IconButton(onPressed: () {
//       Navigator.pushNamed(context, "/profile");
//     }, icon: Icon(Icons.person))],
//   );;
//   }
// }
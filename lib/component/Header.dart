import 'package:akababi/pages/search/SearchPage.dart';
import 'package:flutter/material.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";

PreferredSizeWidget? AppHeader(BuildContext context, String title) {
  return AppBar(
    title: Text(title),
    actions: [
      IconButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => const SearchPage()));
          },
          icon: const Icon(FeatherIcons.search)),
      IconButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true)
                .pushNamed("/notification");
          },
          icon: const Icon(FeatherIcons.bell)),
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
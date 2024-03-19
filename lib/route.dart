import 'package:akababi/pages/auth/ForgetPassword.dart';
import 'package:akababi/pages/auth/LoginPage.dart';
import 'package:akababi/pages/auth/Policy.dart';
import 'package:akababi/pages/auth/SignupPage.dart';
import 'package:akababi/pages/error/ErrorPage.dart';
import 'package:akababi/pages/home/HomePage.dart';
import 'package:akababi/pages/profile/ProfilePage.dart';
import 'package:akababi/utility.dart';
import 'package:flutter/material.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(settings: settings, builder: (_) => HomePage());
    case '/login':
      return MaterialPageRoute(settings: settings, builder: (_) => LoginPage());
    case '/forgetpassword':
      return MaterialPageRoute(
          settings: settings, builder: (_) => ForgetPassword());
    case '/policy':
      return MaterialPageRoute(settings: settings, builder: (_) => Policy());
    case '/profile':
      return MaterialPageRoute(
          settings: settings, builder: (_) => ProfilePage());
    case '/signup':
      return MaterialPageRoute(
          settings: settings, builder: (_) => SignupPage());
    case '/error':
      final data = settings.arguments;
      return MaterialPageRoute(
          settings: settings, builder: (_) => ErrorPage(data: data));
    default:
      final arg = {
        "type": ErrorType.noconnect,
        "msg": "the page doesn't exist"
      };
      return MaterialPageRoute(
          settings: settings, builder: (_) => ErrorPage(data: arg));
  }
}

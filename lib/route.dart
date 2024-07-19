import 'package:akababi/main.dart';
import 'package:akababi/pages/auth/ForgetPassword.dart';
import 'package:akababi/pages/auth/LoginPage.dart';
import 'package:akababi/pages/auth/Policy.dart';
import 'package:akababi/pages/auth/SignupPage.dart';
import 'package:akababi/pages/error/ErrorPage.dart';
import 'package:akababi/pages/notification/NotificationPage.dart';
import 'package:akababi/pages/post/SinglePostPage.dart';
import 'package:akababi/pages/profile/ProfilePage.dart';
import 'package:akababi/pages/profile/UserProfile.dart';
import 'package:akababi/pages/setting/SettingPage.dart';
import 'package:akababi/utility.dart';
import 'package:flutter/material.dart';

/// Generates the appropriate route based on the provided [settings].
///
/// The [settings] parameter contains information about the requested route,
/// such as the route name and any arguments passed to it.
///
/// Returns a [MaterialPageRoute] that corresponds to the requested route.
/// If the requested route is not found, a default error page is returned.
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(
          settings: settings, builder: (_) => const HomePage());
    case '/login':
      return MaterialPageRoute(settings: settings, builder: (_) => LoginPage());
    case '/forgetpassword':
      return MaterialPageRoute(
          settings: settings, builder: (_) => const ForgetPassword());
    case '/policy':
      return MaterialPageRoute(settings: settings, builder: (_) => Policy());
    case '/notification':
      return MaterialPageRoute(
          settings: settings, builder: (_) => const NotificationPage());
    case '/profile':
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const ProfilePage(),
      );
    case '/signup':
      return MaterialPageRoute(
          settings: settings, builder: (_) => const SignupPage());
    case '/setting':
      return MaterialPageRoute(
          settings: settings, builder: (_) => const SettingPage());
    case '/singlePost':
      final id = settings.arguments as int;
      return MaterialPageRoute(
          settings: settings, builder: (_) => SinglePostPage(id: id));
    case '/userProfile':
      final id = settings.arguments as int;
      return MaterialPageRoute(
          settings: settings, builder: (_) => UserProfile(id: id));
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

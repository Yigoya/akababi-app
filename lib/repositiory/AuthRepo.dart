import 'dart:convert';

import 'package:akababi/model/User.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepo {
  final dio = Dio();
  // static String SERVER = 'http://192.168.12.1:3001';
  static String SERVER = 'https://api1.myakababi.com';

  Future<User?> get user async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('user') ?? '';
    if (value == '') return null;
    return User.fromMap(jsonDecode(value));
  }

  Future<void> setUser(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toMap()));
  }

  Future<void> removeUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
  }

  Future<void> setToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<String?> get token async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, dynamic>> login(String? email, String password) async {
    var data = {
      'email': email,
      'password': password,
    };
    final res = await dio.post(SERVER + "/user/login", data: data);

    print(res);

    return {'user': User.fromMap(res.data['user']), 'token': res.data['token']};
  }

  Future<User?> signinWithGoogle(
      String id, String email, String fullname, String? imagePath) async {
    try {
      var first_name = fullname.split(' ')[0];
      var last_name = fullname.split(' ')[1];
      var data = {
        'id': id,
        'email': email,
        'first_name': first_name,
        'last_name': last_name,
      };
      final res = await dio.post(SERVER + "/user/signinWithGoogle", data: data);

      print(res.data['user']);

      return User.fromMap(res.data['user']);
    } catch (err) {
      print('Error $err');
      return null;
    }
  }

  // Future<Map<String, dynamic>> getProfile(String email, String password) async {
  //   User? usr = await user;
  //   final res = await dio.get(SERVER + "/user/profile/${usr!.id}", data: data);

  //   print(res);

  //   return {'user': User.fromMap(res.data['user']), 'token': res.data['token']};
  // }

  Future<Map<String, dynamic>> newPassword(
      String email, String password) async {
    var data = {
      'email': email,
      'password': password,
    };
    final res = await dio.post(SERVER + "/user/newPassword", data: data);

    print(res);

    return {'user': User.fromMap(res.data['user']), 'token': res.data['token']};
  }

  Future<Map<String, dynamic>> emailVarify(String email) async {
    var data = {
      'email': email,
    };
    print(data);
    final res = await dio.post(SERVER + "/user/SendEmail", data: data);

    print(res.data);

    return res.data;
  }

  Future<Map<String, dynamic>> frogetPassEmailVarify(String email) async {
    var data = {
      'email': email,
    };
    final res =
        await dio.post(SERVER + "/user/sendEmailPasswordForget", data: data);

    print(res);

    return res.data;
  }

  Future<Map<String, dynamic>> codeVarify(String? email, String code) async {
    var data = {
      'email': email,
      'otp': code,
    };
    final res = await dio.post(SERVER + "/user/VerifyCode", data: data);

    print(res);

    return res.data;
  }

  Future<Map<String, dynamic>> signup(
      String username,
      String email,
      String gender,
      String password,
      String first_name,
      String last_name,
      String date_of_birth) async {
    var data = {
      'first_name': first_name,
      'last_name': last_name,
      'date_of_birth': date_of_birth,
      'gender': gender,
      'username': username,
      'email': email,
      'password': password,
    };
    final res = await dio.post(SERVER + "/user/Signup", data: data);

    print({'user': User.fromMap(res.data['user']), 'token': res.data['token']});

    return {'user': User.fromMap(res.data['user']), 'token': res.data['token']};
  }
}

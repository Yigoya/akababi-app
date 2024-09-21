import 'dart:convert';

import 'package:akababi/model/User.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepo {
  final dio = Dio();
  static bool isServer = false;
  User? auser;
  static String SERVER = 'http://192.168.45.17:3000';
  // static String SERVER = 'https://api1.myakababi.com';

  /// Retrieves the user from SharedPreferences.
  /// Returns the user object if it exists, otherwise returns null.
  Future<User?> get user async {
    if (auser != null) return auser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('user') ?? '';
    if (value == '') return null;
    auser = User.fromMap(jsonDecode(value));
    return User.fromMap(jsonDecode(value));
  }

  /// Sets the user in the shared preferences.
  ///
  /// This method takes a [User] object and stores it in the shared preferences
  /// as a JSON-encoded string. The user can later be retrieved using the
  /// `getUser` method.
  ///
  /// Parameters:
  /// - `user`: The user object to be stored.
  ///
  /// Returns:
  /// A [Future] that completes when the user is successfully stored.
  ///
  /// Throws:
  /// - [Exception] if there is an error while storing the user.
  ///
  /// Example usage:
  /// ```dart
  /// User user = User(name: 'John Doe', age: 25);
  /// await setUser(user);
  /// ```
  Future<void> setUser(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    auser = user;
    await prefs.setString('user', jsonEncode(user.toMap()));
  }

  /// Removes the user from the shared preferences.
  ///
  /// This method removes the 'user' key from the shared preferences, effectively
  /// removing the user data from the device.
  ///
  /// Example usage:
  /// ```dart
  /// await removeUser();
  /// ```
  Future<void> removeUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
  }

  /// Sets the authentication token in the shared preferences.
  ///
  /// This method takes in a [token] and stores it in the shared preferences
  /// with the key 'token'.
  ///
  /// Example usage:
  /// ```dart
  /// await AuthRepo().setToken('your_token_here');
  /// ```
  Future<void> setToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  /// Retrieves the token from the shared preferences.
  ///
  /// Returns the token as a [String] if it exists, otherwise returns null.
  Future<String?> get token async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Logs in the user with the provided email and password.
  ///
  /// Returns a map containing the user information and authentication token.
  /// Throws an exception if the login request fails.
  Future<Map<String, dynamic>> login(String? email, String password) async {
    var data = {
      'email': email!.trim(),
      'password': password,
    };

    final res = await dio.post("$SERVER/user/login", data: data);

    print(res.data);

    return {'user': User.fromMap(res.data['user']), 'token': res.data['token']};
  }

  /// Signs in a user using Google authentication.
  ///
  /// This method takes in the user's Google ID, email, full name, and an optional image path.
  /// It splits the full name into first name and last name, and sends the user data to the server
  /// for authentication. The server response is then used to create a [User] object, which is returned.
  ///
  /// Returns a [User] object if the sign-in is successful, otherwise returns null.
  Future<User?> signinWithGoogle(
      String id, String email, String fullname, String? imagePath) async {
    var firstName = fullname.split(' ')[0];
    var lastName = fullname.split(' ')[1];
    var data = {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
    };
    final res = await dio.post("$SERVER/user/signinWithGoogle", data: data);

    print(res.data['user']);

    return User.fromMap(res.data['user']);
  }

  /// Deletes the user account with the provided password.
  ///
  /// Returns `true` if the user account is successfully deleted, otherwise `false`.
  /// Throws an error if an exception occurs during the deletion process.
  Future<bool> deleteUser(String password) async {
    User? usr = await user;
    var data = {
      'email': usr!.email,
      'password': password,
    };

    try {
      final res = await dio.post("$SERVER/user/delete", data: data);

      print(res);

      return true;
    } catch (err) {
      print('Error $err');
      return false;
    }
  }

  /// Deactivates the user account with the provided password.
  ///
  /// Returns `true` if the deactivation is successful, otherwise `false`.
  Future<bool> deactivateUser(String password) async {
    User? usr = await user;
    var data = {
      'email': usr!.email,
      'password': password,
    };
    try {
      final res = await dio.post("$SERVER/user/deactivate", data: data);

      print(res);

      return true;
    } catch (err) {
      print('Error $err');
      return false;
    }
  }

  /// Reactivates a user with the given data.
  ///
  /// Returns `true` if the user reactivation is successful, otherwise `false`.
  /// Throws an error if an exception occurs during the reactivation process.
  Future<bool> reactivateUser(Map<String, dynamic> data) async {
    try {
      final res = await dio.post("$SERVER/user/reactivate", data: data);

      print(res);

      return true;
    } catch (err) {
      print('Error $err');
      return false;
    }
  }

  /// Sends a request to reset the user's password with the provided email, code, and new password.
  /// Returns a map containing the user and token information.
  Future<Map<String, dynamic>> newPassword(
      String email, String code, String password) async {
    var data = {
      'email': email,
      'otp': code,
      'password': password,
    };
    final res = await dio.post("$SERVER/user/newPassword", data: data);

    print(res);

    return {'user': User.fromMap(res.data['user']), 'token': res.data['token']};
  }

  /// Sends a verification email to the provided email address.
  /// Returns a map containing the response data.
  Future<Map<String, dynamic>> emailVarify(String email) async {
    var data = {
      'email': email,
    };
    print(data);
    final res = await dio.post("$SERVER/user/sendEmailForSignUp", data: data);

    print(res.data);

    return res.data;
  }

  /// Sends a verification email for password reset to the specified [email].
  /// Returns a [Future] that completes with a [Map] containing the response data.
  Future<Map<String, dynamic>> frogetPassEmailVarify(String email) async {
    var data = {
      'email': email,
    };
    final res =
        await dio.post("$SERVER/user/sendEmailPasswordForget", data: data);

    print(res);

    return res.data;
  }

  /// Verifies the provided code for the given email.
  ///
  /// Returns a [Future] that completes with a [Map] containing the response data.
  /// The [email] parameter is the email address to verify.
  /// The [code] parameter is the code to be verified.
  Future<Map<String, dynamic>> codeVarify(String? email, String code) async {
    var data = {
      'email': email,
      'otp': code,
    };
    final res = await dio.post("$SERVER/user/VerifyCode", data: data);

    print(res);

    return res.data;
  }

  /// Signs up a user with the provided information.
  ///
  /// The [username], [email], [gender], [password], [firstName], [lastName], and [dateOfBirth]
  /// parameters are required to create a new user account.
  ///
  /// Returns a [Future] that completes with a [Map] containing the user information and token.
  /// The user information is represented by a [User] object, and the token is a string.
  Future<Map<String, dynamic>> signup(
      String username,
      String email,
      String gender,
      String password,
      String firstName,
      String lastName,
      String dateOfBirth) async {
    var data = {
      'first_name': firstName,
      'last_name': lastName,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'username': username,
      'email': email.trim(),
      'password': password,
    };
    final res = await dio.post("$SERVER/user/Signup", data: data);

    print({'user': User.fromMap(res.data['user']), 'token': res.data['token']});

    return {'user': User.fromMap(res.data['user']), 'token': res.data['token']};
  }

  /// Sets the location of the user.
  ///
  /// The [latitude] and [longitude] parameters represent the coordinates of the user's location.
  /// Returns a [Future] that completes with a [bool] value indicating whether the location was set successfully.
  /// If the location is set successfully, the method returns `true`. Otherwise, it returns `false`.
  /// Throws an exception if an error occurs during the process.
  Future<bool> setLocation(double? latitude, double? longitude) async {
    try {
      final user = await this.user;
      var data = {"id": user!.id, "latitude": latitude, "longitude": longitude};
      final res = await dio.post("$SERVER/user/setLocation", data: data);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}

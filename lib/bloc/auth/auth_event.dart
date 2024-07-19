import 'package:flutter/material.dart';

class AuthEvent {}

class InitialEvent extends AuthEvent {}

class SignUpEvent extends AuthEvent {
  BuildContext context;
  String username;
  String fname;
  String lname;
  String email;
  String phone;
  String password;
  String confirm;
  String gender;
  String birthdate;

  SignUpEvent(this.username, this.fname, this.lname, this.email, this.phone,
      this.password, this.confirm, this.gender, this.birthdate, this.context);
}

class LoginEvent extends AuthEvent {
  BuildContext context;
  String email;
  String password;
  LoginEvent(this.email, this.password, this.context);
}

class NewPasswordEvent extends AuthEvent {
  BuildContext context;
  String email;
  String code;
  String password;
  String confirm;
  NewPasswordEvent(
      this.email, this.code, this.password, this.confirm, this.context);
}

class EmailVarifyEvent extends AuthEvent {
  String email;
  BuildContext context;
  EmailVarifyEvent(this.email, this.context);
}

class ForgetPassEmailVarifyEvent extends AuthEvent {
  String email;
  BuildContext context;
  ForgetPassEmailVarifyEvent(this.email, this.context);
}

class CodeVarifyEvent extends AuthEvent {
  String code;
  String email;
  BuildContext context;
  CodeVarifyEvent(this.code, this.email, this.context);
}

class GetUserInfoEvent extends AuthEvent {
  GetUserInfoEvent();
}

class BackEvent extends AuthEvent {
  BackEvent();
}

class GetLocationEvent extends AuthEvent {
  bool? off;
  BuildContext context;
  GetLocationEvent({required this.context, bool? off, bool? isToggle}) {
    this.off = off;
  }
}

class LoadUserInfoEvent extends AuthEvent {
  BuildContext context;
  LoadUserInfoEvent(this.context);
}

class ProfileEvent extends AuthEvent {
  BuildContext context;
  ProfileEvent(this.context);
}

class LogOutEvent extends AuthEvent {
  BuildContext context;
  LogOutEvent(this.context);
}

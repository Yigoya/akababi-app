import 'package:akababi/model/User.dart';
import 'package:akababi/repositiory/AuthRepo.dart';

final authRepo = AuthRepo();

class AuthState {
  String? token;
  User? user;
  String? error;
  bool? isLoading;
  AuthState({this.token, this.user, this.error, this.isLoading = false});
}

class InitialState extends AuthState {
  InitialState({String? error, String? token, User? user, bool? isLoading})
      : super(token: token, user: user, error: error, isLoading: isLoading);
}

class LoadingState extends AuthState {
  LoadingState();
}

class SignUpState extends AuthState {
  SignUpState(String token, User user) : super(token: token, user: user);
}

class LoginState extends AuthState {
  LoginState(String token, User user) : super(token: token, user: user);
}

class ChangeProfileState extends AuthState {
  ChangeProfileState(
      {String? error, String? token, User? user, bool? isLoading})
      : super(token: token, user: user, error: error, isLoading: isLoading);
}

class EmailVarifyState extends AuthState {
  EmailVarifyState({String? error, String? token, User? user, bool? isLoading})
      : super(token: token, user: user, error: error, isLoading: isLoading);
}

class CodeVarifyState extends AuthState {
  CodeVarifyState({String? error, String? token, User? user, bool? isLoading})
      : super(token: token, user: user, error: error, isLoading: isLoading);
}

class GetInfoState extends AuthState {
  GetInfoState({String? error, String? token, User? user, bool? isLoading})
      : super(token: token, user: user, error: error, isLoading: isLoading);
}

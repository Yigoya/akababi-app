import 'package:akababi/repositiory/UserRepo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:akababi/bloc/auth/auth_event.dart';
import 'package:akababi/bloc/auth/auth_state.dart';
import 'package:akababi/utility.dart';
import 'package:akababi/model/User.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  trigerNotification(String title, String body) {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: 10, channelKey: 'channelKey', title: title, body: body));
  }

  int _calculatePasswordStrength(String password) {
    int strength = 0;
    if (password.length >= 8) {
      strength++;
    }
    if (password.contains(RegExp(r'[a-z]'))) {
      strength++;
    }
    if (password.contains(RegExp(r'[A-Z]'))) {
      strength++;
    }
    if (password.contains(RegExp(r'[0-9]'))) {
      strength++;
    }
    if (password.contains(RegExp(r'[!@#$%^&*()]'))) {
      strength++;
    }
    return strength;
  }

  AuthRepo authRepo = AuthRepo();
  UserRepo userRepo = UserRepo();
  AuthBloc() : super(InitialState()) {
    on<InitialEvent>(_initial);
    on<SignUpEvent>(_signUp);
    on<LoginEvent>(_logIn);
    on<EmailVarifyEvent>(_emailVarify);
    on<ForgetPassEmailVarifyEvent>(_forgetPassEmailVarify);
    on<CodeVarifyEvent>(_codeVarify);
    on<GetUserInfoEvent>(_getInfo);
    on<BackEvent>(_backEvent);
    on<NewPasswordEvent>(_newPassword);
    on<ProfileEvent>(_profileChange);
    on<LoadUserInfoEvent>(_loadUserInfo);
    on<GetLocationEvent>(_getLocation);
  }

  Future<void> _initial(InitialEvent event, Emitter<AuthState> emit) async {
    emit(InitialState());
  }

  Future<void> _signUp(SignUpEvent event, Emitter<AuthState> emit) async {
    emit(GetInfoState(isLoading: true));
    if (event.password.isEmpty) {
      emit(GetInfoState(error: "passoword required"));
      return;
    }
    if ((event.password != event.confirm) || event.password.isEmpty) {
      print(event.password);
      print(event.confirm);
      emit(GetInfoState(error: "confirm passoword error"));
      return;
    }
    if (4 > _calculatePasswordStrength(event.password)) {
      emit(GetInfoState(error: "passoword is Week"));
      return;
    }
    try {
      final response = await authRepo.signup(
          event.username,
          event.email,
          event.gender,
          event.password,
          event.fname,
          event.lname,
          event.birthdate);
      await authRepo.setToken(response['token']);
      await authRepo.setUser(response['user']);
      print(await authRepo.token);

      emit(SignUpState(response['token'], response['user']));
      trigerNotification(
          'Registration Success', 'The process of Registration is sucessfull');
      await Navigator.pushNamedAndRemoveUntil(
          event.context, "/", (route) => false);
    } catch (e) {
      if (e is DioException) {
        String error = handleDioError(e);
        print(error);
        emit(GetInfoState(error: error));
        // final arg = {"type": ErrorType.noconnect, "msg": error};
        // Navigator.pushNamed(event.context, '/error', arguments: arg);
      }
    }
  }

  Future<void> _logIn(LoginEvent event, Emitter<AuthState> emit) async {
    emit(InitialState(isLoading: true));
    try {
      final response = await authRepo.login(event.email, event.password);
      await authRepo.setToken(response['token']);
      await authRepo.setUser(response['user']);
      print(await authRepo.token);

      emit(LoginState(response['token'], response['user']));
      trigerNotification('Login Success', 'The process of Login is sucessfull');
      await requestLocationPermission();
      Navigator.pushNamedAndRemoveUntil(event.context, "/", (route) => false);
    } catch (e) {
      if (e is DioException) {
        String error = handleDioError(e);
        print(error);
        emit(InitialState(error: error));
      }
    }
  }

  Future<void> _emailVarify(
      EmailVarifyEvent event, Emitter<AuthState> emit) async {
    emit(InitialState(isLoading: true));
    try {
      final response = await authRepo.emailVarify(event.email);

      print(await response);

      emit(EmailVarifyState());
    } catch (e) {
      if (e is DioException) {
        String error = handleDioError(e);
        print(error);
        // final arg = {"type": ErrorType.noconnect, "msg": error};
        // await Navigator.pushNamed(event.context, '/error', arguments: arg);
        emit(InitialState(error: error));
      }
    }
  }

  Future<void> _forgetPassEmailVarify(
      ForgetPassEmailVarifyEvent event, Emitter<AuthState> emit) async {
    emit(LoadingState());
    try {
      final response = await authRepo.frogetPassEmailVarify(event.email);

      print(await response);

      emit(EmailVarifyState());
    } catch (e) {
      if (e is DioException) {
        String error = handleDioError(e);
        print(error);
        final arg = {"type": ErrorType.noconnect, "msg": error};
        await Navigator.pushNamed(event.context, '/error', arguments: arg);
        emit(InitialState());
      }
    }
  }

  Future<void> _codeVarify(
      CodeVarifyEvent event, Emitter<AuthState> emit) async {
    emit((EmailVarifyState(isLoading: true)));
    try {
      final response = await authRepo.codeVarify(event.email, event.code);
      print(response);

      emit(CodeVarifyState());
    } catch (e) {
      if (e is DioException) {
        String error = handleDioError(e);
        print(error);
        emit(EmailVarifyState(error: error));
        // final arg = {"type": ErrorType.noconnect, "msg": error};
        // Navigator.pushNamed(event.context, '/error', arguments: arg);
      }
    }
  }

  Future<void> _getInfo(GetUserInfoEvent event, Emitter<AuthState> emit) async {
    emit(GetInfoState());
  }

  Future<void> _backEvent(BackEvent event, Emitter<AuthState> emit) async {
    emit(CodeVarifyState());
  }

  Future<void> _newPassword(
      NewPasswordEvent event, Emitter<AuthState> emit) async {
    if (event.password.isEmpty) {
      emit(CodeVarifyState(error: "passoword required"));
      return;
    }
    if ((event.password != event.confirm) || event.password.isEmpty) {
      print(event.password);
      print(event.confirm);
      emit(CodeVarifyState(error: "confirm passoword error"));
      return;
    }
    if (4 > _calculatePasswordStrength(event.password)) {
      print(_calculatePasswordStrength(event.password));
      emit(CodeVarifyState(error: "passoword is Week"));
      return;
    }
    try {
      final response = await authRepo.newPassword(event.email, event.password);
      await authRepo.setToken(response['token']);
      await authRepo.setUser(response['user']);
      print(await authRepo.token);

      emit(SignUpState(response['token'], response['user']));
      trigerNotification(
          'Login Success', 'Password reset process is sucessfull');
      Navigator.pushNamedAndRemoveUntil(event.context, "/", (route) => false);
    } catch (e) {
      if (e is DioException) {
        String error = handleDioError(e);
        print(error);
        final arg = {"type": ErrorType.noconnect, "msg": error};
        Navigator.pushNamed(event.context, '/error', arguments: arg);
      }
    }
  }

  Future<void> _profileChange(
      ProfileEvent event, Emitter<AuthState> emit) async {
    // emit(LoadingState());
    try {
      final response = await userRepo.uploadImageAndFile(state.user!.id);
      await authRepo.setUser(response!);
      print(response!.fullname);

      emit(ChangeProfileState(token: state.token!, user: response));
    } catch (e) {
      if (e is DioException) {
        String error = handleDioError(e);
        print(error);
        final arg = {"type": ErrorType.noconnect, "msg": error};
        Navigator.pushNamed(event.context, '/error', arguments: arg);
      }
    }
  }

  Future<void> _loadUserInfo(
      LoadUserInfoEvent event, Emitter<AuthState> emit) async {
    // emit(LoadingState());
    try {
      final token = await authRepo.token;
      final user = await authRepo.user;

      print(user!.fullname);

      emit(InitialState(token: token, user: user));
    } catch (e) {
      if (e is DioException) {
        String error = handleDioError(e);
        print(error);
        final arg = {"type": ErrorType.noconnect, "msg": error};
        Navigator.pushNamed(event.context, '/error', arguments: arg);
      }
    }
  }

  Future<void> _getLocation(
      GetLocationEvent event, Emitter<AuthState> emit) async {
    // emit(LoadingState());
    if (await requestLocationPermission()) {
      final location = await getCurrentLocation();
      print(location!.latitude);
    }
  }
}

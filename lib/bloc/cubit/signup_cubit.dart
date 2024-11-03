import 'package:akababi/model/Signup.dart';
import 'package:akababi/model/User.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  SignupCubit() : super(SignupInitial());
  final signup = Signup();
  final authRepo = AuthRepo();

  Future<bool> getData(Map<String, dynamic> map) async {
    if (map['email'] != null) {
      emit(SignupLoading());
      final res = await AuthRepo().emailVarify(map['email'] as String);
      if (res['status'] == 'error') {
        emit(SignupFailed(res['message']));
        return false;
      }
    }
    signup.getFromMap(map);
    emit(SignupData(signup));

    if (map['password'] != null && map['username'] != null) {
      final signRes = await signUp();
      if (!signRes) {
        return false;
      }
      emit(SignupData(signup));
    }
    return true;
  }

  Future<bool> verifyCode(String code) async {
    emit(SignupLoading());
    final res = await authRepo.codeVarify(signup.email, code);
    if (res['status'] == 'error') {
      emit(SignupFailed(res['message']));
      return false;
    } else {
      emit(SignupData(signup));
    }
    return true;
  }

  Future<void> resendCode() async {
    emit(SignupLoading());
    final res = await authRepo.emailVarify(signup.email);
    if (res['status'] == 'error') {
      emit(SignupFailed(res['message']));
    } else {
      emit(SignupData(signup));
    }
  }

  Future<bool> signUp() async {
    emit(SignupLoading());
    final res = await authRepo.signup(signup.toMap());
    if (res['status'] == 'error') {
      emit(SignupFailed(res['message']));
      return false;
    } else {
      await authRepo.setToken(res['token']);
      await authRepo.setUser(res['user']);
      return true;
    }
  }

  void clearData() {
    signup.clear();
    emit(SignupInitial());
  }
}

part of 'signup_cubit.dart';

sealed class SignupState extends Equatable {
  const SignupState();

  @override
  List<Object> get props => [];
}

final class SignupInitial extends SignupState {}

final class SignupLoading extends SignupState {}

final class SignupData extends SignupState {
  final Signup signup;

  SignupData(this.signup);

  @override
  List<Object> get props => [signup];
}

final class SignupSuccess extends SignupState {
  final User user;

  SignupSuccess(this.user);

  @override
  List<Object> get props => [user];
}

final class SignupFailed extends SignupState {
  final String message;

  SignupFailed(this.message);

  @override
  List<Object> get props => [message];
}

final class SignupTerms extends SignupState {}

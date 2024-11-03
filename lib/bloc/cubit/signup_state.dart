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

  const SignupData(this.signup);

  @override
  List<Object> get props => [signup];
}

final class SignupSuccess extends SignupState {
  final User user;

  const SignupSuccess(this.user);

  @override
  List<Object> get props => [user];
}

final class SignupFailed extends SignupState {
  final String message;

  const SignupFailed(this.message);

  @override
  List<Object> get props => [message];
}

final class SignupTerms extends SignupState {}

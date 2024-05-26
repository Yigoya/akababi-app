part of 'picture_cubit.dart';

@immutable
sealed class PictureState {}

final class PictureInitial extends PictureState {}

final class PictureLoading extends PictureState {}

final class PictureEmpty extends PictureState {
  String? imagePath;
  PictureEmpty({this.imagePath});
}

final class PictureLoaded extends PictureState {
  final String imagePath;

  PictureLoaded({required this.imagePath});
}

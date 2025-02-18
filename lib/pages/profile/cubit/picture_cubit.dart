import 'dart:io';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:akababi/repositiory/UserRepo.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:bloc/bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'picture_state.dart';

class PictureCubit extends Cubit<PictureState> {
  final userRepo = UserRepo();
  final authRepo = AuthRepo();
  final dio = Dio();
  PictureCubit() : super(PictureInitial());

  Future<void> getImage() async {
    // emit(PictureLoading());
    final pref = await SharedPreferences.getInstance();
    final imagePath = pref.getString('imagePath');
    final user = await authRepo.user;
    print(join(AuthRepo.SERVER, user!.profile_picture!));
    if (imagePath != null) {
      emit(PictureLoaded(imagePath: imagePath));
    } else if (user.profile_picture != null) {
      emit(PictureLoadedInternet(imageUrl: user.profile_picture!));
    } else {
      emit(PictureEmpty());
    }
  }

  Future<void> setImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final savedImage = await saveLocally(File(image.path));
      final pref = await SharedPreferences.getInstance();
      pref.setString('imagePath', savedImage.path);
      final user = await userRepo.setProfilePic(savedImage.path);
      if (user == null) return;
      await authRepo.setUser(user);
      emit(PictureLoaded(imagePath: savedImage.path));
    }
  }

  Future<File> saveLocally(File image) async {
    final dirc = await getApplicationDocumentsDirectory();
    final filename = basename(image.path);
    final savedImage = File(join(dirc.path, filename));
    await image.copy(savedImage.path);
    return savedImage;
  }
}

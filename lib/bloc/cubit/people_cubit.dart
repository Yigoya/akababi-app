import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:akababi/repositiory/PeopleRepo.dart';
import 'package:akababi/repositiory/UserRepo.dart';
import 'package:akababi/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

part 'people_state.dart';

class PeopleCubit extends Cubit<PeopleState> {
  PeopleCubit() : super(PeopleInitial());
  final peopleRepo = PeopleRepo();
  final authRepo = AuthRepo();
  final userRepo = UserRepo();
  final p = Logger();
  // void getPeopleSuggestions(BuildContext context) async {
  //   final user = await authRepo.user;
  //   final location = await getCurrentLocation(context);
  //   final data = {
  //     'userId': user!.id,
  //     'currentUserLat': location!.latitude,
  //     'currentUserLng': location.longitude
  //   };
  //   final res = await peopleRepo.getPeopleSuggestions(data);

  //   print(location.latitude);
  //   emit(PeopleLoaded(peoples: res));
  // }

  void getNearMe(BuildContext context) async {
    final location = await getCurrentLocation(context);
    final data = {
      'latitude': location!.latitude,
      'longitude': location.longitude
    };
    final res = await peopleRepo.getNearMe(data);
    final posts = res["posts"].cast<Map<String, dynamic>>().toList();
    final peoples = res["peoples"].cast<Map<String, dynamic>>().toList();
    emit(PeopleLoaded(peoples: peoples, posts: posts));
  }
}

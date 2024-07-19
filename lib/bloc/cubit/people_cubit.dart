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
  void getPeopleSuggestions(BuildContext context) async {
    final user = await authRepo.user;
    final location = await getCurrentLocation(context);
    final data = {
      'userId': user!.id,
      'currentUserLat': location!.latitude,
      'currentUserLng': location.longitude
    };
    final res = await peopleRepo.getPeopleSuggestions(data);

    print(location.latitude);
    emit(PeopleLoaded(peoples: res));
    }

  // void friendRequest(int userId) async {
  //   await peopleRepo.friendRequest(userId);
  //   // emit(PeopleLoaded(data:));
  // }

  // void friendRequestRespond(String response, Map<String, dynamic> data) async {
  //   await peopleRepo.friendRequestRespond(response, data);
  //   // emit(PeopleLoaded(data:));
  // }

  // void getPepoleById(int id) async {
  //   final posts = await userRepo.getUserPost(id);
  //   final friends = await userRepo.getUserFriend(id);
  //   p.d(posts);
  //   p.d(friends);
  //   if (state is PeopleLoaded) {
  //     final peoples = (state as PeopleLoaded).peoples;
  //     emit(PeopleLoading(peoples: peoples));
  //     final user = await authRepo.user;
  //     final people = await peopleRepo.getPeopleById(user!.id, id);
  //     emit(SinglePeopleLoaded(people, peoples, posts, friends));
  //   } else if (state is SinglePeopleLoaded) {
  //     final peoples = (state as SinglePeopleLoaded).peoples;
  //     final user = await authRepo.user;
  //     final people = await peopleRepo.getPeopleById(user!.id, id);
  //     emit(SinglePeopleLoaded(people, peoples, posts, friends));
  //   } else if (state is PeopleInitial) {
  //     final user = await authRepo.user;
  //     final people = await peopleRepo.getPeopleById(user!.id, id);
  //     emit(SinglePeopleLoaded(people, [], posts, friends));
  //   }
  // }

  // void blockUser(Map<String, dynamic> data) async {
  //   final user = await authRepo.user;
  //   data['user_id'] = user!.id;
  //   await peopleRepo.blockUser(data);
  // }
}

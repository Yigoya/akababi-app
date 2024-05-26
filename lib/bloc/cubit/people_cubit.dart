import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:akababi/repositiory/PeopleRepo.dart';
import 'package:akababi/utility.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'people_state.dart';

class PeopleCubit extends Cubit<PeopleState> {
  PeopleCubit() : super(PeopleInitial());
  final peopleRepo = PeopleRepo();
  final authRepo = AuthRepo();

  void printSomeThing() async {
    if (await requestLocationPermission()) {
      final user = await authRepo.user;
      final location = await getCurrentLocation();
      final data = {
        'userId': user!.id,
        'currentUserLat': location!.latitude,
        'currentUserLng': location.longitude
      };
      final res = await peopleRepo.getPeopleSuggestions(data);

      print(location.latitude);
      if (res != null) {
        emit(PeopleLoaded(peoples: res));
      }
    }
  }

  void friendRequest(int userId) async {
    await peopleRepo.friendRequest(userId);
    // emit(PeopleLoaded(data:));
  }

  void friendRequestRespond(String response, Map<String, dynamic> data) async {
    await peopleRepo.friendRequestRespond(response, data);
    // emit(PeopleLoaded(data:));
  }

  void getPepoleById(int id) async {
    if (state is PeopleLoaded) {
      final peoples = (state as PeopleLoaded).peoples;
      emit(PeopleLoading(peoples: peoples));
      final user = await authRepo.user;
      final people = await peopleRepo.getPeopleById(user!.id, id);
      emit(SinglePeopleLoaded(people, peoples));
    } else if (state is SinglePeopleLoaded) {
      final peoples = (state as SinglePeopleLoaded).peoples;
      final user = await authRepo.user;
      final people = await peopleRepo.getPeopleById(user!.id, id);
      emit(SinglePeopleLoaded(people, peoples));
    }
  }
}

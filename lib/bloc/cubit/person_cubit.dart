import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:akababi/repositiory/PeopleRepo.dart';
import 'package:akababi/repositiory/UserRepo.dart';
import 'package:akababi/utility.dart';
import 'package:bloc/bloc.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

part 'person_state.dart';

class PersonCubit extends Cubit<PersonState> {
  final peopleRepo = PeopleRepo();
  final authRepo = AuthRepo();
  final userRepo = UserRepo();
  final p = Logger();
  PersonCubit() : super(PersonInitial());

  Future<String> friendRequest(int userId) async {
    return await peopleRepo.friendRequest(userId);
  }

  Future<String> friendRequestRespond(
      {required int id, required String response}) async {
    return await peopleRepo.friendRequestRespond(id, response);
    // emit(PeopleLoaded(data:));
  }

  Future<Map<String, String>?> getPepoleById(int id) async {
    emit(PersonLoading());
    final posts = await userRepo.getUserPost(id);
    final friends = await userRepo.getUserFriend(id);
    final user = await authRepo.user;
    p.d(posts);
    p.d(friends);

    final people = await peopleRepo.getPeopleById(user!.id, id);
    emit(PersonLoaded(people, posts, friends));
    print('${people['latitude']}, ${people['longitude']}');
    return await getCityAndCountry(people['latitude'], people['longitude']);
  }

  Future<bool> blockUser(Map<String, dynamic> data) async {
    final user = await authRepo.user;
    data['user_id'] = user!.id;
    return await peopleRepo.blockUser(data);
  }

  Future<String> removeFriendRequest(int id) async {
    final user = await authRepo.user;
    final data = {'user_id': user!.id, 'friend_id': id};
    return await peopleRepo.removeFriendRequest(data);
  }
}

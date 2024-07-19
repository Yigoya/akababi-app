import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:akababi/repositiory/PeopleRepo.dart';
import 'package:akababi/repositiory/UserRepo.dart';
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

  Future<bool> friendRequest(int userId) async {
    return await peopleRepo.friendRequest(userId);
  }

  Future<bool> friendRequestRespond(
      String response, Map<String, dynamic> data) async {
    return await peopleRepo.friendRequestRespond(response, data);
    // emit(PeopleLoaded(data:));
  }

  void getPepoleById(int id) async {
    emit(PersonLoading());
    final posts = await userRepo.getUserPost(id);
    final friends = await userRepo.getUserFriend(id);
    final user = await authRepo.user;
    p.d(posts);
    p.d(friends);

    final people = await peopleRepo.getPeopleById(user!.id, id);
    emit(PersonLoaded(people, posts, friends));
  }

  Future<bool> blockUser(Map<String, dynamic> data) async {
    final user = await authRepo.user;
    data['user_id'] = user!.id;
    return await peopleRepo.blockUser(data);
  }

  Future<bool> removeFriendRequest(int id) async {
    final user = await authRepo.user;
    final data = {'user_id': user!.id, 'friend_id': id};
    return await peopleRepo.removeFriendRequest(data);
  }
}

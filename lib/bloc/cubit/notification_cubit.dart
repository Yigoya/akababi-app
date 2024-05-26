import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:akababi/repositiory/postRepo.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final authRepo = AuthRepo();
  NotificationCubit() : super(NotificationInitial());

  void getNotificationByUserId() async {
    emit(NotificationLoading());
    final user = await authRepo.user;
    final notifications = await PostRepo().getNotificationByUserId(user!.id);
    emit(NotificationLoaded(notifications: notifications));
  }

  void deleteNotification(int id) async {
    print('$id tryyyyyyyyyyyyyyy');
    await PostRepo().deleteNotification(id);
  }
}

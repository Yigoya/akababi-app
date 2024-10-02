import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:akababi/repositiory/postRepo.dart';
import 'package:bloc/bloc.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final authRepo = AuthRepo();
  NotificationCubit() : super(NotificationInitial());

  void getNotifications() async {
    emit(NotificationLoading());

    final notifications = await PostRepo().getNotifications();
    final numOfUnReadNotification = notifications
        .where((element) => element['is_read'] == false)
        .toList()
        .length;
    emit(NotificationLoaded(
        notifications: notifications,
        numOfUnreadNotification: numOfUnReadNotification));
  }

  void SetRead(List<int> ids) async {
    String joinedIds = ids.join(',');
    await PostRepo().SetReadMultipleNotification(joinedIds);
    Logger().d(ids);
    emit(NotificationLoading());

    final notifications = await PostRepo().getNotifications();
    final numOfUnReadNotification = notifications
        .where((element) => element['is_read'] == false)
        .toList()
        .length;
    emit(NotificationLoaded(
        notifications: notifications,
        numOfUnreadNotification: numOfUnReadNotification));
  }
}

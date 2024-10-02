part of 'notification_cubit.dart';

@immutable
sealed class NotificationState {}

final class NotificationInitial extends NotificationState {}

final class NotificationLoading extends NotificationState {}

final class NotificationLoaded extends NotificationState {
  final List<Map<String, dynamic>> notifications;
  final int numOfUnreadNotification;

  NotificationLoaded({
    required this.numOfUnreadNotification,
    required this.notifications,
  });
}

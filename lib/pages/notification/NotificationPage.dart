import 'package:akababi/bloc/cubit/notification_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<NotificationCubit>(context).getNotificationByUserId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
        ),
        body: BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is NotificationLoaded) {
              return ListView.builder(
                itemCount: state.notifications.length,
                itemBuilder: (context, index) {
                  final notification = state.notifications[index];
                  return GestureDetector(
                    onTap: () {
                      if (notification["notification_type"] == "post") {
                        Navigator.of(context, rootNavigator: true).pushNamed(
                            '/singlePost',
                            arguments: notification['item_id']);
                      } else if (notification["notification_type"] ==
                          "follower") {
                        Navigator.of(context, rootNavigator: true).pushNamed(
                            '/userProfile',
                            arguments: notification['sender_id']);
                      }
                      BlocProvider.of<NotificationCubit>(context)
                          .deleteNotification(notification['id']);
                    },
                    child: ListTile(
                      title: Text(notification['message']),
                      subtitle: Text(notification['created_at']),
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: Text('No Notification'),
              );
            }
          },
        ));
  }
}

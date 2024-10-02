import 'package:akababi/bloc/cubit/notification_cubit.dart';
import 'package:akababi/component/notification_card.dart';
import 'package:akababi/pages/post/image_view.dart';
import 'package:akababi/pages/post/video_view.dart';
import 'package:akababi/pages/profile/PersonProfile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<int> notificationIds = [];

  @override
  void initState() {
    super.initState();
  }

  // No need to override the dispose method to call SetRead here
  @override
  void dispose() {
    super.dispose();
  }

  // Handle SetRead safely when the page is popped
  Future<void> _onWillPop() async {
    // Call SetRead safely
    BlocProvider.of<NotificationCubit>(context).SetRead(notificationIds);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        _onWillPop();
      }, // Attach the pop action
      child: Scaffold(
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
                      if (notification["type"] == "LIKE") {
                        if (notification['media_type'] == 'image') {
                          Navigator.of(context, rootNavigator: true).push(
                              MaterialPageRoute(
                                  builder: (context) => ImageViewingPage(
                                      imageUrl: notification['media_url'],
                                      postedBy: notification['sender_name'],
                                      likes: notification['likes'])));
                        } else if (notification['media_type'] == 'video') {
                          Navigator.of(context, rootNavigator: true).push(
                              MaterialPageRoute(
                                  builder: (context) => VideoPlayerPage(
                                      videoUrl: notification['media_url'],
                                      postedBy: notification['sender_name'],
                                      likes: notification['likes'])));
                        }
                      } else if (notification["type"] == "FOLLOW") {
                        Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                    PersonPage(id: notification['sender_id'])));
                      }
                    },
                    child: VisibilityDetector(
                      key: Key(notification['id'].toString()),
                      onVisibilityChanged: (visibilityInfo) {
                        if (visibilityInfo.visibleFraction == 1.0 &&
                            !notificationIds.contains(notification['id']) &&
                            notification['is_read'] == false) {
                          notificationIds.add(notification['id']);
                        }
                      },
                      child: NotificationCard(notification: notification),
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
        ),
      ),
    );
  }
}

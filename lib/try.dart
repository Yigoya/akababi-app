import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<String?> _sub;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
    _handleInitialLink();
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  void _initDeepLinkListener() {
    _sub = linkStream.listen((String? link) {
      if (link != null) {
        _handleDeepLink(link);
      }
    }, onError: (err) {
      print('Failed to receive link: $err');
    });
  }

  Future<void> _handleInitialLink() async {
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }
    } catch (e) {
      print('Failed to receive initial link: $e');
    }
  }

  void _handleDeepLink(String link) {
    Uri uri = Uri.parse(link);
    if (uri.pathSegments.length == 2) {
      String type = uri.pathSegments[0];
      String id = uri.pathSegments[1];

      if (type == 'post') {
        _navigatorKey.currentState?.push(MaterialPageRoute(
          builder: (context) => PostScreen(postId: id),
        ));
      } else if (type == 'user') {
        _navigatorKey.currentState?.push(MaterialPageRoute(
          builder: (context) => UserProfileScreen(userId: id),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Deep Linking Example'),
        ),
        body: const Center(
          child: Text('Welcome to the app!'),
        ),
      ),
    );
  }
}

class PostScreen extends StatelessWidget {
  final String postId;

  const PostScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post $postId'),
      ),
      body: Center(
        child: Text('Displaying post $postId'),
      ),
    );
  }
}

class UserProfileScreen extends StatelessWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile $userId'),
      ),
      body: Center(
        child: Text('Displaying profile of user $userId'),
      ),
    );
  }
}

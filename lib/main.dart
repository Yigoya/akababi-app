import 'dart:async';

import 'package:akababi/bloc/auth/auth_bloc.dart';
import 'package:akababi/bloc/cubit/notification_cubit.dart';
import 'package:akababi/bloc/cubit/person_cubit.dart';
import 'package:akababi/bloc/cubit/post_cubit.dart';
import 'package:akababi/bloc/cubit/search_cubit.dart';
import 'package:akababi/bloc/cubit/single_post_cubit.dart';
import 'package:akababi/pages/Nearme/Nearme.dart';
import 'package:akababi/bloc/cubit/people_cubit.dart';
import 'package:akababi/pages/feed/FeedPage.dart';
import 'package:akababi/pages/chat/ChatPage.dart';
import 'package:akababi/pages/post/PostPage.dart';
import 'package:akababi/pages/post/SinglePostPage.dart';
import 'package:akababi/pages/profile/ProfilePage.dart';
import 'package:akababi/pages/profile/UserProfile.dart';
import 'package:akababi/pages/profile/cubit/picture_cubit.dart';
import 'package:akababi/pages/profile/cubit/profile_cubit.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:akababi/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:uni_links/uni_links.dart';

String initialRoute = '/login';

// Future<void> checkExist() async {
//   final authRepo = AuthRepo();
//   final user = await authRepo.user;
//   if (user == null) {
//     initialRoute = '/login';
//   }
// }

Future<bool> checkExist() async {
  final authRepo = AuthRepo();
  final user = await authRepo.user;
  if (user != null) {
    return true;
  }
  return false;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.location.request();
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
          channelKey: "channelKey",
          channelName: "channelName",
          channelDescription: "channelDescription",
          importance: NotificationImportance.Max)
    ],
    debug: true,
  );
  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });
  bool isExist = await checkExist();
  runApp(MyApp(isExist: isExist));
}

class MyApp extends StatefulWidget {
  final bool isExist;
  const MyApp({super.key, required this.isExist});

  @override
  State<MyApp> createState() => _MyAppState();
}

/// The state class for the root widget of the application.
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

  /// Initializes the deep link listener.
  void _initDeepLinkListener() {
    _sub = linkStream.listen((String? link) {
      if (link != null) {
        _handleDeepLink(link);
      }
    }, onError: (err) {
      print('Failed to receive link: $err');
    });
  }

  /// Handles the initial deep link when the app is launched.
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

  /// Handles a deep link by parsing the link and navigating to the appropriate page.
  void _handleDeepLink(String link) {
    Uri uri = Uri.parse(link);
    if (uri.pathSegments.length == 2) {
      String type = uri.pathSegments[0];
      String id = uri.pathSegments[1];
      print(type == 'post');
      if (type == 'post') {
        _navigatorKey.currentState?.push(
          MaterialPageRoute(
              builder: (context) => SinglePostPage(id: int.parse(id))),
        );
      } else if (type == 'user') {
        _navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (context) => UserProfile(
                  id: int.parse(id),
                )));
      }
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
          BlocProvider<PictureCubit>(create: ((context) => PictureCubit())),
          BlocProvider<ProfileCubit>(create: ((context) => ProfileCubit())),
          BlocProvider<PeopleCubit>(create: ((context) => PeopleCubit())),
          BlocProvider<PersonCubit>(create: ((context) => PersonCubit())),
          BlocProvider<SearchCubit>(create: ((context) => SearchCubit())),
          BlocProvider<PostCubit>(create: ((context) => PostCubit())),
          BlocProvider<SinglePostCubit>(
              create: ((context) => SinglePostCubit())),
          BlocProvider<NotificationCubit>(
              create: ((context) => NotificationCubit())),
        ],
        child: MaterialApp(
          navigatorKey: _navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          onGenerateRoute: generateRoute,
          initialRoute: widget.isExist ? '/' : '/login',
        ));
  }
}

/// The home page of the application.
///
/// This widget represents the main screen of the application.
/// It is a stateful widget that creates a corresponding state class [_HomePageState].
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// The state class for the [HomePage] widget.
class _HomePageState extends State<HomePage> {
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  @override
  Widget build(BuildContext context) {
    // final authBloc = BlocProvider.of<AuthBloc>(context)
    //   ..add(LoadUserInfoEvent(context));
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      confineInSafeArea: true,
      backgroundColor: Colors.black, // Default is Colors.white.
      handleAndroidBackButtonPress: true, // Default is true.
      resizeToAvoidBottomInset:
          true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
      stateManagement: true, // Default is true.
      hideNavigationBarWhenKeyboardShows:
          true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
        colorBehindNavBar: Colors.white,
      ),
      popAllScreensOnTapOfSelectedTab: true,
      popActionScreens: PopActionScreensType.all,
      itemAnimationProperties: const ItemAnimationProperties(
        // Navigation Bar's items animation properties.
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
      ),
      screenTransitionAnimation: const ScreenTransitionAnimation(
        // Screen transition animation on change of selected tab.
        animateTabTransition: true,
        curve: Curves.ease,
        duration: Duration(milliseconds: 200),
      ),
      navBarStyle: NavBarStyle.style6,
    );
  }

  /// Builds a list of screens to be displayed in the application.
  ///
  /// Returns a list of [Widget] objects representing the screens.
  List<Widget> _buildScreens() {
    return [
      const FeedPage(),
      NearMePage(),
      const PostPage(),
      const ChatPage(),
      const ProfilePage()
    ];
  }

  /// Returns a list of [PersistentBottomNavBarItem] objects.
  ///
  /// Each [PersistentBottomNavBarItem] represents an item in the persistent
  /// bottom navigation bar. It contains an icon, a title, and primary colors
  /// for both active and inactive states.
  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(FeatherIcons.home),
        title: ("Home"),
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(FeatherIcons.compass),
        title: ("Near Me"),
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(
          FeatherIcons.plusCircle,
          color: Colors.white,
        ),
        title: ("Post"),
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(FeatherIcons.messageCircle),
        title: ("Chat"),
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(FeatherIcons.user),
        title: ("Profile"),
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }
}

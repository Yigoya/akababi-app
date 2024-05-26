import 'package:akababi/bloc/auth/auth_bloc.dart';
import 'package:akababi/bloc/cubit/notification_cubit.dart';
import 'package:akababi/bloc/cubit/post_cubit.dart';
import 'package:akababi/bloc/cubit/search_cubit.dart';
import 'package:akababi/pages/Nearme/Nearme.dart';
import 'package:akababi/bloc/cubit/people_cubit.dart';
import 'package:akababi/pages/feed/FeedPage.dart';
import 'package:akababi/pages/chat/ChatPage.dart';
import 'package:akababi/pages/post/PostPage.dart';
import 'package:akababi/pages/profile/ProfilePage.dart';
import 'package:akababi/pages/profile/cubit/picture_cubit.dart';
import 'package:akababi/pages/profile/cubit/profile_cubit.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:akababi/route.dart';
import 'package:akababi/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

String initialRoute = '/';

Future<void> checkExist() async {
  final authRepo = AuthRepo();
  final user = await authRepo.user;
  if (user == null) {
    initialRoute = '/login';
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestLocationPermission();

  // await getCurrentLocation();
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
  await checkExist();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
          BlocProvider<PictureCubit>(create: ((context) => PictureCubit())),
          BlocProvider<ProfileCubit>(create: ((context) => ProfileCubit())),
          BlocProvider<PeopleCubit>(create: ((context) => PeopleCubit())),
          BlocProvider<SearchCubit>(create: ((context) => SearchCubit())),
          BlocProvider<PostCubit>(create: ((context) => PostCubit())),
          BlocProvider<NotificationCubit>(
              create: ((context) => NotificationCubit())),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          onGenerateRoute: generateRoute,
          initialRoute: initialRoute,
        ));
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PersistentTabController _controller =
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
      itemAnimationProperties: ItemAnimationProperties(
        // Navigation Bar's items animation properties.
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
      ),
      screenTransitionAnimation: ScreenTransitionAnimation(
        // Screen transition animation on change of selected tab.
        animateTabTransition: true,
        curve: Curves.ease,
        duration: Duration(milliseconds: 200),
      ),
      navBarStyle: NavBarStyle.style6,
    );
  }

  List<Widget> _buildScreens() {
    return [FeedPage(), NearMePage(), PostPage(), ChatPage(), ProfilePage()];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(FeatherIcons.home),
        title: ("Home"),
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(FeatherIcons.compass),
        title: ("Near Me"),
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(
          FeatherIcons.plusCircle,
          color: Colors.white,
        ),
        title: ("Post"),
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(FeatherIcons.messageCircle),
        title: ("Chat"),
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(FeatherIcons.user),
        title: ("Profile"),
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }
}

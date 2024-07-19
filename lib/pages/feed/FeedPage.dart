import 'package:akababi/bloc/auth/auth_bloc.dart';
import 'package:akababi/bloc/auth/auth_event.dart';
import 'package:akababi/bloc/cubit/post_cubit.dart';
import 'package:akababi/pages/search/SearchPage.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:akababi/skeleton/postItemSkeleton.dart';
import 'package:flutter/material.dart';
import 'package:akababi/component/PostItem.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final bool _showAppBar = true;
  bool _switchValue = true;

  final authRepo = AuthRepo();
  String userFullName = '';
  Future<void> checkExist() async {
    final authRepo = AuthRepo();
    final user = await authRepo.user;
    if (user == null) {
      Navigator.of(context, rootNavigator: true).pushNamed('/login');
    }
  }

  Future<void> loadName() async {
    final user = await authRepo.user;
    if (user != null) {
      setState(() {
        userFullName = user.fullname;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    await BlocProvider.of<PostCubit>(context).loadPostById(context);
    BlocProvider.of<AuthBloc>(context).add(GetLocationEvent(context: context));
    await loadName();
  }

  String _greeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 18) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[400],
      appBar: AppBar(
        title: Text(
          "Akababi",
          style: GoogleFonts.kodchasan(
            textStyle: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w500,
                color: Color.fromARGB(255, 199, 47, 93)),
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SearchPage()));
              },
              icon: const Icon(FeatherIcons.search)),
          IconButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true)
                    .pushNamed("/notification");
              },
              icon: const Icon(FeatherIcons.bell)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          BlocProvider.of<PostCubit>(context).loadPostById(context);
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 260,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              "hi $userFullName",
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.kodchasan(
                                textStyle: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromARGB(255, 61, 14, 28)),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Text("visibility"),
                            SizedBox(
                              height: 20,
                              width: 30,
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: Switch(
                                    value: _switchValue,
                                    onChanged: (newValue) {
                                      if (newValue) {
                                        BlocProvider.of<AuthBloc>(context).add(
                                            GetLocationEvent(
                                                context: context, off: false));
                                      } else {
                                        BlocProvider.of<AuthBloc>(context).add(
                                            GetLocationEvent(
                                                context: context, off: true));
                                      }
                                      setState(() {
                                        _switchValue = newValue;
                                      });
                                    }),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text("${_greeting()} see what is happening round you",
                        style: GoogleFonts.kodchasan(
                          textStyle: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                              color: const Color.fromARGB(255, 139, 35, 66)
                                  .withOpacity(0.5)),
                        )),
                  ],
                ),
              ),
              const SizedBox(
                height: 1,
              ),
              BlocBuilder<PostCubit, PostState>(
                builder: (context, state) {
                  if (state is PostLoading) {
                    return const Column(
                        children: [PostItemSkeleton(), PostItemSkeleton()]);
                  } else if (state is PostLoaded) {
                    var posts = state.posts;
                    if (state.posts.isEmpty) {
                      return Container(
                        height: 560,
                        color: Colors.white,
                        child: Center(
                            child: Text("No post found",
                                style: GoogleFonts.kodchasan(
                                  textStyle: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w500,
                                      color: const Color.fromARGB(255, 0, 0, 0)
                                          .withOpacity(0.5)),
                                ))),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        return PostItem(
                          post: posts[index],
                        );
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
//  Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppHeader(context, "Feed"),
//         body: SingleChildScrollView(
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text("data"),
//                         Row(
//                           children: [
//                             Text("visibility"),
//                             SizedBox(
//                                 height: 20,
//                                 width: 30,
//                                 child: FittedBox(
//                                     fit: BoxFit.fill,
//                                     child:
//                                         Switch(value: true, onChanged: (_) {})))
//                           ],
//                         ),
//                       ],
//                     ),
//                     Text("data"),
//                   ],
//                 ),
//               ),
//               PostItem(),
//               // PeopleItem(),
//               ChatIcon(
//                 isOnline: true,
//                 imageUrl: "https://picsum.photos/200",
//                 username: "yigo",
//               ),
//               ChatListItem(
//                   fullName: "Yigermal Abebe",
//                   lastMessage: "lastMessage for remainber",
//                   isDelivered: true),
//               Text("Welcome",
//                   style: TextStyle(color: Colors.deepOrange, fontSize: 30)),
//               ElevatedButton(
//                   onPressed: () async {
//                     BlocProvider.of<AuthBloc>(context).add(GetLocationEvent());
//                   },
//                   child: Text('get location')),
//             ],
//           ),
//         ));
//   }

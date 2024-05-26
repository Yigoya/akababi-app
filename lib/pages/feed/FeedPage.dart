import 'package:akababi/bloc/auth/auth_bloc.dart';
import 'package:akababi/bloc/auth/auth_event.dart';
import 'package:akababi/bloc/cubit/post_cubit.dart';
import 'package:akababi/component/ChatListItem.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:akababi/repositiory/postRepo.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";
import 'package:flutter/material.dart';
import 'package:akababi/component/Header.dart';
import 'package:akababi/component/PostItem.dart';
import 'package:akababi/component/ChatIcon.dart';
import 'package:akababi/component/peopleItem.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  bool _showAppBar = true;

  final authRepo = AuthRepo();
  String userFullName = '';
  Future<void> loadName() async {
    final user = await authRepo.user;
    setState(() {
      userFullName = user!.fullname;
    });
  }

  @override
  void initState() {
    super.initState();
    loadName();
    // checkExist();
    BlocProvider.of<PostCubit>(context).loadPostById();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(context, "Feed"),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Welcome to Akababi"),
                      Row(
                        children: [
                          Text("visibility"),
                          SizedBox(
                            height: 20,
                            width: 30,
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: Switch(value: true, onChanged: (_) {}),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text("$userFullName"),
                ],
              ),
            ),
            BlocBuilder<PostCubit, PostState>(
              builder: (context, state) {
                if (state is PostLoading) {
                  return CircularProgressIndicator.adaptive();
                } else if (state is PostLoaded || state is SinglePostLoaded) {
                  var posts = state is PostLoaded
                      ? (state as PostLoaded).posts
                      : (state as SinglePostLoaded).posts;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
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
            // PostItem(),
            // PeopleItem(),
            ChatIcon(
              isOnline: true,
              imageUrl: "https://picsum.photos/200",
              username: "yigo",
            ),
            ChatListItem(
              fullName: "Yigermal Abebe",
              lastMessage: "lastMessage for remainber",
              isDelivered: true,
            ),
            Text(
              "Welcome",
              style: TextStyle(color: Colors.deepOrange, fontSize: 30),
            ),
            ElevatedButton(
              onPressed: () async {
                BlocProvider.of<AuthBloc>(context).add(GetLocationEvent());
              },
              child: Text('get location'),
            ),
          ],
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

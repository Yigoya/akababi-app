import 'package:akababi/bloc/cubit/person_cubit.dart';
import 'package:akababi/model/User.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:akababi/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class UserProfile extends StatefulWidget {
  final int id;

  const UserProfile({super.key, required this.id});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  var _error = false;
  Map<String, String> place = {'city': '', 'country': ''};
  User? user;
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    final _place =
        await BlocProvider.of<PersonCubit>(context).getPepoleById(widget.id);
    final _user = await AuthRepo().user;
    if (_place != null) {
      setState(() {
        place = _place;
        user = _user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.id);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: BlocBuilder<PersonCubit, PersonState>(
            builder: (context, state) {
              if (state is PersonLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is PersonLoaded) {
                var data = state.person;

                var imageUrl = data['profile_picture'] ??
                    'uploads/image/183be109c77b089a72a693d8fd9e91ef-1000033241.jpg';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Image(
                          image: NetworkImage('${AuthRepo.SERVER}/$imageUrl'),
                          fit: BoxFit.cover,
                          height: MediaQuery.of(context).size.height * 0.6,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/image/bgauth.jpg',
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height / 2,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.5),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['first_name'],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '@${data['username']}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    data['bio'] != null
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              data['bio'] ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                    const SizedBox(height: 10),
                    place['city'] != '' && place['country'] != ''
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on),
                                Text(
                                  '${place['city']}, ${place['country']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const Spacer(),
                                Row(children: [
                                  Text(
                                    'Open Map',
                                    style: GoogleFonts.aBeeZee(
                                        textStyle:
                                            const TextStyle(fontSize: 22)),
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        openGoogleMaps(data['latitude'],
                                            data['longitude']);
                                      },
                                      icon: const Icon(Icons.map_rounded)),
                                ]),
                              ],
                            ),
                          )
                        : SizedBox.shrink(),
                    const SizedBox(height: 10),
                    user != null && user!.id != widget.id
                        ? Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: FriendStatusWidget(
                                friendShipStatus: data['friendShip'],
                                is_request: data['is_request'],
                                personId: data['id']))
                        : SizedBox.shrink(),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("friends",
                              style: GoogleFonts.roboto(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: state.friends.length,
                              itemBuilder: (context, index) {
                                var friend = state.friends[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => UserProfile(
                                        id: friend['id'],
                                      ),
                                    ));
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 16),
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundImage: _error
                                              ? NetworkImage(
                                                      '${AuthRepo.SERVER}/${friend['profile_picture']}')
                                                  as ImageProvider<Object>
                                              : const AssetImage(
                                                  'assets/image/profile.png'),
                                          onBackgroundImageError:
                                              (exception, stackTrace) {
                                            setState(() {
                                              print('error $exception');
                                              _error = true;
                                            });
                                          },
                                        ),
                                        Text(friend['full_name']),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    // SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          state.person['mutual_friends'].length > 0
                              ? Text("mutual friends",
                                  style: GoogleFonts.roboto(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold))
                              : Container(),
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: state.person['mutual_friends'].length,
                              itemBuilder: (context, index) {
                                var friend =
                                    state.person['mutual_friends'][index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => UserProfile(
                                        id: friend['id'],
                                      ),
                                    ));
                                  },
                                  child: Column(
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundImage: _error
                                            ? NetworkImage(
                                                    '${AuthRepo.SERVER}/${friend['profile_picture']}')
                                                as ImageProvider<Object>
                                            : const AssetImage(
                                                'assets/image/profile.png'),
                                        onBackgroundImageError:
                                            (exception, stackTrace) {
                                          setState(() {
                                            print('error $exception');
                                            _error = true;
                                          });
                                        },
                                      ),
                                      Text(
                                          '${friend['first_name']} ${friend['last_name']}'),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text("Posts"),
                    GridView.builder(
                      shrinkWrap: true,
                      itemCount: state.posts.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                      ),
                      itemBuilder: (context, index) {
                        var post = state.posts[index];

                        return listItem(context, post);
                      },
                    ),
                    // Add other user profile information here
                  ],
                );
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }
}

class FriendStatusWidget extends StatefulWidget {
  final dynamic friendShipStatus;
  final bool is_request;
  final int personId;

  const FriendStatusWidget({
    Key? key,
    required this.friendShipStatus,
    required this.is_request,
    required this.personId,
  }) : super(key: key);

  @override
  _FriendStatusWidgetState createState() => _FriendStatusWidgetState();
}

class _FriendStatusWidgetState extends State<FriendStatusWidget> {
  var friendShip;
  var is_request;
  @override
  void initState() {
    friendShip = widget.friendShipStatus;
    is_request = widget.is_request;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildFriendStatusWidget();
  }

  Widget _buildFriendStatusWidget() {
    print(is_request);
    if (friendShip == null) {
      return GestureDetector(
        onTap: () async {
          setState(() {
            friendShip = {'status': 'loading'};
          });
          final res = await BlocProvider.of<PersonCubit>(context)
              .friendRequest(widget.personId);
          if (res) {
            setState(() {
              friendShip = {'status': 'pending'};
              is_request = true;
            });
          } else {
            setState(() {
              friendShip = null;
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(5),
          ),
          child: const Center(
            child: Text(
              'Follow',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    } else if (friendShip['status'] == 'accepted') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              var status = friendShip as Map<String, dynamic>;
              setState(() {
                friendShip['status'] = 'loading';
              });

              final res = await BlocProvider.of<PersonCubit>(context)
                  .friendRequestRespond("pending", status);
              if (res) {
                setState(() {
                  friendShip['status'] = 'pending';
                });
              } else {
                setState(() {
                  friendShip['status'] = 'accepted';
                });
              }
            },
            child: Container(
              width: (MediaQuery.of(context).size.width * 0.5) - 32,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 72, 73, 72),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Center(
                child: Text(
                  'Friends',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 4,
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: (MediaQuery.of(context).size.width * 0.5) - 32,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(127, 72, 73, 21),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Center(
                child: Text(
                  'Message',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (String value) async {
              if (value == 'block') {
                final res = await BlocProvider.of<PersonCubit>(context)
                    .blockUser({'blocked_user_id': widget.personId});
                Navigator.of(context).pop();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'block',
                child: Text('Block'),
              ),
            ],
            child: const Icon(Icons.more_vert),
          ),
        ],
      );
    } else if (!is_request && friendShip['status'] == 'pending') {
      print(is_request);
      return GestureDetector(
        onTap: () async {
          var status = friendShip as Map<String, dynamic>;
          setState(() {
            friendShip['status'] = 'loading';
          });

          final res = await BlocProvider.of<PersonCubit>(context)
              .friendRequestRespond("accepted", status);
          if (res) {
            setState(() {
              friendShip['status'] = 'accepted';
            });
          } else {
            setState(() {
              friendShip['status'] = 'pending';
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(5),
          ),
          child: const Center(
            child: Text(
              'Follow back',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    } else if (friendShip['status'] == 'pending') {
      return GestureDetector(
        onTap: () async {
          var status = friendShip as Map<String, dynamic>;
          setState(() {
            friendShip['status'] = 'loading';
          });

          final res = await BlocProvider.of<PersonCubit>(context)
              .removeFriendRequest(widget.personId);
          if (res) {
            setState(() {
              friendShip = null;
            });
          } else {
            setState(() {
              friendShip['status'] = 'pending';
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(5),
          ),
          child: const Center(
            child: Text(
              'Following',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    } else if (friendShip['status'] == 'rejected') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(5),
        ),
        child: const Center(
          child: Text(
            'Rejected',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    } else if (friendShip['status'] == 'loading') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(5),
        ),
        child: const Center(
          child: Text('Loading...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )),
        ),
      );
    } else {
      return Container();
    }
  }
}

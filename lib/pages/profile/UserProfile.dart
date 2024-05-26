import 'package:akababi/bloc/cubit/people_cubit.dart';
import 'package:akababi/model/User.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserProfile extends StatefulWidget {
  final int id;

  const UserProfile({super.key, required this.id});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<PeopleCubit>(context).getPepoleById(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    print(widget.id);
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<PeopleCubit, PeopleState>(
          builder: (context, state) {
            if (state is PeopleLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is SinglePeopleLoaded) {
              var data = (state as SinglePeopleLoaded).people;

              var imageUrl = data['profile_picture'] ??
                  'uploads/image/183be109c77b089a72a693d8fd9e91ef-1000033241.jpg';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Image(
                        image: NetworkImage('${AuthRepo.SERVER}/${imageUrl}'),
                        fit: BoxFit.cover,
                        height: MediaQuery.of(context).size.height * 0.6,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/image/bgauth.jpg',
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height / 4,
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
                          icon: Icon(
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
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['first_name'],
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '@${data['username']}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      data['bio'] ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(Icons.location_on),
                        Text(
                          'Addis Ababa, Ethiopia',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  friendStatus(data['friendShip'], data['is_request'],
                      data['id'], context),
                  // Add other user profile information here
                ],
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  Widget friendStatus(
      dynamic friendShip, bool forMe, int personId, BuildContext context) {
    print(forMe);
    if (friendShip == null) {
      return GestureDetector(
        onTap: () {
          BlocProvider.of<PeopleCubit>(context).friendRequest(personId);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
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
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(
            'Friends',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    } else if (!forMe && friendShip['status'] == 'pending') {
      return Row(
        children: [
          GestureDetector(
            onTap: () {
              var status = friendShip as Map<String, dynamic>;
              BlocProvider.of<PeopleCubit>(context)
                  .friendRequestRespond("accepted", status);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
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
          ),
          GestureDetector(
            onTap: () {
              var status = friendShip as Map<String, dynamic>;
              BlocProvider.of<PeopleCubit>(context)
                  .friendRequestRespond("rejected", status);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
                child: Text(
                  'Cancel Request',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (friendShip['status'] == 'pending') {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(
            'Following',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    } else if (friendShip['status'] == 'rejected') {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
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
    } else {
      return Container();
    }
  }
}

import 'package:akababi/pages/profile/cubit/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingPage extends StatelessWidget {
  bool isDarkModeEnabled =
      false; // Add a boolean variable to track the dark mode state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Settings and Privacy',
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Edit Profile'),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {
              // Handle edit profile tap
            },
          ),
          ListTile(
            leading: Icon(Icons.dark_mode),
            title: Text('Dark Mode'),
            trailing: Switch(
              // Replace the trailing icon with a Switch widget
              value:
                  isDarkModeEnabled, // Set the value of the Switch based on the dark mode state
              onChanged: (value) {
                // Handle dark mode toggle
                // Update the dark mode state based on the new value
                isDarkModeEnabled = value;
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.language),
            title: Text('Language'),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {
              // Handle language tap
            },
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: Icon(
                Icons.logout,
                color: Colors.white,
              ),
              title: Text(
                'Log Out',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                BlocProvider.of<ProfileCubit>(context).logOut(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

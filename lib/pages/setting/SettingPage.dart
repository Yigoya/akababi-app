import 'package:akababi/pages/profile/EditProfile.dart';
import 'package:akababi/pages/profile/cubit/profile_cubit.dart';
import 'package:akababi/pages/setting/DeactivatePage.dart';
import 'package:akababi/pages/setting/DeletePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool isDarkModeEnabled = false;
  String? selectedOption;
  // Add a boolean variable to track the dark mode state
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Settings and Privacy',
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                  builder: (context) => const EditProfile(name: 'fullname')));
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              // Handle language tap
            },
          ),
          Row(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: const Icon(Icons.account_box),
              ),
              DropdownButton<String>(
                iconSize: 30,
                icon: Container(
                  margin: const EdgeInsets.only(left: 20),
                  child: const Icon(Icons.keyboard_arrow_down),
                ),
                underline: Container(),
                value: selectedOption,
                hint: const Text('Account'),
                items: <String>['Delete', 'Deactivate'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedOption = newValue;
                  });

                  // Handle the selected option
                  if (newValue != null) {
                    if (newValue == 'Delete') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const DeleteAccountPage(),
                        ),
                      );
                      print('Delete action selected');
                    } else if (newValue == 'Deactivate') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const DeactivatePage(),
                        ),
                      );
                      print('Deactivate action selected');
                    }
                  }
                },
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.white,
              ),
              title: const Text(
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

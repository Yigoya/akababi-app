import 'package:akababi/bloc/cubit/search_cubit.dart';
import 'package:akababi/pages/profile/UserProfile.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String searchText = '';
  List<String> searchResults = [];

  void search(String query) {
    // Perform the search logic here
    // You can use APIs or any other data source to fetch the search results
    // For simplicity, let's assume we have a list of search results already
    List<String> results = [
      'Result 1',
      'Result 2',
      'Result 3',
      'Result 4',
      'Result 5',
    ];

    setState(() {
      searchText = query;
      searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back)),
          flexibleSpace: Container(
            margin: EdgeInsets.only(left: 42, top: 32),
            padding: EdgeInsets.only(left: 16, bottom: 2),
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(40),
            ),
            child: TextField(
              onChanged: (value) {
                BlocProvider.of<SearchCubit>(context).search(value);
              },
              decoration: InputDecoration(
                hintText: 'Search...',
                border: InputBorder.none,
              ),
            ),
          )),
      body: Column(
        children: [
          BlocBuilder<SearchCubit, SearchState>(
            builder: (context, state) {
              if (state is SearchLoading) {
                return Center(child: CircularProgressIndicator());
              } else if (state is SearchLoaded) {
                if (state.search.isEmpty) {
                  return Center(child: Text('No results found'));
                }
                return Expanded(
                  child: ListView.builder(
                    itemCount: state.search.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UserProfile(
                                        id: state.search[index]['id'],
                                      )));
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: state.search[index]
                                        ["profile_picture"] !=
                                    null
                                ? NetworkImage(
                                        '${AuthRepo.SERVER}/${state.search[index]["profile_picture"]}')
                                    as ImageProvider<Object>?
                                : const AssetImage('assets/image/profile.png'),
                          ),
                          title: Text(
                              '${state.search[index]["first_name"]} ${state.search[index]["last_name"]}'),
                          subtitle: Text('@${state.search[index]["username"]}'),
                        ),
                      );
                    },
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
    );
  }
}

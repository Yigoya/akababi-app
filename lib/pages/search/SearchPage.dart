import 'package:akababi/bloc/cubit/search_cubit.dart';
import 'package:akababi/component/PostItem.dart';
import 'package:akababi/pages/profile/PersonProfile.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:akababi/skeleton/SearchItemSkeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

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
              icon: const Icon(Icons.arrow_back)),
          flexibleSpace: Container(
            margin: const EdgeInsets.only(left: 42, top: 32),
            padding: const EdgeInsets.only(left: 16, bottom: 2),
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(40),
            ),
            child: TextField(
              onChanged: (value) {
                if (value.length > 2) {
                  BlocProvider.of<SearchCubit>(context).search(value);
                }
              },
              decoration: const InputDecoration(
                hintText: 'Search...',
                border: InputBorder.none,
              ),
            ),
          )),
      body: SingleChildScrollView(
        child: Column(
          children: [
            BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) {
                if (state is SearchLoading) {
                  return Expanded(
                    child: ListView(
                      children: const [
                        SearchItemSkeleton(),
                        SearchItemSkeleton(),
                        SearchItemSkeleton(),
                        SearchItemSkeleton(),
                        SearchItemSkeleton(),
                      ],
                    ),
                  );
                } else if (state is SearchLoaded) {
                  if (state.search.isEmpty) {
                    return const Center(child: Text('No results found'));
                  }
                  return SizedBox(
                    height: state.search['user']!.length * 70.0,
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.search['user']!.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PersonPage(
                                          id: state.search['user']![index]
                                              ['id'],
                                        )));
                          },
                          child: SizedBox(
                            height: 70,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: state.search['user']![index]
                                            ["profile_picture"] !=
                                        null
                                    ? NetworkImage(
                                            '${AuthRepo.SERVER}/${state.search['user']![index]["profile_picture"]}')
                                        as ImageProvider<Object>?
                                    : const AssetImage(
                                        'assets/image/profile.png'),
                              ),
                              title: Text(
                                  '${state.search['user']![index]["first_name"]} ${state.search['user']![index]["last_name"]}'),
                              subtitle: Text(
                                  '@${state.search['user']![index]["username"]}'),
                            ),
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
            const SizedBox(height: 20),
            BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) {
                if (state is SearchLoading) {
                  return Expanded(
                    child: ListView(
                      children: const [
                        SearchItemSkeleton(),
                        SearchItemSkeleton(),
                        SearchItemSkeleton(),
                        SearchItemSkeleton(),
                        SearchItemSkeleton(),
                      ],
                    ),
                  );
                } else if (state is SearchLoaded) {
                  if (state.search.isEmpty) {
                    return const Center(child: Text('No results found'));
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.search['post']!.length,
                    itemBuilder: (context, index) {
                      return PostItem(
                        post: state.search['post']![index],
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
    );
  }
}

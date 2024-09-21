import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class InfiniteScrollExample extends StatefulWidget {
  @override
  _InfiniteScrollExampleState createState() => _InfiniteScrollExampleState();
}

class _InfiniteScrollExampleState extends State<InfiniteScrollExample> {
  List<dynamic> posts = [];
  int offset = 0;
  bool isLoading = false;
  bool hasMore = true;

  final ScrollController _scrollController = ScrollController();
  final int limit = 10; // Number of items per page
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _fetchPosts();

    // Add listener to scroll controller
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && hasMore && !isLoading) {
        _fetchPosts(); // Fetch more data when user reaches end of the list
      }
    });
  }

  Future<void> _fetchPosts() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await _dio.get(
        'https://your-backend.com/posts',
        queryParameters: {
          'offset': offset,
          'limit': limit,
        },
      );
      final List<dynamic> newPosts = response.data;

      setState(() {
        offset += newPosts.length;
        posts.addAll(newPosts);
        if (newPosts.length < limit) {
          hasMore = false; // No more posts to load
        }
      });
    } catch (e) {
      print('Error fetching posts: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Infinite Scroll Example')),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: posts.length + 1,
        itemBuilder: (context, index) {
          if (index < posts.length) {
            return ListTile(
              title: Text(posts[index]['title']),
              subtitle: Text(posts[index]['body']),
            );
          } else if (hasMore) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('No more posts'),
              ),
            );
          }
        },
      ),
    );
  }
  int? lastPostId;  // Tracks the ID of the last post

Future<void> _fetchPosts2() async {
  if (isLoading) return;

  setState(() {
    isLoading = true;
  });

  try {
    final response = await _dio.get(
      'https://your-backend.com/posts',
      queryParameters: {
        'lastPostId': lastPostId,  // Pass the last loaded post ID
        'limit': limit,
      },
    );
    final List<dynamic> newPosts = response.data;

    setState(() {
      if (newPosts.isNotEmpty) {
        lastPostId = newPosts.last['id'];  // Update the lastPostId to the latest post ID
        posts.addAll(newPosts);
      }
      if (newPosts.length < limit) {
        hasMore = false;  // No more posts to load
      }
    });
  } catch (e) {
    print('Error fetching posts: $e');
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}

}

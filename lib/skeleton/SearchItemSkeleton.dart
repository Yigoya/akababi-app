import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SearchItemSkeleton extends StatelessWidget {
  const SearchItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListTile(
          leading: Container(
            width: 50.0,
            height: 50.0,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          title: Container(
            width: 100.0,
            height: 20.0,
            color: Colors.white,
          ),
          subtitle: Container(
            width: 50.0,
            height: 10.0,
            color: Colors.white,
          ),
        ));
  }
}

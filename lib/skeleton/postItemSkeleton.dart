import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PostItemSkeleton extends StatelessWidget {
  const PostItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Container(
                  width: 50.0,
                  height: 50.0,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 100.0,
                          height: 20.0,
                          color: Colors.white,
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width - 291),
                        Container(
                          width: 100,
                          height: 30.0,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                        )
                      ],
                    ),
                    Container(
                      width: 50.0,
                      height: 10.0,
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 5.0),
          Container(
            width: double.infinity,
            height: 250.0,
            color: Colors.white,
          ),
          const SizedBox(height: 10.0),
          Container(
            width: double.infinity,
            height: 40.0,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

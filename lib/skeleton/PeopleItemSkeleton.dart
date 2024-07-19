import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PeopleItemSkeleton extends StatelessWidget {
  const PeopleItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: double.infinity,
          height: 400.0,
          alignment: Alignment.bottomLeft,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                    width: double.infinity,
                    height: 250.0,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    )),
                const SizedBox(height: 10.0),
                Container(
                    width: 200,
                    height: 50.0,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 10.0),
                Container(
                    width: 100,
                    height: 20.0,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5))),
                const SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 80,
                      height: 30.0,
                      color: Colors.white,
                    ),
                    Container(
                        width: 100,
                        height: 40.0,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20))),
                  ],
                ),
              ]),
        ));
  }
}

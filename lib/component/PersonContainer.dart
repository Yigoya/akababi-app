import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:flutter/material.dart';

class PersonContainer extends StatelessWidget {
  final Map<String, dynamic> data;
  const PersonContainer({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final imageUrl = data['profile_picture'] ??
        'uploads/image/9a2d5ca917fcb24a6bc26f34492b75ff-people.jpg';
    return Container(
      width: 200,
      height: 300,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage('${AuthRepo.SERVER}/$imageUrl'))),
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
          child: const Text(
            "data",
            style: TextStyle(color: Colors.white),
          ),
        ),
        Container(
            height: 50,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15)),
                color: Colors.black.withOpacity(0.5)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data['first_name'],
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17),
                ),
                GestureDetector(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.red),
                    child: const Text(
                      'Follow',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ],
            ))
      ]),
    );
  }
}

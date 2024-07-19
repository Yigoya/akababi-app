import 'package:akababi/pages/profile/UserProfile.dart';
import 'package:akababi/repositiory/AuthRepo.dart';
import 'package:akababi/utility.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class PeopleItem extends StatefulWidget {
  final Map<String, dynamic> data;
  const PeopleItem({super.key, required this.data});

  @override
  State<PeopleItem> createState() => _PeopleItemState();
}

class _PeopleItemState extends State<PeopleItem> {
  final logger = Logger();
  var _isLocalImage = false;
  var imageUrl = '';
  @override
  Widget build(BuildContext context) {
    if (widget.data['profile_picture'] == null) {
      setState(() {
        imageUrl = 'assets/image/bgauth.jpg';
        _isLocalImage = true;
      });
    } else {
      setState(() {
        imageUrl = widget.data['profile_picture'];
      });
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UserProfile(
                      id: widget.data['id'],
                    )));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
                fit: BoxFit.cover,
                image: !_isLocalImage
                    ? NetworkImage('${AuthRepo.SERVER}/$imageUrl')
                        as ImageProvider<Object>
                    : AssetImage(imageUrl) as ImageProvider<Object>,
                onError: (exception, stackTrace) {
                  setState(() {
                    imageUrl = 'assets/image/bgauth.jpg';
                    _isLocalImage = true;
                  });
                })),
        child: Container(
          height: 420,
          padding: const EdgeInsets.all(20),
          alignment: Alignment.bottomLeft, // Align items to the left
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.8),
                  ])),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${widget.data['first_name']} ${widget.data['last_name']}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white)),
              Text(
                '@${widget.data['username']}',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(
                width: 10,
              ),
              widget.data['bio'] != null
                  ? Text(
                      '${widget.data['bio']}',
                      style: const TextStyle(color: Colors.white),
                    )
                  : Container(),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  widget.data['distance'] != null
                      ? GestureDetector(
                          onTap: () {
                            print({
                              widget.data['latitude'],
                              widget.data['longitude']
                            });
                            openGoogleMaps(widget.data['latitude'],
                                widget.data['longitude']);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Colors.red),
                            child: Text(
                              '${widget.data['distance']} km',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                      : Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.red),
                          child: const Icon(
                            Icons.location_off,
                            size: 20,
                            color: Colors.white,
                          )),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UserProfile(
                                      id: widget.data['id'],
                                    )));
                      },
                      child: Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 255, 64, 64),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Text("view profile",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white)),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.white,
                              )
                            ],
                          )))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

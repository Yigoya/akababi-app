class User {
  int id;
  String fullname;
  String username;
  String? gender;
  String? date_of_birth;
  String? profile_picture;
  String? phonenumber;
  String? bio;
  String? location_id;
  String email;

  User({
    required this.id,
    required this.fullname,
    required this.username,
    required this.gender,
    required this.date_of_birth,
    required this.bio,
    required this.location_id,
    required this.profile_picture,
    required this.phonenumber,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullname': fullname,
      'username': username,
      'gender': gender,
      'date_of_birth': date_of_birth,
      'profile_picture': profile_picture,
      'phonenumber': phonenumber,
      'bio': bio,
      'location_id': location_id,
      'email': email,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    print(map['username']);
    RegExp regExp = RegExp(r"\d{4}-\d{2}-\d{2}");
    String? dateMatch = map['date_of_birth'] != null
        ? regExp.stringMatch(map['date_of_birth'])
        : null;
    print(dateMatch);
    // final date = DateTime.parse(map['date_of_birth']);
    // final formatedDate = '${date.year}-${date.month}-${date.day}';
    return User(
      id: map['id'],
      fullname: map['fullname'],
      username: map['username'],
      gender: map['gender'] ?? '',
      date_of_birth: dateMatch ?? '',
      profile_picture: map['profile_picture'] ?? '',
      phonenumber: map['phonenumber'] ?? '',
      bio: map['bio'] ?? '',
      location_id: map['location_id'] ?? '',
      email: map['email'],
    );
  }
}

class User {
  int id;
  String fullname;
  String username;
  String? profile_picture;
  String? bio;
  String? location_id;
  String email;

  User({
    required this.id,
    required this.fullname,
    required this.username,
    required this.bio,
    required this.location_id,
    required this.profile_picture,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullname': fullname,
      'username': username,
      'profile_picture': profile_picture,
      'bio': bio,
      'location_id': location_id,
      'email': email,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      fullname: map['fullname'],
      username: map['username'],
      profile_picture: map['profile_picture'],
      bio: map['bio'],
      location_id: map['location_id'],
      email: map['email'],
    );
  }
}

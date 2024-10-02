class Signup {
  String email;
  String password;
  String firstName;
  String lastName;
  String phoneNumber;
  String gender;
  String birthDate;
  String username;

  Signup({
    this.email = '',
    this.password = '',
    this.firstName = '',
    this.lastName = '',
    this.phoneNumber = '',
    this.birthDate = '',
    this.gender = '',
    this.username = '',
  });

  set setEmail(String email) {
    this.email = email;
  }

  set setPassword(String password) {
    this.password = password;
  }

  set setFirstName(String firstName) {
    this.firstName = firstName;
  }

  set setLastName(String lastName) {
    this.lastName = lastName;
  }

  set setPhoneNumber(String phoneNumber) {
    this.phoneNumber = phoneNumber;
  }

  set setGender(String gender) {
    this.gender = gender;
  }

  set setBirthDate(String birthDate) {
    this.birthDate = birthDate;
  }

  set setUsername(String username) {
    this.username = username;
  }

  void getFromMap(Map<String, dynamic> map) {
    if (map['email'] != null) {
      email = map['email'];
    }
    if (map['password'] != null) {
      password = map['password'];
    }
    if (map['firstName'] != null) {
      firstName = map['firstName'];
    }
    if (map['lastName'] != null) {
      lastName = map['lastName'];
    }
    if (map['phoneNumber'] != null) {
      phoneNumber = map['phoneNumber'];
    }
    if (map['gender'] != null) {
      gender = map['gender'];
    }
    if (map['birthDate'] != null) {
      birthDate = map['birthDate'];
    }
    if (map['username'] != null) {
      username = map['username'];
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'birthDate': birthDate,
      'username': username,
    };
  }

  void clear() {
    email = '';
    password = '';
    firstName = '';
    lastName = '';
    phoneNumber = '';
    gender = '';
    birthDate = '';
  }

  bool get isValid {
    return email.isNotEmpty &&
        password.isNotEmpty &&
        firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        phoneNumber.isNotEmpty &&
        gender.isNotEmpty &&
        birthDate.isNotEmpty;
  }
}

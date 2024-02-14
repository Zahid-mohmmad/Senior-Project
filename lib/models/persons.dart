import 'package:cloud_firestore/cloud_firestore.dart';

class Person {
  //PERSONAL INFO
  String? imageProfile;
  String? email;
  String? password;
  String? name;
  int? age;
  String? phoneNo;
  String? major;
  String? gender;
  int? userStatus;

  //constructor of the class
  Person({
    this.imageProfile,
    this.email,
    this.password,
    this.name,
    this.age,
    this.phoneNo,
    this.major,
    this.gender,
    this.userStatus,
  });

  static Person fromDataSnapshot(DocumentSnapshot snapshot) {
    var dataSnapshot = snapshot.data() as Map<String, dynamic>;
    return Person(
      //for retriving data from the database we convert json to normal format
      imageProfile: dataSnapshot['imageProfile'],
      email: dataSnapshot["email"],
      password: dataSnapshot["password"],
      name: dataSnapshot["name"],
      age: dataSnapshot['age'],
      phoneNo: dataSnapshot['phoneNo'],
      major: dataSnapshot['major'],
      gender: dataSnapshot['gender'],
      userStatus: dataSnapshot['userStatus'],
    );
  }

  // convert the data to json format to save it in firestore database.
  Map<String, dynamic> toJson() => {
        "imageProfile": imageProfile,
        "email": email,
        "password": password,
        "name": name,
        'age': age,
        'phoneNo': phoneNo,
        'major': major,
        'gender': gender,
        'UserStatus': userStatus,
      };
}

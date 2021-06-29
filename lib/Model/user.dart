import 'package:http/http.dart' as http;
import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

Future<List<Hobby>> fetchDetails() async {
  final url = "http://hobcom.in/getprofiledetails.php";
  var url2 = Uri.parse(url);
  final http.Response response = await http.post(url2,
      body: jsonEncode(<String, dynamic>{"user_id": "101"}));

  var responseJson = json.decode(response.body);
  return (responseJson['hobbies'] as List)
      .map((p) => Hobby.fromJson(p))
      .toList();
}

class User {
  User({
    this.userdetails,
    this.hobbies,
    String name,
  });

  Userdetails userdetails;
  List<Hobby> hobbies;

  factory User.fromJson(Map<String, dynamic> json) => User(
        userdetails: Userdetails.fromJson(json["userdetails"]),
        hobbies:
            List<Hobby>.from(json["hobbies"].map((x) => Hobby.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "userdetails": userdetails.toJson(),
        "hobbies": List<dynamic>.from(hobbies.map((x) => x.toJson())),
      };
}

class Hobby {
  Hobby({
    this.hobbiesId,
    this.id,
    this.hobbyname,
    this.hobbydescription,
  });

  String hobbiesId;
  String id;
  String hobbyname;
  String hobbydescription;

  factory Hobby.fromJson(Map<String, dynamic> json) => Hobby(
        hobbiesId: json["hobbies_id"],
        id: json["id"],
        hobbyname: json["hobbyname"],
        hobbydescription: json["hobbydescription"],
      );

  Map<String, dynamic> toJson() => {
        "hobbies_id": hobbiesId,
        "id": id,
        "hobbyname": hobbyname,
        "hobbydescription": hobbydescription,
      };
}

class Userdetails {
  Userdetails({
    this.id,
    this.userId,
    this.userName,
    this.homeTown,
    this.passion,
    this.profilePicture,
    this.modified,
    this.uid,
    this.uname,
    this.email,
    this.mobileno,
    this.profileFlag,
  });

  String id;
  String userId;
  String userName;
  String homeTown;
  String passion;
  String profilePicture;
  DateTime modified;
  String uid;
  String uname;
  String email;
  String mobileno;
  String profileFlag;

  factory Userdetails.fromJson(Map<String, dynamic> json) => Userdetails(
        id: json["id"],
        userId: json["user_id"],
        userName: json["user_name"],
        homeTown: json["home_town"],
        passion: json["passion"],
        profilePicture: json["profile_picture"],
        modified: DateTime.parse(json["modified"]),
        uid: json["UID"],
        uname: json["UNAME"],
        email: json["email"],
        mobileno: json["mobileno"],
        profileFlag: json["profile_flag"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "user_name": userName,
        "home_town": homeTown,
        "passion": passion,
        "profile_picture": profilePicture,
        "modified": modified.toIso8601String(),
        "UID": uid,
        "UNAME": uname,
        "email": email,
        "mobileno": mobileno,
        "profile_flag": profileFlag,
      };
}

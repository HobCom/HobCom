import 'package:flutter/material.dart';
import 'package:hobcom/Utils/const..dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AllFriendList extends StatefulWidget {
  @override
  _AllFriendListState createState() => _AllFriendListState();
}

class _AllFriendListState extends State<AllFriendList> {
  String id;
  bool _isLoading = false;
  String username;
  Future getId() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    print(sharedPreferences.getString("userid"));
    id = sharedPreferences.getString("userid");
    username = sharedPreferences.get("username");
  }

  var frndName = "";
  var allFriendList = [];
  Future<void> getFriendList() async {
    String url = "http://hobcom.in/getfriend_list.php";
    var url2 = Uri.parse(url);
    http.Response response = await http.post(url2,
        body: jsonEncode(<String, dynamic>{"user_id": id}));
    if (response.body.isNotEmpty) {
      print(json.decode(response.body));
      allFriendList = json.decode(response.body);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    setState(() {
      _isLoading = true;
    });

    await getId();
    await getFriendList();
    print(id);
    // print("Name : " +(allFriendList[0]["sender_uid"] == id ? allFriendList[0]["receiver_user_profilename"] :allFriendList[0]["sender_user_profilename"]),);
    // print(allFriendList[0]["sender_uid"]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Hobcom Friends"),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: Image(
                  image: AssetImage("lib/asset/horseLoading.gif"),
                  height: 100,
                  width: 100))
          : allFriendList.isEmpty
              ? Center(child: Text("No friends yet "))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: allFriendList.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 300,
                      height: 170,
                      padding: new EdgeInsets.all(10.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        color: kprimary,
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Align(
                                  alignment: Alignment.topLeft,
                                  child: (allFriendList[index]["sender_uid"] ==
                                                  id
                                              ? allFriendList[index]
                                                  ["receiver_profilepicture"]
                                              : allFriendList[index]
                                                  ["sender_profilepicture"]) !=
                                          null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(70),
                                          child: Image.network(
                                            allFriendList[index]
                                                        ["sender_uid"] ==
                                                    id
                                                ? allFriendList[index]
                                                    ["receiver_profilepicture"]
                                                : allFriendList[index]
                                                    ["sender_profilepicture"],
                                            height: 50,
                                            width: 50,
                                          ),
                                        )
                                      : Icon(Icons.person,
                                          size: 50, color: Colors.white)),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      "Name : " +
                                          (allFriendList[index]["sender_uid"] ==
                                                  id
                                              ? allFriendList[index]
                                                  ["receiver_user_profilename"]
                                              : allFriendList[index]
                                                  ["sender_user_profilename"]),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                ],
                              ),
                              // Text("uid : " + (allFriendList[index]["sender_uid"] != id ?  allFriendList[index]["sender_uid"]: allFriendList[index]["requestid"]) ),
                              SizedBox(height: 8),
                              Text("Friends since : " +
                                  allFriendList[index]["accept_decline_date"]),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
    );
  }
}

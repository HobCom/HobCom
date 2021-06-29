import 'package:clippy_flutter/arc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hobcom/Utils/const..dart';
import 'package:hobcom/chat/ChattingPage.dart';
import 'package:hobcom/chat/widgets/ProgressWidget.dart';
import 'package:hobcom/screen/chatting.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

bool _isLoading = true;

class ChatBox extends StatefulWidget {
  @override
  _ChatBoxState createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  var allFriendList = [];
  String id;
  String username;
  Future getId() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    print(sharedPreferences.getString("userid"));
    id = sharedPreferences.getString("userid");
    username = sharedPreferences.get("username");
  }

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
    await getId();
    getFriendList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inbox"),
        // actions: [
        //   IconButton(
        //       icon: Icon(
        //         Icons.search,
        //         color: Colors.black,
        //         size: 30,
        //       ),
        //       onPressed: () {}),
        //   IconButton(
        //       icon: Image(
        //         image: AssetImage(
        //           'images/icons/3dotmenu.png',
        //         ),
        //       ),
        //       onPressed: () {}),
        // ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                backgroundColor: kprimary,
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: allFriendList.isEmpty
                      ? Center(
                          child: Container(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Text(
                                  "Make friends to get started with chatting",
                                  style: TextStyle(fontWeight: FontWeight.w300),
                                ),
                              ),
                              margin: EdgeInsets.all(50),
                              height: 300,
                              width: 400,
                              decoration: new BoxDecoration(
                                  image: new DecorationImage(
                                      image: new AssetImage(
                                          "images/getstartedchat.png"),
                                      fit: BoxFit.contain))),
                        )
                      : ListView.builder(
                          itemBuilder: (ctx, index) {
                            return
                                // ChatBox(allFriendList())

                                ChatInbox(
                              (allFriendList[index]["sender_uid"] == id
                                  ? allFriendList[index]["receiver_uid"]
                                  : allFriendList[index]["sender_uid"]),
                              allFriendList[index]["sender_uid"] == id
                                  ? allFriendList[index]
                                      ["receiver_profilepicture"]
                                  : allFriendList[index]
                                      ["sender_profilepicture"],
                              (allFriendList[index]["sender_uid"] == id
                                  ? allFriendList[index]
                                      ["receiver_user_profilename"]
                                  : allFriendList[index]
                                      ["sender_user_profilename"]),
                              "Message",
                              allFriendList[index]["accept_decline_date"],
                              allFriendList[index]["sender_uid"] == id
                                  ? allFriendList[index]["receiver_passion"]
                                  : allFriendList[index]["sender_passion"],
                            );
                          },
                          itemCount: allFriendList.length,
                        ),
                ),
              ],
            ),
    );
  }
}

class ChatInbox extends StatelessWidget {
  final String receiverID;
  final String pic;
  final String name;
  final String msg;
  final String time;
  final String passion;
  // String chatID;
  ChatInbox(
      this.receiverID, this.pic, this.name, this.msg, this.time, this.passion);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => Chat(
                          receiverId: receiverID,
                          receiverName: name,
                          userBio: passion,
                          receiverImage: pic,
                          joinedAt: time,
                        )
                    // ChatScreen()

                    )),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: pic != null
                    ? NetworkImage(pic)
                    : AssetImage("lib/asset/Person_icon.jpg"),
              ),
              title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(msg),
            )),
        //
        Padding(
            padding: EdgeInsets.only(left: 70),
            child: Divider(color: Colors.grey))
      ],
    );
  }
}

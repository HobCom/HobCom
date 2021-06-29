import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FriendRequests extends StatefulWidget {
  @override
  _FriendRequestsState createState() => _FriendRequestsState();
}

class _FriendRequestsState extends State<FriendRequests> {
  var requests = [];
  String currentUserid;
  getuid() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    currentUserid = await sharedPreferences.get("userid");
  }

  bool _isLoading = false;
  @override
  void didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    setState(() {
      _isLoading = true;
    });
    try {
      getuid().then((value) async {
        String url = "http://hobcom.in/getrequested_list.php";
        var url2 = Uri.parse(url);
        http.Response response = await http.post(url2,
            body: jsonEncode(<String, dynamic>{"user_id": currentUserid}));
        if (response.body.isNotEmpty) {
          requests = json.decode(response.body);
          print(json.decode(response.body));
        }
        requests
            .removeWhere((element) => element["sender_uid"] == currentUserid);

        setState(() {
          _isLoading = false;
        });
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print(e.toString());
    }
  }

  requestFlag(String reqID, String flag) async {
    String url = "http://hobcom.in/updatefrndrequeststatus.php";
    var url2 = Uri.parse(url);
    var response = await http.post(url2,
        body: jsonEncode(
            <String, dynamic>{"requestid": reqID, "requestflag": flag}));
    print(response);
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height * 0.5;
    return Scaffold(
      appBar: AppBar(title: Text("Pending Requests")),
      body: _isLoading
          ? Center(
              child: Image(
                  image: AssetImage("lib/asset/horseLoading.gif"),
                  height: 100,
                  width: 100))
          : Column(
              children: [
                SizedBox(height: 8),
                Expanded(
                  child: requests.length == 0
                      ? Center(child: Text("no pending requests"))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemBuilder: (ctx, index) {
                            return Column(
                              children: [
                                // requests[index]["sender_uid"] != currentUserid?
                                ListTile(
                                  leading: ClipRRect(
                                      child: requests[index][
                                                      "sender_profilepicture"] ==
                                                  null ||
                                              requests[index][
                                                      "sender_profilepicture"] ==
                                                  ""
                                          ? Image(
                                              image: AssetImage(
                                                  "lib/asset/Person_icon.jpg"))
                                          : FadeInImage.assetNetwork(
                                              imageErrorBuilder:
                                                  (BuildContext context,
                                                      Object exception,
                                                      StackTrace stackTrace) {
                                                return Image(
                                                    image: AssetImage(
                                                        "lib/asset/Person_icon.jpg"));
                                              },
                                              image: requests[index]
                                                  ["sender_profilepicture"],
                                              placeholder:
                                                  "lib/asset/Person_icon.jpg" // your assets image path
                                              )),
                                  title: Text(
                                    requests[index]["sender_user_profilename"],
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      IconButton(
                                          icon: Image.asset(
                                              "lib/asset/requestaccept.png"),
                                          onPressed: () {
                                            requests[index]['request_status'] =
                                                "2";
                                            requestFlag(
                                                requests[index]["requestid"],
                                                "2");
                                            setState(() {
                                              requests.removeAt(index);
                                            });
                                          }),
                                      Container(
                                        height: 60,
                                        width: 60,
                                        child: IconButton(
                                            icon: Image.asset(
                                              "lib/asset/declinerequest.jpg",
                                              fit: BoxFit.cover,
                                            ),
                                            onPressed: () {
                                              requests[index]
                                                  ['request_status'] = "3";
                                              requestFlag(
                                                  requests[index]["requestid"],
                                                  "3");
                                              setState(() {
                                                requests.removeAt(index);
                                              });
                                            }),
                                      )
                                    ],
                                  ),
                                ),
                                // divider
                                Divider(color: Colors.grey, thickness: 1.2)
                              ],
                            );
                          },
                          itemCount: requests.length,
                        ),
                ),
              ],
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RelatedEvents extends StatefulWidget {
  @override
  _RelatedEventsState createState() => _RelatedEventsState();
}

class _RelatedEventsState extends State<RelatedEvents> {
  var events = [];
  bool _isError = false;
  String city;
  String currentUserId;
  Future getId() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    print(sharedPreferences.getString("userid"));
    currentUserId = sharedPreferences.getString("userid");
    city = sharedPreferences.getString("currentcity");
  }

  @override
  void didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    await getId();
    String url = "http://hobcom.in/getrelatedevents.php";
    var url2 = Uri.parse(url);
    http.Response response = await http.post(url2,
        body: jsonEncode(
            <String, dynamic>{"user_id": currentUserId, "city": city}));
    if (response.body.isNotEmpty) {
      print(json.decode(response.body));
      events = json.decode(response.body);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return events == null || events.length == 0
        ? Center(
            child: Text(
            "No events nearby",
            style: TextStyle(fontWeight: FontWeight.w400),
          ))
        : ListView.builder(
            shrinkWrap: true,
            itemBuilder: (ctx, index) {
              return Column(children: [
                ListTile(
                  onTap: () {},
                  leading: CircleAvatar(
                    // onBackgroundImageError: (__,_) {
                    //   setState(() {
                    //     _isError=true;
                    //   });
                    // },
                    backgroundImage: events[index]['event_image'] == null ||
                            events[index]['event_image'] == ""
                        ? AssetImage("lib/asset/Person_icon.jpg")
                        : NetworkImage(events[index]['event_image']),
                  ),
                  title: Text(
                    events[index]['eventname'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(events[index]['eventdescription']),
                ),
                Padding(
                    padding: EdgeInsets.only(left: 70),
                    child: Divider(
                      color: Colors.black45,
                      thickness: 1,
                    )),
              ]);
            },
            itemCount: events.length,
          );
  }
}

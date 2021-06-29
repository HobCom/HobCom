import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Utils/const..dart';
import '../Utils/const..dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool isLoading = true;
  var notification = [];
  String id = "";
  Future<void> getuserlocaldata() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    id = sharedPreferences.get("userid");

    setState(() {});
    print(id);
  }

  var notiResponse;
  Future<void> getNotification() async {
    String url = "http://hobcom.in/notification_list.php";
    var url2 = Uri.parse(url);
    http.Response res = await http.post(url2,
        body: jsonEncode(<String, dynamic>{"user_id": id}));

    try {
      if (res.statusCode == 200) {
        setState(() {
          notiResponse = json.decode(res.body);
          notification = notiResponse;
        });
        // print(notiResponse);
        print(notification);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  void didChangeDependencies() async {
    await getuserlocaldata();
    await getNotification().then((value) {
      isLoading = false;
    });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Notifications"),
          backgroundColor: kprimary,
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(kprimary),
              ))
            : notification.isEmpty
                ? Center(
                    child: Text("No new notification"),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (ctx, index) {
                      return Column(
                        children: [
                          Notifications(
                            notification[index]["notification"],
                            notification[index]["created"],
                          )
                        ],
                      );
                    },
                    itemCount: notification.length,
                  ));
  }
}

class Notifications extends StatelessWidget {
  final noti;
  final time;
  Notifications(this.noti, this.time);

  void showToast(String str) {
    Fluttertoast.showToast(
        msg: str,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black87,
        textColor: Colors.white);
  }

  Widget build(BuildContext context) {
    return Column(
      children: [
        Slidable(
          closeOnScroll: true,
          secondaryActions: [
            IconSlideAction(
                iconWidget: Image(
                  image: AssetImage('lib/asset/decline.png'),
                  height: 50,
                ),
                closeOnTap: true,
                // caption: "Decline",
                color: Colors.grey,
                onTap: () => showToast('Decline')),
            IconSlideAction(
                iconWidget: Image(
                  image: AssetImage('lib/asset/accept.png'),
                  height: 50,
                ),
                closeOnTap: true,
                color: kprimary,
                // color: Colors.black,
                onTap: () => showToast('Accept'))
          ],
          actionPane: SlidableDrawerActionPane(),
          actionExtentRatio: 0.2,
          child: Card(
            child: Stack(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        AssetImage('images/icons/notification.png'),
                  ),
                  // title: Text('$noti',style:TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('$time'),
                  trailing: Icon(Icons.more_horiz),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(70, 18, 0, 0),
                  child: Row(
                    children: [
                      Text('$noti ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            elevation: 1,
          ),
        ),
        SizedBox(height: 5),
      ],
    );
  }
}

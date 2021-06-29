import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hobcom/Model/Infowindow.dart';
import 'package:hobcom/screen/homePage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

class RelatedUsers extends StatefulWidget {
  final users;
  final loc;
  GoogleMapController mapController;
  Completer<GoogleMapController> googleMapController = Completer();
  // final userHobbies;
  final String currrentUserid;
  RelatedUsers(this.users, this.loc, this.mapController,
      this.googleMapController, this.currrentUserid);
  @override
  _RelatedUsersState createState() => _RelatedUsersState();
}

class _RelatedUsersState extends State<RelatedUsers> {
  Future<void> sendRequest(String senderID, String reciverID) async {
    print(senderID + "s");
    String url = "http://hobcom.in/sendrequest.php";
    var url2 = Uri.parse(url);
    http.Response response = await http.post(url2,
        body: jsonEncode(<String, dynamic>{
          "senderid": senderID,
          "receiverid": reciverID,
        }));
    if (response.body.isNotEmpty) {
      print(json.decode(response.body));
      print("request is now sent");
    }
  }

  @override
  Widget build(BuildContext context) {
    final providerobject = Provider.of<Infowindow>(context, listen: false);

    final double widthinfowindow = 250;
    final double marketofset = 170;
    Future<void> _changeMapPosition(LatLng pos) async {
      final CameraPosition finalPosition =
          CameraPosition(target: pos, zoom: 12.5);
      widget.mapController = await widget.googleMapController.future;
      widget.mapController
          .animateCamera(CameraUpdate.newCameraPosition(finalPosition));
    }

    return widget.users == null || widget.users.length == 0
        ? Center(
            child: Text(
            "No users nearby",
            style: TextStyle(fontWeight: FontWeight.w400),
          ))
        : ListView.builder(
            shrinkWrap: true,
            itemBuilder: (ctx, index) {
              return Column(children: [
                ListTile(
                    onTap: () async {
                      print(widget.loc[index].location);
                      await _changeMapPosition(widget.loc[index].location);

                      providerobject.updateInfoWindow(
                          context,
                          widget.mapController,
                          widget.loc[index].location,
                          widthinfowindow,
                          marketofset);
                      providerobject.updateUser(widget.loc[index]);
                      providerobject.updateVisiblity(true);
                      providerobject.rebuildInfoWindow();
                      //
                    },
                    leading: ClipRRect(
                        child: widget.users[index]['profile_picture'] == null ||
                                widget.users[index]['profile_picture'] == ""
                            ? Image(
                                image: AssetImage("lib/asset/Person_icon.jpg"))
                            : FadeInImage.assetNetwork(
                                fit: BoxFit.cover,
                                height: 55,
                                width: 55,
                                imageErrorBuilder: (BuildContext context,
                                    Object exception, StackTrace stackTrace) {
                                  return Image(
                                      image: AssetImage(
                                          "lib/asset/Person_icon.jpg"));
                                },
                                image: widget.users[index]['profile_picture'],
                                placeholder:
                                    "lib/asset/Person_icon.jpg" // your assets image path
                                )),
                    title: Text(
                      widget.users[index]['user_name'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle:
                        Text("Hobbies- " + widget.users[index]["hobbies"])),
                Padding(
                    padding: EdgeInsets.only(left: 70),
                    child: Divider(
                      color: Colors.black45,
                      thickness: 1,
                    )),
              ]);
            },
            itemCount: widget.users.length,
          );
  }
}

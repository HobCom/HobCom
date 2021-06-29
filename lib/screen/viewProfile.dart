import 'dart:io';
import 'package:flutter/material.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:hobcom/Authentication/AuthHome.dart';
import 'package:hobcom/Model/Infowindow.dart';
import 'package:hobcom/Model/hobbies.dart';
import 'package:hobcom/Model/user.dart';
import 'package:hobcom/Utils/const..dart';
import 'package:hobcom/model/user.dart';
import 'package:hobcom/screen/AllFriendList.dart';
import 'package:hobcom/screen/updateProf.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hobcom/Utils/const..dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:photo_view/photo_view.dart';

import 'multipleImages.dart';
// class multipleImages with ChangeNotifier{}

class ViewProfile extends StatefulWidget {
  final String id;
  ViewProfile(this.id);
  @override
  _ViewProfileState createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  bool loading = false;
  bool dpLoading = true;
  var allFriendList = [];
  var flag;
  var responseJson;
  List<Hobbies> hobbiesList = [];
  List selectedHobbies = [];
  String name = "";
  String dob = "";
  String passion = "";
  String hometown = "";
  String dp;
  List<String> userImages = [];
  var numberOfImages = 0;
  String currrentUserid;
  getuid() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    currrentUserid = await sharedPreferences.get("userid");
    // print(currrentUserid);
  }

  Future<void> getHobbiesList() async {
    hobbiesList = [];
    String url = "http://hobcom.in/hobby_list.php";
    var url2 = Uri.parse(url);
    http.Response hobbiesResponse = await http.get(url2);
    var res = json.decode(hobbiesResponse.body);
    for (int i = 0; i < res.length; i++) {
      hobbiesList.add(Hobbies(id: res[i]['id'], name: res[i]['hobbyname']));
    }
  }

  Future<void> sendRequest(String senderID, String reciverID) async {
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

  String cover;
  getCoverPhoto() async {
    String url = "http://hobcom.in/get_coverImages.php";
    var url2 = Uri.parse(url);
    http.Response res = await http.post(url2,
        body: jsonEncode(<String, dynamic>{"user_id": widget.id}));
    var coverResponse = json.decode(res.body);
    if (coverResponse == null || coverResponse.length == 0) {
    } else {
      cover = coverResponse["cover_image"];
    }
    setState(() {});
  }

  Future<String> getDP() async {
    String url = "http://hobcom.in/getprofiledetails.php";
    var url2 = Uri.parse(url);
    http.Response response = await http.post(url2,
        body: jsonEncode(<String, dynamic>{"user_id": widget.id.toString()}));
    setState(() {
      dp = json.decode(response.body)["userdetails"]['profile_picture'];
      dpLoading = false;
    });
    return dp;
  }

  Future<void> getMultipleImages() async {
    String imgUrl = "http://hobcom.in/get_userimages.php";
    var imgurl2 = Uri.parse(imgUrl);
    http.Response uImages = await http.post(imgurl2,
        body: jsonEncode(<String, String>{
          "user_id": widget.id,
        }));
    var imageRes = json.decode(uImages.body);
    setState(() {
      print(imageRes);
      if (imageRes != null) {
        for (int i = 0; i < imageRes.length; i++) {
          userImages.add(imageRes[i]["image"]);
        }
        numberOfImages = imageRes.length;
      }
    });
  }

  var cityname;
  var selectedHobbiesName = "";
  Future<void> getProfile() async {
    String url = "http://hobcom.in/getprofiledetails.php";
    var url2 = Uri.parse(url);
    http.Response response = await http.post(url2,
        body: jsonEncode(<String, dynamic>{"user_id": widget.id.toString()}));
    if (response.body.isNotEmpty) {
      responseJson = json.decode(response.body);
      cityname = responseJson["userdetails"]["home_town"];
      selectedHobbies = [];
      int hobLen;
      if (responseJson['hobbies'] == 0) {
        hobLen = 0;
      } else {
        hobLen = responseJson['hobbies'].length;
      }
      selectedHobbiesName = "";
      for (int i = 0; i < hobLen; i++) {
        selectedHobbies.add(responseJson['hobbies'][i]['id']);

        if (i < 5) {
          selectedHobbiesName = selectedHobbiesName +
              responseJson['hobbies'][i]['hobbyname'] +
              (i < hobLen - 1 ? ",\n" : "");
        }
      }
      print(responseJson);
    }
    setState(() {
      dp = responseJson["userdetails"]['profile_picture'];
      name = responseJson["userdetails"]["UNAME"];
      flag = responseJson["userdetails"]["profile_flag"];
      dpLoading = false;
      dob = responseJson["userdetails"]["dob"];
      passion = responseJson["userdetails"]["passion"];
      hometown = responseJson["userdetails"]["home_town"];
    });
  }

  @override
  void didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    await getuid();
    name = "";
    dpLoading = true;
    // await getID();
    await getProfile();
    getCoverPhoto();
    print(2);
    await getMultipleImages();
    // await getHobbiesList();
    print(22);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    // hobcomUser= fetchUserInfo();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print(hobcomUser);
    final providerobject = Provider.of<Infowindow>(context, listen: false);
    var deviceheight = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(
          name,
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              })
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          if (loading)
            Center(
                child: Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: SpinKitFadingCube(
                      color: Colors.blueGrey,
                      size: 100,
                    ))),
          SingleChildScrollView(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 230.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: cover == null
                              ? AssetImage("lib/asset/addimage.png")
                              : NetworkImage(cover),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.5), BlendMode.darken),
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    Text(
                      name,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8),
                    RaisedButton(
                      onPressed: () {
                        print(providerobject.status);
                        if (providerobject.status == null ||
                            providerobject.status == "3") {
                          providerobject.updateRequestStatus("1");
                          setState(() {});
                          sendRequest(currrentUserid, widget.id);
                        }
                      },
                      child: Text(providerobject.status == null ||
                              providerobject.status == "3"
                          ? "Send Request"
                          : providerobject.status == "1"
                              ? "Request sent"
                              : "Friends"),
                      // color: Color.fromRGBO(57, 86, 156, 1),
                      color: providerobject.status == null ||
                              providerobject.status == "3"
                          ? Colors.blue[900]
                          : providerobject.status == "1"
                              ? Colors.white
                              : Colors.greenAccent[700],
                      textColor: providerobject.status == null ||
                              providerobject.status == "3"
                          ? Colors.white
                          : providerobject.status == "1"
                              ? Colors.black
                              : Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(
                              color: providerobject.status == "1"
                                  ? Colors.red
                                  : Colors.transparent)),
                    ),
                    // Text(
                    //   "Model",
                    //   style: TextStyle(
                    //     color: Colors.grey,
                    //     fontSize: 15,
                    //     fontWeight: FontWeight.w500,
                    //   ),
                    // ),
                    SizedBox(height: 15),
                    Divider(
                      thickness: 2,
                      color: Colors.grey.shade300,
                    ),
                    Row(
                      // mainrow
                      children: [
                        Row(
                          children: [
                            IconButton(
                                icon: Image(
                                  image: AssetImage(
                                    'images/icons/cake.png',
                                  ),
                                ),
                                onPressed: null),
                            Text(
                              dob,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        // 2
                        Row(
                          children: [
                            IconButton(
                                icon: Image(
                                  image: AssetImage(
                                    'images/icons/location.png',
                                  ),
                                ),
                                onPressed: null),
                            Text(
                              hometown,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        // 3
                        Row(
                          children: [
                            IconButton(
                                icon: Image(
                                  image: AssetImage(
                                    'images/icons/like.png',
                                  ),
                                ),
                                onPressed: null),
                            SizedBox(
                              width: 90,
                              child: Text(
                                selectedHobbiesName,
                                overflow: TextOverflow.ellipsis,
                                // softWrap: false,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // bio
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          "Biography",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        passion,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    GridView(
                      padding: EdgeInsets.all(5),
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      children: [
                        for (int i = 0; i < numberOfImages; i++)
                          InkWell(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return MultipleImages(userImages, i);
                              }));
                            },
                            child: Image.network(
                              userImages[i],
                              fit: BoxFit.cover,
                            ),
                          ),

                        // Image.network(
                        //   userImages[i]['image'],
                        //   fit: BoxFit.cover,
                        // )
                        // Image.asset('images/1.png'),
                        // Image.asset('images/2.png'),
                        // Image.asset('images/3.png'),
                        // Image.asset('images/4.png'),
                        // Image.asset('images/5.png'),
                        // Image.asset('images/6.png'),
                      ],
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 190,
                          childAspectRatio: 1,
                          crossAxisSpacing: 1,
                          mainAxisSpacing: 1),
                    ),
                  ],
                ),
                Positioned(
                    top: MediaQuery.of(context).size.height *
                        (150 / deviceheight),
                    child: dpLoading == true
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(70),
                            child: Image(
                                image: AssetImage(
                                  "lib/asset/dploading.gif",
                                ),
                                height: MediaQuery.of(context).size.height *
                                    (140 / deviceheight),
                                width: MediaQuery.of(context).size.height *
                                    (140 / deviceheight)))
                        : Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: flag == "2"
                                      ? kprimary
                                      : Colors.transparent,
                                  width: 3),
                              borderRadius: BorderRadius.circular(75),
                            ),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(70),
                                child: dp == null
                                    ? Image(
                                        image: AssetImage(
                                            "lib/asset/Person_icon.jpg"),
                                        height:
                                            MediaQuery.of(context).size.height *
                                                (140 / deviceheight),
                                        width:
                                            MediaQuery.of(context).size.height *
                                                (140 / deviceheight),
                                        fit: BoxFit.cover,
                                      )
                                    : FadeInImage.assetNetwork(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                (140 / deviceheight),
                                        width:
                                            MediaQuery.of(context).size.height *
                                                (140 / deviceheight),
                                        placeholder: "lib/asset/dploading.gif",
                                        image: dp,
                                        fit: BoxFit.fill,
                                      )),
                          )
                    // CircleAvatar(
                    //     radius: 70,
                    //     backgroundImage:
                    //     dp == null
                    //         ? AssetImage("lib/asset/addimage.png")
                    //         :{dpLoading==true?AssetImage("lib/asset/dploading.gif"):NetworkImage(dp)}
                    //         ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

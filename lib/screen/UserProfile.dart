import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:hobcom/Authentication/AuthHome.dart';
import 'package:hobcom/Model/hobbies.dart';
import 'package:hobcom/Model/user.dart';
import 'package:hobcom/Utils/const..dart';
import 'package:hobcom/model/user.dart';
import 'package:hobcom/screen/AllFriendList.dart';
import 'package:hobcom/screen/multipleImages.dart';
import 'package:hobcom/screen/updateProf.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hobcom/Utils/const..dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_viewer/image_viewer.dart';
import 'coverPicture.dart';
// class multipleImages with ChangeNotifier{}

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isProfileLoading = true;
  bool _isHobbiesLoading = true;
  String dob = "";
  String hometown = "";
  var hobbiesname = [];
  String career = "";
  String bio = "";
  getuserlocaldata() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    name = sharedPreferences.get("username");
    id = sharedPreferences.get("userid");
    dob = sharedPreferences.get("dob");
    career = sharedPreferences.get("career");
    hometown = sharedPreferences.get("usercity");
    bio = sharedPreferences.get("passion");
    if (bio == null) {
      bio = "";
    }
    setState(() {});
    // career = await sharedPreferences.get("dob");
    print(dob);
  }

  void showToast(String str) {
    Fluttertoast.showToast(
        msg: str,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black87,
        textColor: Colors.white);
  }

  String id;
  bool loading = false;
  bool dpLoading = true;
  var allFriendList = [];
  final _picker = ImagePicker();
  removeuserInfo() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove('userid');
    sharedPreferences.remove('username');
    await sharedPreferences.clear();
    print("logout");
    print("userRemoved");
  }

  Widget button(String text, PickedFile file) {
    return FlatButton(
        onPressed: () async {
          Navigator.of(context).pop();
          // ignore: deprecated_member_use
          text == "Choose from gallery"
              ? file = await _picker.getImage(source: ImageSource.gallery)
              : file = await _picker.getImage(source: ImageSource.camera);
          if (file != null) {
            File croppedFile = await ImageCropper.cropImage(
                sourcePath: file.path,
                aspectRatioPresets: [
                  CropAspectRatioPreset.square,
                  CropAspectRatioPreset.ratio3x2,
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.ratio4x3,
                  CropAspectRatioPreset.ratio16x9
                ],
                androidUiSettings: AndroidUiSettings(
                    toolbarTitle: 'Cropper',
                    toolbarColor: Colors.blueGrey,
                    toolbarWidgetColor: Colors.white,
                    initAspectRatio: CropAspectRatioPreset.original,
                    lockAspectRatio: false),
                iosUiSettings: IOSUiSettings(
                  minimumAspectRatio: 1.0,
                ));
            if (croppedFile != null) {
              setState(() {
                loading = true;
              });
              _upload(croppedFile).then((value) {
                setState(() {
                  loading = false;
                });
                Scaffold.of(context).showSnackBar(new SnackBar(
                  content: Text(
                    "Done!!",
                    style: TextStyle(fontSize: 16),
                  ),
                  backgroundColor: Colors.blueGrey,
                  duration: Duration(seconds: 2),
                ));
              });
            }
          }
        },
        child: Text(text));
  }

  // Widget buttoncover(String text, String image) {
  //   return FlatButton(
  //       onPressed: () async {
  //         Navigator.of(context).pop();
  //         // ignore: deprecated_member_use
  //         image = "cover";

  //         setState(() {});

  //         if (cover != null) {
  //           Navigator.push(context, MaterialPageRoute(builder: (_) {
  //             return CoverPicture(cover);
  //           }));
  //         }
  //       },
  //       child: Text(text));
  // }

  var responseJson;
  List<Hobbies> hobbiesList = [];
  List selectedHobbies = [];
  String name = "";
  String dp;
  List<String> userImages = [];
  int numberOfImages = 0;

  Future<void> getHobbiesList() async {
    hobbiesList = [];
    String url = "http://hobcom.in/hobby_list.php";
    var url2 = Uri.parse(url);
    http.Response hobbiesResponse = await http.get(url2);
    var res = json.decode(hobbiesResponse.body);
    for (int i = 0; i < res.length; i++) {
      hobbiesList.add(Hobbies(id: res[i]['id'], name: res[i]['hobbyname']));
    }
    _isHobbiesLoading = false;
  }

  String cover;
  getCoverPhoto() async {
    String url = "http://hobcom.in/get_coverImages.php";
    var url2 = Uri.parse(url);
    http.Response res = await http.post(url2,
        body: jsonEncode(<String, dynamic>{"user_id": id}));
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
        body: jsonEncode(<String, dynamic>{"user_id": id.toString()}));
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
          "user_id": id,
        }));
    var imageRes = json.decode(uImages.body);
    setState(() {
      print(imageRes);
      if (imageRes != null) {
        for (int i = 0; i < imageRes.length; i++) {
          userImages.add(imageRes[i]["image"]);
        }
        numberOfImages = imageRes.length;
        // userImages.addAll(imageRes["image"]);

        // userImages = imageRes;
      }
    });
  }

  var selectedHobbiesName = "";
  var cityname = "";
  var birthDate = "";
  var flag = "";
  var userbio = "";
  var usercareer = "";
  var username = "";

  Future<void> getProfile() async {
    String url = "http://hobcom.in/getprofiledetails.php";
    var url2 = Uri.parse(url);
    http.Response response = await http.post(url2,
        body: jsonEncode(<String, dynamic>{"user_id": id.toString()}));
    if (response.body.isNotEmpty) {
      responseJson = json.decode(response.body);

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
      // print(responseJson);
      // print(responseJson['userdetails']['profile_flag']);
      print(selectedHobbiesName);
    }
    setState(() {
      dp = responseJson["userdetails"]['profile_picture'];
      flag = responseJson["userdetails"]["profile_flag"];
      _isProfileLoading = false;
      dpLoading = false;
      usercareer = responseJson["userdetails"]["profession"];
      cityname = responseJson["userdetails"]["home_town"];
      birthDate = responseJson["userdetails"]["dob"];
      userbio = responseJson["userdetails"]["passion"];
      username = responseJson["userdetails"]["user_name"];
    });
  }

  final String phpEndPoint = 'http://hobcom.in/images_upload.php';
  Future<void> showDialog() async {
    PickedFile img;
    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      // barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 700),
      context: context,
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 120,
            width: 200,
            child: Column(
              children: <Widget>[
                button("Choose from gallery", img),
                // ignore: deprecated_member_use
                Divider(
                  color: Colors.black,
                ),
                button("Take a picture", img)
              ],
            ),
            margin: EdgeInsets.only(bottom: 300),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
    );
  }

  // cover dailog

  // Future<void> showDialogcover() async {
  //   File img;
  //   showGeneralDialog(
  //     barrierLabel: "Barrier",
  //     barrierDismissible: true,
  //     // barrierColor: Colors.black.withOpacity(0.5),
  //     transitionDuration: Duration(milliseconds: 700),
  //     context: context,
  //     pageBuilder: (_, __, ___) {
  //       return Align(
  //         alignment: Alignment.bottomCenter,
  //         child: Container(
  //           height: 120,
  //           width: 200,
  //           child: Column(
  //             children: <Widget>[
  //               buttoncover("View cover", image),
  //               // ignore: deprecated_member_use
  //               Divider(
  //                 color: Colors.black,
  //               ),
  //               button("Upload cover", img)
  //             ],
  //           ),
  //           margin: EdgeInsets.only(bottom: 300),
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  String image = "";
  Future _upload(File file) async {
    String url;
    if (image == "images") {
      url = phpEndPoint;
    } else if (image == "profilepic") {
      url = "http://hobcom.in/uploadprofile_pic.php";
      setState(() {
        dpLoading = true;
      });
    } else {
      url = "http://hobcom.in/CoverImage_upload.php";
    }
    if (file == null) {
      return null;
    }
    String base64Image = base64Encode(file.readAsBytesSync());
    var url2 = Uri.parse(url);
    await http
        .post(url2,
            body: jsonEncode(<String, dynamic>{
              "user_id": id.toString(),
              "images": base64Image,
            }))
        .then((res) async {
      print(res.statusCode);
      print(json.decode(res.body));
      if (image == "profilepic") {
        getDP();
      } else if (image == "images") {
        getMultipleImages();
      } else {
        getCoverPhoto();
      }
    }).catchError((err) {
      print(err);
    });
  }

  @override
  void didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    name = "";
    dpLoading = true;
    await getuserlocaldata();
    getHobbiesList();
    await getProfile();
    getMultipleImages();

    getCoverPhoto().then((value) {
      setState(() {});
    });

    super.didChangeDependencies();
  }

  @override
  void initState() {
    // hobcomUser= fetchUserInfo();
    getuserlocaldata();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print(hobcomUser);
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
              icon: Image(
                image: AssetImage(
                  'images/icons/settingicon.png',
                ),
              ),
              onPressed: () {
                _scaffoldKey.currentState.openEndDrawer();
              }),
        ],
      ),
      extendBodyBehindAppBar: true,
      endDrawer: Drawer(
        child: ListView(
          children: [
            Container(
              padding: EdgeInsets.only(left: 25, top: 40),
              child: Text(
                username,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(height: 10),

            Divider(
              thickness: 2,
              color: Colors.grey.shade300,
            ),

            // menu's end drawer
            Column(
              children: [
                // edit profile
                InkWell(
                  onTap: () {
                    !_isHobbiesLoading && !_isProfileLoading
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UpdateUserInfo(
                                    responseJson,
                                    hobbiesList,
                                    selectedHobbies)))
                        : showToast(" wait ");
                  },
                  child: Row(
                    children: [
                      // ignore: missing_required_param
                      IconButton(
                        icon: Image(
                          image: AssetImage(
                            'images/icons/editprofile.png',
                          ),
                        ),
                      ),
                      Text(
                        "Edit Profile",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),

                // auth level
                Row(
                  children: [
                    IconButton(
                      icon: Image(
                        image: AssetImage(
                          'images/icons/authlevel.png',
                        ),
                      ),
                      onPressed: null,
                    ),
                    InkWell(
                      onTap: () {
                        if (responseJson['userdetails']['profile_flag'] ==
                            "1") {
                          Navigator.pushNamed(context, './level2auth');
                        } else {
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.INFO,
                            animType: AnimType.BOTTOMSLIDE,
                            title: 'Hey',
                            desc: 'You are already level 2 authenticated',
                            btnCancelOnPress: () {},
                            btnOkOnPress: () {},
                          )..show();
                        }
                      },
                      child: Text(
                        "Authentication Level",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),

                SizedBox(
                  height: 10,
                ),
                // help

                Row(
                  children: [
                    IconButton(
                      icon: Image(
                        image: AssetImage(
                          'images/icons/help.png',
                        ),
                      ),
                      onPressed: null,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pushNamed('./help');
                      },
                      child: Text(
                        "Help",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                //logout

                Row(
                  children: [
                    IconButton(
                      icon: Image(
                        image: AssetImage(
                          'images/icons/logout.png',
                        ),
                      ),
                      onPressed: () async {
                        setState(() {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AuthHome()));
                        });
                        removeuserInfo();
                      },
                    ),
                    InkWell(
                      onTap: () async {
                        setState(() {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AuthHome()));
                        });
                        removeuserInfo();
                      },
                      child: Text(
                        "Logout",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
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
                    InkWell(
                      onLongPress: () {
                        // image = "cover";
                        // showDialog();
                        // setState(() {});
                      },
                      onTap: () {
                        if (cover != null) {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) {
                            return CoverPicture(cover);
                          }));
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 230.0,
                        decoration: BoxDecoration(),
                        child: Hero(
                            tag: "cover",
                            child: DecoratedBox(
                                decoration: BoxDecoration(
                              image: DecorationImage(
                                image: cover == null
                                    ? AssetImage("lib/asset/addimage.png")
                                    : NetworkImage(cover),
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                    Colors.black.withOpacity(0.5),
                                    BlendMode.darken),
                              ),
                            ))),
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
                    Text(
                      usercareer,

                      // career,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 15),
                    Divider(
                      thickness: 2,
                      color: Colors.grey.shade300,
                    ),
                    Row(
                      // mainrow
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                              birthDate,
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
                              cityname,
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
                          "Biography ",
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
                      child: Column(
                        children: [
                          Text(
                            userbio,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GridView(
                      padding: EdgeInsets.all(5),
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      children: [
                        InkWell(
                          onTap: () {
                            image = "images";
                            showDialog();
                            setState(() {});
                          },
                          child: Image.asset(
                            'images/addpost.png',
                            height: 25,
                            // fit: BoxFit.fitHeight,
                          ),
                        ),
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
                          )),
                Positioned(
                  top:
                      MediaQuery.of(context).size.height * (250 / deviceheight),
                  right: MediaQuery.of(context).size.width * (140 / 411),
                  child: CircleAvatar(
                    backgroundColor: Color(0xff16D324),
                    child: IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          image = "profilepic";
                          print(image);
                          showDialog();
                          setState(() {});
                        }),
                  ),
                ),

                // edit cover

                Positioned(
                  top:
                      MediaQuery.of(context).size.height * (140 / deviceheight),
                  right: MediaQuery.of(context).size.width * (30 / 411),
                  child: CircleAvatar(
                    backgroundColor: Color(0xff16D324),
                    child: IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          image = "cover";
                          showDialog();
                          setState(() {});
                          // showDialog();
                          // setState(() {});

                          // showDialogcover();
                        }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

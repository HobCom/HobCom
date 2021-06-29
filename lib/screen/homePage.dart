import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:math';
import 'dart:ui' as codec;
import 'dart:ui' as ui;
import 'package:android_intent/android_intent.dart';
import 'package:clippy_flutter/clippy_flutter.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hobcom/Model/MapUsers.dart';
import 'package:hobcom/screen/AllFriendList.dart';
import 'package:hobcom/screen/friend_requests.dart';
import 'package:hobcom/screen/related_user.dart';
import 'package:hobcom/screen/viewProfile.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Utils/const..dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_switch/flutter_switch.dart';
import './related_events.dart';
import 'package:hobcom/Model/Infowindow.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PermissionHandler permissionHandler = PermissionHandler();
  Map<PermissionGroup, PermissionStatus> permissions;
  void initState() {
    super.initState();
    requestLocationPermission();

    _gpsService();
  }

  Future<bool> _requestPermission(PermissionGroup permission) async {
    final PermissionHandler _permissionHandler = PermissionHandler();
    var result = await _permissionHandler.requestPermissions([permission]);
    if (result[permission] == PermissionStatus.granted) {
      return true;
    }
    return false;
  }

/*Checking if  App has been Given Permission*/
  Future<bool> requestLocationPermission({Function onPermissionDenied}) async {
    var granted = await _requestPermission(PermissionGroup.location);
    if (granted != true) {
      requestLocationPermission();
    }
    debugPrint('requestContactsPermission $granted');
    return granted;
  }

/*Show dialog if GPS not enabled and open settings location*/
  Future _checkGps() async {
    if (!(await Geolocator().isLocationServiceEnabled())) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Can't get gurrent location"),
                content:
                    const Text('Please make sure you enable GPS and try again'),
                actions: <Widget>[
                  FlatButton(
                      child: Text('Ok'),
                      onPressed: () {
                        final AndroidIntent intent = AndroidIntent(
                            action:
                                'android.settings.LOCATION_SOURCE_SETTINGS');
                        intent.launch();
                        Navigator.of(context, rootNavigator: true).pop();
                        _gpsService();
                      })
                ],
              );
            });
      }
    }
  }

/*Check if gps service is enabled or not*/
  Future _gpsService() async {
    if (!(await Geolocator().isLocationServiceEnabled())) {
      _checkGps();
      return null;
    } else
      return true;
  }

  var userlocation = "";
  Future getcurrentuserlocation() async {
    var position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    // print(position.latitude+ position.longitude);
    // setState(() {
    //   // userlocation = "${position.latitude} , ${position.longitude}";
    // });
    lat = position.toJson()["latitude"];
    long = position.toJson()["longitude"];
    print(position.toJson());
  }

  String currrentUserid = "";
  String city;
  File imgFile;
  var markerIcon;
  static Random random = new Random();
  int randomNum = random.nextInt(10);
  getuid() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    currrentUserid = await sharedPreferences.get("userid");
    imgFile = await DefaultCacheManager().getSingleFile(
        "https://miro.medium.com/max/1200/1*mk1-6aYaf_Bes1E3Imhc0A.jpeg");
    // print(currrentUserid);
  }

  var req;
  findReuestStatus(String id) {
    if (id != null) {
      var reqStat = users.where((element) => element["user_id"] == id).toList();
      req = reqStat[0]["request_status"];
    }
  }

  var _scaffoldKey = GlobalKey<ScaffoldState>();
  Future getId() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    print(sharedPreferences.getString("userid"));
    return sharedPreferences.getString("userid");
  }

  static var finalPos;
  static var currentPos = LatLng(28.613939, 77.209023);
  static var lat = 28.613939;
  static var long = 77.209023;
  Future getCity() async {
    String url = "http://hobcom.in/updatelivelocation.php";
    var url2 = Uri.parse(url);

    final coordinates = new Coordinates(lat, long);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    city = first.toMap()["subAdminArea"];
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("currentcity", city);
    await http.post(url2,
        body: jsonEncode(<String, dynamic>{
          "user_id": currrentUserid,
          "latitude": lat,
          "longitude": long,
          "city": city
        }));
    setState(() {
      finalPos = LatLng(lat, long);
      print(lat);
      print(long);
    });
  }

  var customicon;
  Future mapIcon({String url}) async {
    final int targetWidth = 160;
    final File markerImageFile = await DefaultCacheManager().getSingleFile(url);
    final Uint8List markerImageBytes = await markerImageFile.readAsBytes();
    final codec.Codec markerImageCodec = await instantiateImageCodec(
        markerImageBytes,
        targetWidth: targetWidth,
        targetHeight: targetWidth);
    final FrameInfo frameInfo = await markerImageCodec.getNextFrame();
    final ByteData byteData = await frameInfo.image.toByteData(
      format: ImageByteFormat.png,
    );
    final Uint8List resizedMarkerImageBytes = byteData.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(resizedMarkerImageBytes);
  }

  static Future<BitmapDescriptor> convertImageFileToBitmapDescriptor(String url,
      {int size = 150,
      bool addBorder = true,
      Color borderColor = Colors.yellow,
      double borderSize = 10,
      Color titleColor = Colors.transparent,
      Color titleBackgroundColor = Colors.transparent}) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()
      ..strokeWidth = 12.5
      ..style = PaintingStyle.stroke
      ..color = kprimary;
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    final double radius = size / 2;
    final Offset center = new Offset(size.toDouble() / 2, size.toDouble() / 2);
    // final RRect borderRect = borderRadius.resolve(textDirection).toRRect(rect);

    //make canvas clip path to prevent image drawing over the circle
    final Path clipPath = Path();
    final path = Path();
    path.addOval(Rect.fromCircle(
      center: center,
      radius: 75.0,
    ));

    clipPath.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size / 1, size / 1), Radius.circular(130)));
    // clipPath.addRRect(RRect.fromRectAndRadius(
    //     Rect.fromLTWH(200 / 2.toDouble(), size + 20.toDouble(), 10, 10),
    //     Radius.circular(200)));
    canvas.drawPath(path, paint);
    // canvas.drawCircle(center, radius, paint);
// canvas.drawArc(Rect.fromCircle(radius:size.toDouble()/2, center: center), -2*pi, 2*pi, false, paint);

    canvas.clipPath(clipPath);

    //paintImage
    final File imageFile = await DefaultCacheManager().getSingleFile(url);

    final Uint8List imageUint8List = await imageFile.readAsBytes();
    final ui.Codec codec = await ui.instantiateImageCodec(imageUint8List);
    final ui.FrameInfo imageFI = await codec.getNextFrame();
    paintImage(
        fit: BoxFit.cover,
        canvas: canvas,
        rect: Rect.fromLTWH(6, 6, 140.toDouble(), 140.toDouble()),
        image: imageFI.image);
    //convert canvas as PNG bytes
    final _image = await pictureRecorder
        .endRecording()
        .toImage((size).toInt(), (size).toInt());
    final data = await _image.toByteData(format: ui.ImageByteFormat.png);

    //convert PNG bytes as BitmapDescriptor
    return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
  }

  Future<void> _changeMapPosition(LatLng pos) async {
    final CameraPosition finalPosition =
        CameraPosition(target: pos, zoom: 12.5);
    mapController = await googleMapController.future;
    mapController.animateCamera(CameraUpdate.newCameraPosition(finalPosition));
  }

  Completer<GoogleMapController> googleMapController = Completer();
  // List<Marker> markerlist = [];
  bool _isLoading = false;
  var users = [];
  var userHobbies = [];
  bool _isSwitched = false;
  List icon = [];
  getIcons() async {
    for (int i = 0; i < users.length; i++) {
      // var res = await mapIcon(
      //     url: users[i]["profile_picture"] != null
      //         ? users[i]["profile_picture"]
      //         : "https://cdn.business2community.com/wp-content/uploads/2017/08/blank-profile-picture-973460_640.png");
      // icon.add(res);
      var res = await convertImageFileToBitmapDescriptor(users[i]
                  ["profile_picture"] !=
              null
          ? users[i]["profile_picture"]
          : "https://cdn.business2community.com/wp-content/uploads/2017/08/blank-profile-picture-973460_640.png");
      icon.add(res);
    }
  }

  final List<MapUsers> _userslist = [];
  Future<void> getUsers(String id) async {
    String url = "http://hobcom.in/getrelateduserhobbiesfrnds.php";
    var url2 = Uri.parse(url);
    http.Response response = await http.post(url2,
        body: jsonEncode(<String, dynamic>{"user_id": id, "city": city}));
    if (response.body.isNotEmpty) {
      print(json.decode(response.body));
      users = json.decode(response.body);
    }
  }

  @override
  void didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    // await mapIcon();
    _isLoading = true;
    await getuid();
    await getcurrentuserlocation().then(
        (value) => getCity().then((value) => _changeMapPosition(finalPos)));
    await getUsers(currrentUserid);
    setState(() {
      _isLoading = false;
    });
    await getIcons();
    for (int i = 0; i < users.length; i++) {
      _userslist.add(MapUsers(
          uid: users[i]["user_id"],
          username: users[i]['user_name'],
          mapImage: icon[i],
          profilepic: users[i]["profile_picture"],
          location: LatLng(double.parse(users[i]["lattitude"]),
              double.parse(users[i]["longitude"]))));
    }
    setState(() {});
  }

  final double widthinfowindow = 250;
  final double marketofset = 170;
  GoogleMapController mapController;

  Set<Marker> _markers = Set<Marker>();
  Set<Marker> _eventMarkers = Set<Marker>();
  @override
  Widget build(BuildContext context) {
    final providerobject = Provider.of<Infowindow>(context, listen: false);
    // _userslist.forEach((key, value) {
    for (int i = 0; i < _userslist.length; i++) {
      _markers.add(Marker(
          icon: icon[i],
          onDragEnd: (position) {},
          markerId: MarkerId(_userslist[i].uid),
          position: _userslist[i].location,
          onTap: () {
            providerobject.updateInfoWindow(context, mapController,
                _userslist[i].location, widthinfowindow, marketofset);
            providerobject.updateUser(_userslist[i]);
            providerobject.updateVisiblity(true);
            providerobject.rebuildInfoWindow();
          }));
    }

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        drawer: new Drawer(
          child: new ListView(
            children: [
              Container(
                  color: kprimary,
                  child: Image(image: AssetImage('images/logo.png'))),
              Divider(
                color: Colors.grey,
              ),
              ListTile(
                title: Center(
                  child: Text('Friend Requests',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return FriendRequests();
                  }));
                },
              ),
              Divider(
                color: Colors.grey,
              ),
              ListTile(
                title: Center(
                  child: Text('Friends',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return AllFriendList();
                  }));
                },
              ),
              Divider(
                color: Colors.grey,
              )
            ],
          ),
        ),
        body: Stack(children: [
          Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.45,
                width: MediaQuery.of(context).size.width * 1.0,
                decoration: BoxDecoration(),
                child: Consumer<Infowindow>(
                  builder: (context, model, child) {
                    return Stack(
                      children: [
                        child,
                        Positioned(
                            top: -50,
                            // bottom: 30,
                            left: 0,
                            child: Visibility(
                                visible: providerobject.showinfoWindow,
                                child: (providerobject.user == null ||
                                        !providerobject.showinfoWindow)
                                    ? Container()
                                    : Container(
                                        margin: EdgeInsets.only(
                                          left: providerobject.leftMargin,
                                          top: providerobject.topMargin,
                                        ),
                                        child: Column(
                                          children: [
                                            Container(
                                              height: 115,
                                              width: 250,
                                              padding: EdgeInsets.all(15),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  gradient: LinearGradient(
                                                      colors: [
                                                        Colors.white,
                                                        Color(0xfffceef5)
                                                      ],
                                                      end: Alignment
                                                          .bottomCenter,
                                                      begin:
                                                          Alignment.topCenter),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors.grey,
                                                        offset: Offset(
                                                          0.0,
                                                          1.0,
                                                        ),
                                                        blurRadius: 6)
                                                  ]),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    height: 75,
                                                    width: 75,
                                                    child: providerobject.user
                                                                .profilepic !=
                                                            null
                                                        ? Image.network(
                                                            providerobject.user
                                                                .profilepic,
                                                            fit: BoxFit.cover)
                                                        : Image.asset(
                                                            "lib/asset/Person_icon.jpg",
                                                            fit: BoxFit.cover,
                                                          ),
                                                  ),
                                                  // Image.asset(
                                                  //     providerobject.user.image,
                                                  //     height: 75),
                                                  SizedBox(
                                                    width: 15,
                                                  ),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                          providerobject
                                                              .user.username,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700)),
                                                      FlatButton(
                                                          color: kprimary,
                                                          onPressed: () {
                                                            findReuestStatus(
                                                                providerobject
                                                                    .user.uid);
                                                            providerobject
                                                                .updateRequestStatus(
                                                                    req);
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) {
                                                              return ViewProfile(
                                                                  providerobject
                                                                      .user
                                                                      .uid);
                                                            })).then((value) =>
                                                                getUsers(
                                                                    currrentUserid));
                                                          },
                                                          child: Text(
                                                            "View Profile",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ))
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                            Triangle.isosceles(
                                              edge: Edge.BOTTOM,
                                              child: Container(
                                                color: Colors.white70,
                                                width: 20,
                                                height: 15,
                                              ),
                                            )
                                          ],
                                        ),
                                      )))
                      ],
                    );
                  },
                  child: Positioned(
                    child: GoogleMap(
                      mapToolbarEnabled: false,
                      myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                      padding: EdgeInsets.only(
                        top: 200.0,
                      ),
                      onTap: (position) {
                        if (providerobject.showinfoWindow) {
                          providerobject.updateVisiblity(false);
                          providerobject.rebuildInfoWindow();
                        }
                      },
                      onCameraMove: (position) {
                        if (providerobject.user == null) {
                          providerobject.updateInfoWindow(
                              context,
                              mapController,
                              providerobject.user.location,
                              widthinfowindow,
                              marketofset);

                          providerobject.rebuildInfoWindow();
                        }
                        providerobject.updateVisiblity(false);
                      },
                      markers: _isSwitched ? _eventMarkers : _markers,
                      initialCameraPosition:
                          CameraPosition(target: currentPos, zoom: 6),
                      mapType: MapType.normal,
                      onMapCreated: (controller) {
                        setState(() {
                          googleMapController.complete(controller);
                          mapController = controller;
                        });
                      },
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: _isSwitched
                        ? Text(
                            "Near By Event",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          )
                        : Text(
                            "Near By People",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                  )),
              // SizedBox(height:5),
              _isLoading
                  ? Container(child: Center(child: CircularProgressIndicator()))
                  : Expanded(
                      child: _isSwitched
                          ? RelatedEvents()
                          : RelatedUsers(
                              users,
                              // userHobbies,
                              _userslist,
                              mapController,
                              googleMapController,
                              currrentUserid))
            ],
          ),
          Positioned(
            left: 10,
            top: 20,
            child: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () => _scaffoldKey.currentState.openDrawer(),
            ),
          ),
          Positioned(
              top: 20,
              right: 10,
              child: FlutterSwitch(
                value: _isSwitched,
                onToggle: (value) {
                  setState(() {
                    providerobject.updateVisiblity(false);
                    _isSwitched = value;
                  });
                },
                height: 30,
                width: 55,
                activeColor: Colors.white,
                activeToggleColor: Colors.greenAccent[400],
                inactiveColor: Colors.white,
                inactiveToggleColor: kprimary,
              ))
        ]),
      ),
    );
  }
}

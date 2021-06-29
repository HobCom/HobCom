import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:hobcom/Utils/const..dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Level2AuthScreen extends StatefulWidget {
  @override
  _Level2AuthScreenState createState() => _Level2AuthScreenState();
}

class _Level2AuthScreenState extends State<Level2AuthScreen> {
  String id;
  getId() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    id = sharedPreferences.getString("userid");
  }

  String uploadedPic;
  checkStatus() async {
    String url = "http://hobcom.in/get_Level2AuthenticationDetails.php";
    var url2 = Uri.parse(url);
    http.Response res = await http.post(url2,
        body: jsonEncode(<String, dynamic>{"user_id": id}));
    var flagRes = json.decode(res.body);
    if (flagRes.length != 0) {
      uploadedPic = flagRes["image"];
    }
  }

  File croppedFile;
  static Random rng = new Random();
  int code = rng.nextInt(9000) + 1000;
  bool loading = false;
  bool _isUploading = false;
  bool _isFlagLoading = true;
  final _picker = ImagePicker();
  Future button() async {
    PickedFile file = await _picker.getImage(
        source: ImageSource.camera, preferredCameraDevice: CameraDevice.front);
    if (file != null) {
      croppedFile = await ImageCropper.cropImage(
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
  }

  Future _upload(File file) async {
    setState(() {
      _isUploading = true;
    });
    String url = "http://hobcom.in/level2_authentication.php";
    var url2 = Uri.parse(url);

    if (file == null) {
      return null;
    }
    String base64Image = base64Encode(file.readAsBytesSync());
    await http
        .post(url2,
            body: jsonEncode(<String, dynamic>{
              "user_id": id.toString(),
              "code": code,
              "images": base64Image,
            }))
        .then((res) async {
      print(res.statusCode);
      print(json.decode(res.body));
      if (res.statusCode == 200) {
        setState(() {
          _isUploading = false;
        });
      }
    }).catchError((err) {
      print(err);
    });
  }

  @override
  void didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    await getId();
    checkStatus().then((_) {
      setState(() {
        _isFlagLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Level 2 Authenticaton"),
        centerTitle: true,
      ),
      body: _isFlagLoading
          ? Center(
              child: CircularProgressIndicator(
              backgroundColor: kprimary,
            ))
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  //  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    Container(
                      margin: EdgeInsets.all(25),
                      height: 130,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('images/twostepauth.png'))),
                    ),
                    SizedBox(
                      height: 15,
                    ),

                    //
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          //  getting here genrated otp by authlevel 2 api call & print on screen for user
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text('Your OTP',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: Text(code.toString(),
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    textAlign: TextAlign.center),
                              ),
                              Column(
                                children: [
                                  croppedFile == null && uploadedPic == null
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              right: 30.0),
                                          child: IconButton(
                                            hoverColor: kprimary,
                                            focusColor: kprimary,
                                            splashColor: kprimary,
                                            highlightColor: kprimary,
                                            icon: Icon(Icons.camera_alt,
                                                size: 82, color: Colors.black),
                                            onPressed: () {
                                              button();
                                            },
                                            padding: EdgeInsets.all(0.0),
                                            iconSize: 52,
                                          ),
                                        )
                                      : croppedFile != null
                                          ? Container(
                                              height: 100,
                                              width: 100,
                                              child: Image.file(
                                                croppedFile,
                                                fit: BoxFit.cover,
                                              ))
                                          : Container(
                                              height: 100,
                                              width: 100,
                                              child: FadeInImage.assetNetwork(
                                                  placeholder:
                                                      "lib/asset/dploading.gif",
                                                  image: uploadedPic)),
                                  SizedBox(height: 5),
                                  if (croppedFile != null ||
                                      uploadedPic != null)
                                    Center(
                                        child: FlatButton(
                                            onPressed: () => button(),
                                            child: Text("Retake",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14)),
                                            color: Colors.blue[700],
                                            height: 25))
                                ],
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Text(
                            "Step 1:",
                            textAlign: TextAlign.center,
                            style: new TextStyle(
                                fontSize: 22.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 5),
                          child: Text(
                            "Write OTP on paper",
                            textAlign: TextAlign.center,
                            style: new TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Text(
                            "Step 2:",
                            textAlign: TextAlign.center,
                            style: new TextStyle(
                                fontSize: 22.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 5),
                          child: Text(
                            "Hold the paper and click a selfie",
                            textAlign: TextAlign.center,
                            style: new TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 55,
                    ),

                    // Center(
                    //   child: Padding(
                    //     padding: const EdgeInsets.only(left: 11.0, bottom: 25),
                    //     child: SizedBox(
                    //       height: 45,
                    //       width: 300,
                    //       child: RaisedButton(
                    //           shape: RoundedRectangleBorder(
                    //             borderRadius: BorderRadius.circular(18.0),
                    //           ),
                    //           onPressed: () async {
                    //             Navigator.of(context).pushNamed('./tab');
                    //           },
                    //           color: kprimary,
                    //           textColor: Colors.black,
                    //           child: Text(
                    //             " Skip this step",
                    //             style: TextStyle(fontSize: 16, color: Colors.white),
                    //           )),
                    //     ),
                    //   ),
                    // ),

                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 11.0, bottom: 25),
                        child: SizedBox(
                            height: 45,
                            width: 200,
                            child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                                onPressed: () async {
                                  Navigator.of(context)
                                      .pushReplacementNamed('./tab');
                                },
                                color: kprimary,
                                textColor: Colors.black,
                                child: _isUploading
                                    ? Center(
                                        child: CircularProgressIndicator(
                                        backgroundColor: Colors.black,
                                      ))
                                    : Text(
                                        "Go to home ",
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.white),
                                      ))),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

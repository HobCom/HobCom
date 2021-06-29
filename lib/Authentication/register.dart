import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hobcom/Authentication/Forgotpass.dart';
import 'package:hobcom/Authentication/Login.dart';
import 'package:hobcom/Utils/const..dart';
import 'package:hobcom/screen/WelcomeScreens/OtpScreen.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  final TabController tabController;
  RegisterScreen(this.tabController);
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController _textEditConName = TextEditingController();
  TextEditingController _textEditConEmail = TextEditingController();
  TextEditingController _textEditConPassword = TextEditingController();
  TextEditingController _textEditConConfirmPassword = TextEditingController();
  TextEditingController _textEditConMobile = TextEditingController();
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  int mobile;
  // User user;

  Future<void> sendOTPtoUsermobile(String resotp, String mobile) async {
    String url =
        "http://www.alots.in/sms-panel/api/http/index.php?username=Hobcom&apikey=594EA-0E7D5&apirequest=Template&sender=HOBCOM&mobile=$mobile&TemplateID=321&Values=$resotp&route=OTP&format=JSON";
    var url2 = Uri.parse(url);
    http.Response response = await http.get(
      url2,
    );

    var responseJson = json.decode(response.body);
    if (response.statusCode == 200 && responseJson['status'] == "success") {
      print(responseJson);

      print("otp sent succesfully");
    } else {
      return null;
    }
  }

  static var formkey = GlobalKey<FormState>();
  bool showSpinner = false;
  final FocusNode _passwordEmail = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _passwordConfirmFocus = FocusNode();
  bool validateAndSave() {
    final form = formkey.currentState;

    if (form.validate()) {
      return true;
    } else {
      return false;
    }
  }

  addUserprofile(String user_id) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final String addprofAPI = "http://hobcom.in/add_profile.php";
    var addProfAPI = Uri.parse(addprofAPI);
    http.Response response = await http.post(addProfAPI,
        body: jsonEncode(<String, dynamic>{
          "user_id": user_id,
          "user_name": _textEditConName.text.trim(),
          "home_town": "",
          "hobbies": [],
          "passion": "",
          "dob": "",
          "profession": ""
        }));
    String responseString = response.body;
    var responseJson = json.decode(response.body);
    if (response.statusCode == 200 && responseJson['status'] == "success") {
      print(responseJson);
      print("userprofile Added success");
      // return userFromJson(responseString);
    } else {
      return null;
    }
  }

// http://api.positionstack.com/v1/forward?access_key=f3e335fd344f2dc73b5e7c97ab9fb858&query=Delhi
  @override
  void initState() {
    isPasswordVisible = false;
    isConfirmPasswordVisible = false;

    super.initState();
  }

  String validateMobile(String value) {
    if (value.length != 10)
      return 'Mobile Number must be of 10 digit';
    else
      return null;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Form(
                  key: formkey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        child: TextFormField(
                            controller: _textEditConName,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (String value) {
                              FocusScope.of(context)
                                  .requestFocus(_passwordEmail);
                            },
                            decoration: InputDecoration(
                              labelText: ' Username',
                              //prefixIcon: Icon(Icons.email),
                              icon: Icon(Icons.person),
                            )),
                      ), //text field : user name
                      Container(
                        child: TextFormField(
                          controller: _textEditConEmail,
                          focusNode: _passwordEmail,
                          validator: (emailid) {
                            return RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(emailid)
                                ? null
                                : "Please provide a valid email Id ";
                          },
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (String value) {
                            FocusScope.of(context).requestFocus(_passwordFocus);
                          },
                          decoration: InputDecoration(
                              labelText: 'Email',
                              //prefixIcon: Icon(Icons.email),
                              icon: Icon(Icons.email)),
                        ),
                      ), //text field: email
                      Container(
                        child: TextFormField(
                          validator: (password) {
                            return password.isEmpty || password.length < 6
                                ? "password must be 6 or more characters"
                                : null;
                          },
                          controller: _textEditConPassword,
                          focusNode: _passwordFocus,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (String value) {
                            FocusScope.of(context)
                                .requestFocus(_passwordConfirmFocus);
                          },
                          obscureText: !isPasswordVisible,
                          decoration: InputDecoration(
                              labelText: 'Password',
                              suffixIcon: IconButton(
                                icon: Icon(isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                onPressed: () {
                                  setState(() {
                                    isPasswordVisible = !isPasswordVisible;
                                  });
                                },
                              ),
                              icon: Icon(Icons.vpn_key)),
                        ),
                      ), //text field: password
                      Container(
                        child: TextFormField(
                            controller: _textEditConConfirmPassword,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.done,
                            obscureText: !isConfirmPasswordVisible,
                            validator: (confirmPassword) {
                              return confirmPassword !=
                                      _textEditConPassword.text
                                  ? "password is not same"
                                  : null;
                            },
                            decoration: InputDecoration(
                                labelText: 'Confirm Password',
                                suffixIcon: IconButton(
                                  icon: Icon(isConfirmPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                  onPressed: () {
                                    setState(() {
                                      isConfirmPasswordVisible =
                                          !isConfirmPasswordVisible;
                                    });
                                  },
                                ),
                                icon: Icon(Icons.vpn_key))),
                      ),

                      Container(
                          child: TextFormField(
                        validator: validateMobile,
                        controller: _textEditConMobile,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        obscureText: false,
                        decoration: InputDecoration(
                          labelText: 'Mobile No',
                          icon: Icon(Icons.phone_android),
                        ),
                      )),
                      SizedBox(
                        height: 35,
                      ),
                      SizedBox(
                        height: 45,
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                          onPressed: () async {
                            if (validateAndSave()) {
                              setState(() {
                                showSpinner = true;
                              });
                              try {
                                var responseJson;
                                final url = "http://hobcom.in/registration.php";
                                var url2 = Uri.parse(url);
                                final http.Response response =
                                    await http.post(url2,
                                        body: jsonEncode(<String, dynamic>{
                                          "user_name": _textEditConName.text,
                                          "email": _textEditConEmail.text,
                                          "password": _textEditConPassword.text,
                                          "mobileno": _textEditConMobile.text
                                        }));
                                responseJson = json.decode(response.body);

                                if (response.statusCode == 200 &&
                                    responseJson['status'] == "success") {
                                  final snackbar = SnackBar(
                                      content: Text("Registration done!"));
                                  Scaffold.of(context).showSnackBar(snackbar);
                                  sendOTPtoUsermobile(
                                          responseJson['Otp'].toString(),
                                          _textEditConMobile.text)
                                      .whenComplete(() => Navigator.of(context)
                                          .pushReplacement(MaterialPageRoute(
                                              builder: (_) => Otp(
                                                    userid:
                                                        responseJson['Userid']
                                                            .toString(),
                                                    username: _textEditConName
                                                        .text
                                                        .trim(),
                                                    usermobile:
                                                        _textEditConMobile.text
                                                            .trim(),
                                                    genratedOTP:
                                                        responseJson['Otp']
                                                            .toString(),
                                                  ))));

                                  addUserprofile(
                                      responseJson['Userid'].toString());
                                } else if (responseJson['status'] ==
                                    "failure") {
                                  final snackbar = SnackBar(
                                      content: Text("Error Occured!! " +
                                          responseJson['message'].toString()));
                                  Scaffold.of(context).showSnackBar(snackbar);
                                }
                                setState(() {
                                  showSpinner = false;
                                });
                                print(responseJson);
                              } catch (error) {
                                print(error);
                              }
                            }
                          },
                          color: kprimary,
                          textColor: Colors.black,
                          child: showSpinner
                              ? Center(child: CircularProgressIndicator())
                              : Text("Register",
                                  style: TextStyle(fontSize: 20)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an Account ?',
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  widget.tabController.index = 0;
                                });
                              },
                              child: Text(
                                'Login',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => ForgotPass())),
                        child: Container(
                          padding: EdgeInsets.all(15),
                          child: Center(
                              child: Text(
                            "Forgot Password ? ",
                            style: TextStyle(fontWeight: FontWeight.w700),
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

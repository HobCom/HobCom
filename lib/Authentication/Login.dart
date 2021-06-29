import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hobcom/Authentication/Forgotpass.dart';
import 'package:hobcom/main.dart';
import 'package:hobcom/Authentication/register.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Utils/const..dart';

class LoginScreen extends StatefulWidget {
  final TabController tabController;
  LoginScreen(this.tabController);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static var formkey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _textEditConEmail = TextEditingController();
  TextEditingController _textEditConPassword = TextEditingController();
  bool isPasswordVisible = false;
  String url = "http://hobcom.in/login.php";
  final FocusNode _passwordEmail = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _passwordConfirmFocus = FocusNode();

  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  bool showspinner = false;

  @override
  void initState() {
    isPasswordVisible = false;
    // loginRequestModel = new LoginRequestModel();
    super.initState();
  }

  bool validateAndSave() {
    final form = formkey.currentState;
    if (form.validate()) {
      return true;
    } else {
      return false;
    }
  }

  saveUserLogin(String id, String username, String profileFlag) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("userid", id);
    sharedPreferences.setString("username", username);
    sharedPreferences.setString("profileflag", profileFlag);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              DefaultTabController(
                length: 2,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Form(
                    key: formkey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                              FocusScope.of(context)
                                  .requestFocus(_passwordFocus);
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
                                  showspinner = true;
                                });

                                try {
                                  var responseJson;
                                  var url2 = Uri.parse(url);
                                  final http.Response response =
                                      await http.post(url2,
                                          body: jsonEncode(<String, dynamic>{
                                            'email': _textEditConEmail.text,
                                            'password':
                                                _textEditConPassword.text
                                          }));
                                  responseJson = json.decode(response.body);
                                  setState(() {
                                    showspinner = false;
                                  });
                                  if (response.statusCode == 200 &&
                                      responseJson['status'] == "success") {
                                    // Navigator.of(context).pushReplacementNamed('./tab');

                                    String userflag =
                                        responseJson['profileflag'];
                                    switch (userflag) {
                                      case "0":
                                        Navigator.of(context)
                                            .pushReplacementNamed("/otpScreen");
                                        break;

                                      case "1":
                                        Navigator.of(context)
                                            .pushReplacementNamed(
                                                './level2auth');
                                        break;

                                      case "2":
                                        Navigator.of(context)
                                            .pushReplacementNamed('./tab');
                                        break;

                                      default:
                                        Navigator.of(context)
                                            .pushReplacementNamed(
                                                './level2auth');
                                    }
                                    saveUserLogin(
                                        responseJson['Userid'],
                                        responseJson['username'],
                                        responseJson['profileflag']);
                                  } else {
                                    final snackbar = SnackBar(
                                        content: Text("Error Occured!!"));
                                    Scaffold.of(context).showSnackBar(snackbar);
                                  }
                                  print(responseJson);
                                  print(response.statusCode);
                                } catch (error) {
                                  print(error);
                                }
                              }
                            },
                            color: kprimary,
                            textColor: Colors.black,
                            child: showspinner
                                ? Center(
                                    child: CircularProgressIndicator(
                                    backgroundColor: Colors.white,
                                  ))
                                : Text("Login", style: TextStyle(fontSize: 20)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Dont have an Account ",
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
                                    widget.tabController.index = 1;
                                  });
                                },
                                child: Text(
                                  'Register',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
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

                        // ForgotPass(),
                      ],
                    ),
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

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hobcom/Authentication/AuthHome.dart';
import 'package:hobcom/Utils/const..dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPass extends StatefulWidget {
  @override
  _ForgotPassState createState() => _ForgotPassState();
}

class _ForgotPassState extends State<ForgotPass> {
  Future<void> sendResetPasstoUsermobile(
      String resetpass, String mobile) async {
    String url =
        "http://www.alots.in/sms-panel/api/http/index.php?username=Hobcom&apikey=594EA-0E7D5&apirequest=Template&sender=HOBCOM&mobile=$mobile&TemplateID=321&Values=$resetpass&route=OTP&format=JSON";
    var url2 = Uri.parse(url);
    http.Response response = await http.get(
      url2,
    );

    var responseJson = json.decode(response.body);
    if (response.statusCode == 200 && responseJson['status'] == "success") {
      print(responseJson);

      print("reset pass sent succesfully");
    } else {
      return null;
    }
  }

  var responseJson;
  Future<void> resetUserPass() async {
    final String forgotpassAPI = "http://hobcom.in/Get_forgot_pass_OTP.php";
    var forgotPassApiUrl = Uri.parse(forgotpassAPI);
    http.Response response = await http.post(forgotPassApiUrl,
        body: jsonEncode(<String, dynamic>{
          "user_id": _textEditConMobile.text.trim(),
        }));

    responseJson = json.decode(response.body);
    if (response.statusCode == 200 && responseJson['status'] == "success") {
      print(responseJson);
      print("reset passoword success");
      AwesomeDialog(
        context: context,
        dialogType: DialogType.INFO,
        animType: AnimType.BOTTOMSLIDE,
        title: responseJson["status"].toString(),
        desc:
            'Your new password is being sent to your mobile\n You can login with your new password',
        btnCancelOnPress: () {},
        btnOkOnPress: () {
          Navigator.pop(context);
        },
      )..show();

      sendResetPasstoUsermobile(
          responseJson["tempPass"].toString(), _textEditConMobile.text.trim());
    } else if (responseJson['status'] == "Error") {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.ERROR,
        animType: AnimType.BOTTOMSLIDE,
        title: 'Something went wrong',
        desc: 'Mobile no not registered with any account',
        btnCancelOnPress: () {},
        btnOkOnPress: () {
          Navigator.pop(context);
        },
      )..show();
    } else {
      return null;
    }
  }

  TextEditingController _textEditConMobile = TextEditingController();
  static var formkey = GlobalKey<FormState>();

  bool validateAndSave() {
    final form = formkey.currentState;

    if (form.validate()) {
      return true;
    } else {
      return false;
    }
  }

  String validateMobile(String value) {
    if (value.length != 10)
      return 'Mobile Number must be of 10 digit';
    else
      return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reset your password"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formkey,
          child: Column(
            children: [
              SizedBox(
                height: 50,
              ),
              Container(
                  padding: EdgeInsets.all(25),
                  child: Image.asset(
                    'images/forgotpass.png',
                  )),
              Text("Enter your mobile to reset password"),
              Container(
                  margin: EdgeInsets.all(25),
                  child: TextFormField(
                    validator: validateMobile,
                    controller: _textEditConMobile,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    obscureText: false,
                    decoration: InputDecoration(
                      labelText: 'Enter your Mobile No',
                      icon: Icon(Icons.phone_android),
                    ),
                  )),
              SizedBox(
                width: 180,
                height: 50,
                child: RaisedButton(
                    child: Text(
                      "Send Otp",
                      style: TextStyle(color: Colors.white),
                    ),
                    color: kprimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    onPressed: () {
                      if (validateAndSave()) {
                        try {
                          resetUserPass();
                        } catch (e) {
                          print(e.toString());
                        }
                      }
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}

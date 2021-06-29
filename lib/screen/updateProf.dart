import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
// import 'package:dropdown_search/dropdown_search.dart';
import 'package:dropdownfield/dropdownfield.dart';
import 'package:flutter/material.dart';
import 'package:hobcom/Model/hobbies.dart';
import 'package:hobcom/Utils/const..dart';
// import 'package:hobcom/screen/UserProfile.dart';
// import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:http/http.dart' as http;
import '../Model/cities.dart';

class UpdateUserInfo extends StatefulWidget {
  final userDetails;
  List<Hobbies> hobbiesList;
  List selectedHobbies;

  UpdateUserInfo(
    this.userDetails,
    this.hobbiesList,
    this.selectedHobbies,
  );
  @override
  _UpdateUserInfoState createState() => _UpdateUserInfoState();
}

class _UpdateUserInfoState extends State<UpdateUserInfo> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String birthDateInStringnew = "";
  DateTime birthDate;
  bool isDateSelected = false;
  String passion = "";
  String profession = "";
  void validateAndSave() {
    final form = formKey.currentState;
    if (form.validate() && initValue["homeTown"] != null) {
      print('Form is valid');

      updateProfile()
          .then((value) => Navigator.pushReplacementNamed(context, "./tab"));
      // updateProfile().then((value) => Navigator.pushReplacement(
      //                     context,
      //                     MaterialPageRoute(
      //                         builder: (context) => UserProfile())));
    } else {
      print('form is invalid');
    }
  }

  String dob;
  void getlocaldata() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    dob = sharedPreferences.get("dob");
    setState(() {});
    // print("localdob"+dob);
  }

  void updateuserlocaldata() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(
        "dob",
        birthDateInStringnew.isEmpty
            ? dob.toString()
            : birthDateInStringnew.toString());
    sharedPreferences.setString("passion", passion);
    sharedPreferences.getString("dob");
    setState(() {});
  }

  FocusNode fusername;
  FocusNode fuserhometown;
  FocusNode fuserhobbies;
  var initValue;
  List _selectedHobbies;
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    getlocaldata();
    initValue = {
      "userName": widget.userDetails["userdetails"]["user_name"],
      "homeTown": widget.userDetails["userdetails"]["home_town"],
      "passion": widget.userDetails["userdetails"]["passion"],
      "profession": widget.userDetails["userdetails"]["profession"],
      "dob": widget.userDetails["userdetails"]["dob"],
    };
    super.didChangeDependencies();
  }

  String username;
  Future updateProfile() async {
    String url = "http://hobcom.in/update_profile.php";
    var url2 = Uri.parse(url);
    http.Response response = await http.post(url2,
        body: jsonEncode(<String, dynamic>{
          "user_id": widget.userDetails["userdetails"]['user_id'],
          "user_name": initValue["userName"],
          "home_town": initValue["homeTown"],
          "hobbies": _selectedHobbies,
          "passion": initValue["passion"],
          "dob": birthDateInStringnew.isEmpty
              ? widget.userDetails["userdetails"]["dob"]
              : birthDateInStringnew.toString(),
          "profession": initValue["profession"]
        }));
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("username", initValue["userName"].toString());
    sharedPreferences.setString("usercity", initValue["homeTown"].toString());
    //  sharedPreferences.setString("hobbies", _selectedHobbies.toString());

    print(json.decode(response.body));
  }

  @override
  void initState() {
    fusername = FocusNode();
    fuserhometown = FocusNode();
    fuserhobbies = FocusNode();
    super.initState();
    _hobbiesList = widget.hobbiesList;
    _selectedHobbies = widget.selectedHobbies;
    print(_hobbiesList);
  }

// User hobbies [part]
// bool _isSelected;
  List<Hobbies> _hobbiesList = [];

  Iterable<Widget> get hobbiesWidgets sync* {
    for (Hobbies hobbies in _hobbiesList) {
      yield Padding(
        padding: const EdgeInsets.all(5.0),
        child: FilterChip(
          selectedColor: kprimary,
          avatar: CircleAvatar(
            child: Text(hobbies.name[0].toUpperCase()),
          ),
          label: Text(hobbies.name),
          selected: _selectedHobbies.contains(hobbies.id),
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                // adding hobbies to list
                _selectedHobbies.add(hobbies.id);

                // limiting hobbies to selected list of hobbies
                if (_selectedHobbies.length > 5) {
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.INFO,
                    animType: AnimType.BOTTOMSLIDE,
                    title: 'Max Hobbies Added',
                    desc: 'You can only add upto max  5 hobbies',
                    btnCancelOnPress: () {},
                    btnOkOnPress: () {},
                  )..show();
                }
                // removing last index : "if user had selected 6 hobbies"
                if (_selectedHobbies.length > 5) {
                  _selectedHobbies.removeLast();
                }
              } else {
                _selectedHobbies.removeWhere((var id) {
                  return id == hobbies.id;
                });
              }
            });
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Update Profile",
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // SizedBox(
              //   height: 15,
              // ),
              // Padding(
              //   padding: const EdgeInsets.all(20.0),
              //   child: CircleAvatar(
              //       radius: 70, backgroundImage: AssetImage('images/avatar.png')),
              // ),
              // IconButton(
              //   icon: Icon(Icons.camera_alt, size: 52, color: Colors.black),
              //   onPressed: () {},
              //   padding: EdgeInsets.all(0.0),
              //   splashColor: Colors.black,
              //   highlightColor: Colors.grey,
              //   iconSize: 52,
              // ),
              Padding(
                padding: EdgeInsets.all(25),
                child: TextFormField(
                  validator: (value) {
                    return value.isEmpty ? "Username can't be empty" : null;
                  },
                  initialValue: initValue['userName'],
                  focusNode: fusername,
                  onChanged: (value) {
                    setState(() {
                      initValue["userName"] = value;
                    });
                  },
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'user_name',
                    icon: Icon(Icons.person),
                  ),
                ),
              ),

              // Padding(
              //   padding: EdgeInsets.all(25),
              //   child: TextFormField(
              //     initialValue: initValue['homeTown'],
              //     focusNode: fuserhometown,
              //     onSaved: (value) {},
              //     onChanged: (value) {
              //       setState(() {
              //         initValue["homeTown"] = value;
              //       });
              //     },
              //     textAlign: TextAlign.center,
              //     decoration: InputDecoration(
              //       icon: Icon(Icons.home),
              //       hintText: 'home_town',
              //     ),
              //   ),
              // ),

              Padding(
                padding: EdgeInsets.all(25),
                child: DropDownField(
                    required: true,
                    itemsVisibleInDropdown: 3,
                    hintText: "Hometown",
                    icon: Icon(Icons.home),
                    value: initValue['homeTown'],
                    onValueChanged: (val) {
                      setState(() {
                        initValue["homeTown"] = val;
                      });
                    },
                    items: Cities().city),
              ),
              // Padding(padding:EdgeInsets.all(25),child:SearchableDropdown(items: <DropdownMenuItem>[1:"delhi","2":"mumbai","kolkata","agra","calicut","banglore"], onChanged: null) ),

              Padding(
                padding: const EdgeInsets.only(left: 25.0, bottom: 15),
                child: Row(
                  children: [
                    GestureDetector(
                        child: new Icon(
                          Icons.cake,
                          color: kprimary,
                          size: 25,
                        ),
                        onTap: () async {
                          final datePick = await showDatePicker(
                              context: context,
                              initialDate: new DateTime.now(),
                              firstDate: new DateTime(1900),
                              lastDate: new DateTime(2023));
                          if (datePick != null && datePick != birthDate) {
                            setState(() {
                              birthDate = datePick;
                              isDateSelected = true;

                              // put it here
                              birthDateInStringnew =
                                  "${birthDate.year}/${birthDate.month}/${birthDate.day}";

                              // print(birthDateInString);
                            });
                          }
                        }),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: InkWell(
                          onTap: () async {
                            final datePick = await showDatePicker(
                              context: context,
                              initialDate: new DateTime.now(),
                              firstDate: new DateTime(1900),
                              lastDate: new DateTime(2023),
                            );
                            if (datePick != null && datePick != birthDate) {
                              birthDate = datePick;
                              birthDateInStringnew =
                                  "${birthDate.year}/${birthDate.month}/${birthDate.day}";

                              setState(() {
                                isDateSelected = true;

                                // put it here

                                // print(birthDateInString);
                              });
                            }
                          },
                          child: birthDateInStringnew == "" ||
                                  birthDateInStringnew == null
                              ? Text("Change your date of birth :$dob")
                              : Text(
                                  "Change your date of birth :$birthDateInStringnew")),
                      //+widget.userDetails["userdetails"][ "dob"]
                    ),
                  ],
                ),
              ),

              Text('Select 5 Hobbies',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center),
              Padding(
                padding: EdgeInsets.all(5),
                child: Column(
                  children: [
                    Wrap(
                      children: hobbiesWidgets.toList(),
                    ),
                    // Padding(
                    //     padding: const EdgeInsets.all(10.0),
                    //     child: Text(
                    //         'Selected Hobbies : ${_selectedHobbies.join(', ')}',
                    //         style: TextStyle(
                    //           color: Colors.black,
                    //           fontWeight: FontWeight.w300,
                    //         ),
                    //         textAlign: TextAlign.center)),
                  ],
                ),
              ),

              // bio

              Padding(
                padding: EdgeInsets.all(25),
                child: TextFormField(
                  initialValue: initValue["profession"],
                  onChanged: (value) {
                    initValue["profession"] = value;
                  },
                  onSaved: (value) {},
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    icon: Icon(Icons.leave_bags_at_home_sharp),
                    hintText: 'Update your profession',
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(25),
                child: TextFormField(
                  initialValue: initValue['passion'],
                  onChanged: (value) {
                    setState(() {
                      initValue["passion"] = value;
                      passion = value;

                      updateuserlocaldata();
                    });
                  },
                  onSaved: (value) {},
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    icon: Icon(Icons.connect_without_contact_sharp),
                    hintText: 'Update your Passion/Bio',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0, bottom: 25),
                child: SizedBox(
                  height: 45,
                  width: 200,
                  child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      onPressed: () async {
                        validateAndSave();
                        updateuserlocaldata();

                        // else{

                        //   return "Username and hometowm can't be empty";
                        // }
                      },
                      color: kprimary,
                      textColor: Colors.black,
                      child: Text(
                        " Update",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

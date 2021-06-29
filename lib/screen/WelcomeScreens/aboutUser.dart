import 'package:dropdownfield/dropdownfield.dart';
import 'package:flutter/material.dart';
import 'package:hobcom/Model/cities.dart';
import 'dart:convert';
import 'package:hobcom/Model/hobbies.dart';
import 'package:hobcom/Utils/const..dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Aboutuser extends StatefulWidget {
  @override
  _AboutuserState createState() => _AboutuserState();
}

class _AboutuserState extends State<Aboutuser> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController carrertextEditingController =
      new TextEditingController();
  var initValue;
  String birthDateInString;
  DateTime birthDate;
  bool isDateSelected = false;

  void validateAndSave() {
    final form = formKey.currentState;

    if (form.validate() &&
        homeTown != null &&
        birthDateInString != null &&
        passion.isNotEmpty) {
      print('Form is valid');

      updateProfile();
      Navigator.of(context).pushNamed('./congratsUser');
    } else {
      print('form is invalid');
      setState(() {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.INFO,
          animType: AnimType.BOTTOMSLIDE,
          title: 'Hi',
          desc: 'Please fill all the details',
          btnCancelOnPress: () {},
          btnOkOnPress: () {},
        )..show();
      });
    }
  }

  FocusNode name;
  FocusNode fuserhobbies;
  FocusNode fuserpassion;
  // bool _isSelected;
  // List<Hobbies> _hobbiesList;
  List _selectedHobbies;
  List<Hobbies> _hobbiesList = [];
  Future<void> getHobbiesList() async {
    _hobbiesList = [];
    String url = "http://hobcom.in/hobby_list.php";
    var url2 = Uri.parse(url);
    http.Response hobbiesResponse = await http.get(url2);
    var res = json.decode(hobbiesResponse.body);
    setState(() {
      for (int i = 0; i < res.length; i++) {
        _hobbiesList.add(Hobbies(id: res[i]['id'], name: res[i]['hobbyname']));
      }
    });
  }

  String userName = "";
  String homeTown = "";
  String passion = "";
  String career = "";
  Future updateProfile() async {
    String url = "http://hobcom.in/update_profile.php";
    var url2 = Uri.parse(url);
    http.Response response = await http.post(url2,
        body: jsonEncode(<String, dynamic>{
          "user_id": id,
          "user_name": userName,
          "home_town": homeTown,
          "hobbies": _selectedHobbies,
          "passion": passion,
          "dob": birthDateInString,
          "profession": carrertextEditingController.text.trim()
        }));
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(
      "username",
      userName,
    );

    sharedPreferences.setString("usercity", homeTown);
    sharedPreferences.setString("passion", passion);
    sharedPreferences.setString("dob", birthDateInString);
    sharedPreferences.setString("career", career);
    // sharedPreferences.setString("hobbies", _selectedHobbies.toString());

    print(_selectedHobbies);
    print(json.decode(response.body));
  }

  String id;
  @override
  void didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    id = sharedPreferences.get("userid");
    await getHobbiesList();
    super.didChangeDependencies();
  }

  @override
  void initState() {
    name = FocusNode();
    fuserhobbies = FocusNode();
    fuserpassion = FocusNode();
    super.initState();
    _selectedHobbies = [];
  }

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
                    dialogType: DialogType.WARNING,
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
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Tell us more about you"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Container(
                  height: 150,
                  margin: EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('images/moreabout.png')),
                  ),
                ),

                // username
                Padding(
                  padding: EdgeInsets.all(20),
                  child: TextFormField(
                    validator: (value) {
                      return value.isEmpty ? "Username can't be empty" : null;
                    },
                    focusNode: name,
                    onSaved: (value) {},
                    onChanged: (value) {
                      setState(() {
                        userName = value;
                      });
                    },
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'Your Name',
                      icon: Icon(Icons.person),
                    ),
                  ),
                ),

                // age
                // Padding(
                //   padding: EdgeInsets.all(20),
                //   child: TextFormField(
                //     keyboardType: TextInputType.number,
                //     onSaved: (value) {},
                //     onChanged: (value) {},
                //     textAlign: TextAlign.center,
                //     decoration: InputDecoration(
                //       hintText: 'Age ',
                //       icon: Icon(Icons.psychology),
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
                      onValueChanged: (val) {
                        setState(() {
                          homeTown = val;
                        });
                      },
                      items: Cities().city),
                ),

                Padding(
                  padding:
                      const EdgeInsets.only(left: 25.0, bottom: 15, top: 15),
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
                                birthDateInString =
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
                                  lastDate: new DateTime(2023));
                              if (datePick != null && datePick != birthDate) {
                                setState(() {
                                  birthDate = datePick;
                                  isDateSelected = true;

                                  // put it here
                                  birthDateInString =
                                      "${birthDate.year}/${birthDate.month}/${birthDate.day}";

                                  // print(birthDateInString);
                                });
                              }
                            },
                            child: birthDateInString == null
                                ? Text("Select your date of birth : yyyy-mm-dd")
                                : Text(
                                    "Selected your date of birth : $birthDateInString")),
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
                      Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                              'Selected Hobbies : ${_selectedHobbies.join(', ')}',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w300,
                              ),
                              textAlign: TextAlign.center)),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(25),
                  child: TextFormField(
                    controller: carrertextEditingController,
                    validator: (value) {
                      return value.isEmpty ? "Career can't be empty" : null;
                    },
                    onChanged: (value) {
                      setState(() {
                        career = value;
                      });
                    },
                    onSaved: (value) {},
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      icon: Icon(Icons.business_center_sharp),
                      hintText: 'About your career',
                    ),
                  ),
                ),

                // ;

                Padding(
                  padding: EdgeInsets.all(25),
                  child: TextFormField(
                    focusNode: fuserpassion,
                    onChanged: (value) {
                      setState(() {
                        passion = value;
                      });
                    },
                    onSaved: (value) {},
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      icon: Icon(Icons.connect_without_contact_sharp),
                      hintText: 'Express your passion for hobbies',
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Add picture to show others\n how passionate you are about your hobby",
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  height: 150,
                  margin: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage('images/addprof.png'),
                    // colorFilter: ColorFilter.mode(Colors.black.withOpacity(.2), BlendMode.dstATop)
                  )),
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 11.0, bottom: 25),
                  child: SizedBox(
                    height: 45,
                    width: 200,
                    child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        onPressed: () async {
                          validateAndSave();
                        },
                        color: kprimary,
                        textColor: Colors.black,
                        child: Text(
                          "Next",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

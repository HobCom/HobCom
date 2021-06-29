import 'package:flutter/material.dart';
import 'package:hobcom/Utils/const..dart';

class CongratsScreen extends StatefulWidget {
  @override
  _CongratsScreenState createState() => _CongratsScreenState();
}

class _CongratsScreenState extends State<CongratsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.all(25),
                height: 150,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('images/Hobcom_logo.png'))),
              ),

              Container(
                margin: EdgeInsets.all(25),
                height: 150,
                decoration: BoxDecoration(
                    image:
                        DecorationImage(image: AssetImage('images/congo.png'))),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Congratulation !',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Your profile has been created ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center),
              ),

              //  \n your profile has been created
              SizedBox(
                height: 25,
              ),

              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                    'Now you can connect to someone \nto pursue your hobby .',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center),
              ),

              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                    'Your Profile has been rated as\n Level 1 authenticated 🌟',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center),
              ),

              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Text(
                    'However, we would appreciate if you could take a moment to validate your profile further .\n \nThis additonal step, even though optional, makes your profile look genuine to others',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center),
              ),

            // Move towards level 2 authentication
             Padding(
                padding: const EdgeInsets.only(left: 11.0, bottom: 25),
                child: SizedBox(
                  height: 45,
                  width:300,
                  child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      onPressed: () async {
                        Navigator.of(context).pushNamed('./level2auth');
                      },
                      color: kprimary,
                      textColor: Colors.black,
                      child: Text(
                        " Move towards level 2 authentication",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      )),
                ),
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
                        Navigator.of(context).pushNamed('./tab');
                      },
                      color: kprimary,
                      textColor: Colors.black,
                      child: Text(
                        "Skip",
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

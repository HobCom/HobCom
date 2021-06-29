import 'package:flutter/material.dart';
import 'package:hobcom/Authentication/AuthHome.dart';
import 'package:hobcom/Utils/const..dart';
import 'package:hobcom/screen/helpsupport.dart';
import 'package:hobcom/screen/homePage.dart';
import 'package:hobcom/tabs/bottomTab.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hobcom/screen/WelcomeScreens/OtpScreen.dart';
import 'package:hobcom/screen/WelcomeScreens/aboutUser.dart';
import 'package:hobcom/screen/WelcomeScreens/CongratsUser.dart';
import 'package:hobcom/screen/WelcomeScreens/level2Auth.dart';
import 'Model/Infowindow.dart';
import 'package:firebase_core/firebase_core.dart';
import 'chat/pushNotification.dart';

 FirebasePushNotificationService  _pushNotificationService = FirebasePushNotificationService();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  _pushNotificationService.initialize();
  String userID;
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  userID = sharedPreferences.getString("userid");
  print("userfetched");
  

  runApp(ChangeNotifierProvider(
    create: (context)=>Infowindow(),
      child: MyApp(
     userinfo: userID,
    ),
  ));
}

class MyApp extends StatefulWidget {
  final String userinfo;

  const MyApp({Key key, this.userinfo}) : super(key: key);
  // This widget is the root of your application

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: kprimary,
        primarySwatch: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: widget.userinfo != null ? Tabs() : AuthHome(),
      routes: {
        './tab': (context) => Tabs(),
        './home': (context) => HomePage(),
      '/otpScreen':(context)=>Otp(),
        './aboutuser': (context) => Aboutuser(),
         './congratsUser': (context) => CongratsScreen(),
          './level2auth': (context) => Level2AuthScreen(),
          './help' : (context)=>  HelpSupport()

        //  Level2AuthScreen
         
      },
    );
  }
}

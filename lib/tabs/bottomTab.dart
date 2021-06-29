import 'package:flutter/material.dart';
import 'package:hobcom/screen/UserProfile.dart';
import 'package:hobcom/screen/chatsbox.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screen/homePage.dart';
import '../screen/notifications.dart';

class Tabs extends StatefulWidget {
  @override
  _TabsState createState() => _TabsState();
}

class _TabsState extends State<Tabs> {


  int _selectedIndex = 0;
  List<Map<String, dynamic>> page = [
    {
      'page': HomePage(),
    },
    {
      'page': ChatBox(),
    },
    {
      'page': NotificationScreen(),
    },
    {
      'page': UserProfile( ),
    }
    
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: page[_selectedIndex]['page'],
        bottomNavigationBar: Container(
          height:83,
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                  activeIcon: Image(
                    image: AssetImage(
                      'lib/asset/homeIcon.png',
                    ),
                     )),
              BottomNavigationBarItem(
                icon: Image(
                  image: AssetImage('lib/asset/chatting.png'),
                ),
                activeIcon: Image(
                    image: AssetImage(
                      'lib/asset/chattingIcon.png',
                    ),),
                label: 'Chatting',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
                label: 'Notification',
                activeIcon: Image(
                    image: AssetImage(
                      'lib/asset/notificationIcon.png',
                    ),),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
                activeIcon: Image(
                    image: AssetImage(
                      'lib/asset/profileIcon.png',
                    ),),
              )
            ],
            currentIndex: _selectedIndex,
            showSelectedLabels: false,
            unselectedItemColor: Colors.grey[400],
            showUnselectedLabels: true,
            type: BottomNavigationBarType.shifting,
            // elevation: 40,
            fixedColor: Color.fromRGBO(254, 178, 31, 1),
            onTap: _onItemTapped,
          ),
        ));
  }
}

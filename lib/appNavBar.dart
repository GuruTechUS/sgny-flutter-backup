import 'package:easy_dialog/easy_dialog.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:sgny/pages/contacts.dart';
import 'pages/gallery/galleryPage.dart';
import 'pages/home/homePage.dart';
import 'pages/info.dart';
import 'pages/links.dart';
import 'pages/notifications.dart';

class AppNavBar extends StatefulWidget {
  @override
  _AppNavBarState createState() => _AppNavBarState();
}

class _AppNavBarState extends State<AppNavBar> {
  Widget _displayPage = HomePage();

  Widget selectedPage(int page) {
    switch (page) {
      case 0:
        return HomePage();
        break;
      case 1:
        return Gallery();
        break;
      case 2:
        return Links();
        break;
      case 3:
        return Notifications();
        break;
      case 4:
        return Contacts();
        break;
      case 5:
        return Info();
        break;
      default:
        return HomePage();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: CurvedNavigationBar(
          index: 0,
          height: 75.0,
          items: <Widget>[
            Icon(Icons.home, size: 30),
            Icon(Icons.photo_library, size: 30),
            Icon(Icons.link, size: 30),
            Icon(Icons.notifications, size: 30),
            Icon(Icons.contact_phone, size: 30),
            Icon(Icons.info, size: 30),
          ],
          color: Colors.white70,
          buttonBackgroundColor: Color(0xffbdc3c7),
          backgroundColor: Colors.black,
          animationCurve: Curves.easeInOut,
          animationDuration: Duration(milliseconds: 600),
          onTap: (index) {
            setState(() {
              _displayPage = selectedPage(index);
            });
          },
        ),
        body: Container(
            color: Colors.white,
            child: SafeArea(
              child: _displayPage,
            )));
  }
}

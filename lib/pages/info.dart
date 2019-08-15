import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:sgny/utils/firebase_anon_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'loginPage.dart';

class Info extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
   if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.deepPurpleAccent, // Color for Android
                statusBarBrightness: Brightness.light // Dark == white status bar -- for IOS.
              ));
    } else if (Platform.isIOS) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.white, // Color for Android
                statusBarBrightness: Brightness.light // Dark == white status bar -- for IOS.
              ));
    }
    return _InfoState();
  }
}

class _InfoState extends State<Info> {
  final FirebaseAnonAuth firebaseAuth = FirebaseAnonAuth();
  
  bool adminLoggedIn = false;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  _InfoState() {
    firebaseAuth.isLoggedIn().then((user) {
      if (user != null && user.uid != null && user.uid != "") {
        if (user.isAnonymous == false) {
          setState(() {
            adminLoggedIn = true;
          });
        }
      } else {
        firebaseAuth.signInAnon().then((anonUser) { 
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.deepPurpleAccent,
          title: Text("Info"),
          actions: <Widget>[
            adminLoggedIn == false
                ? FlatButton.icon(
                    icon: Icon(Icons.lock),
                    splashColor: Colors.white,
                    label: Text('Login'),
                    textColor: Colors.white,
                    onPressed: () async {
                      final result = await Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => LoginPage()));
                      if (result == true) {
                        setState(() {
                          adminLoggedIn = true;
                        });
                        _scaffoldKey.currentState.showSnackBar(SnackBar(
                            backgroundColor: Colors.greenAccent,
                            content: Text(
                              "Admin Logged-In Successfully..!",
                              style: TextStyle(color: Colors.black),
                            )));
                      }
                      Future.delayed(const Duration(milliseconds: 150), () {
                            updateStatusBarColor();
                        });
                        Future.delayed(const Duration(milliseconds: 500), () {
                            updateStatusBarColor();
                        });
                    },
                  )
                : FlatButton.icon(
                    icon: Icon(Icons.lock_open),
                    label: Text('Logout'),
                    splashColor: Colors.white,
                    textColor: Colors.white,
                    onPressed: () {
                      firebaseAuth.signOut().then((data) {
                        setState(() {
                          adminLoggedIn = false;
                        });
                        _scaffoldKey.currentState.showSnackBar(SnackBar(
                            content: Text(
                          "Admin Logged-Out!",
                        )));
                      });
                    },
                  )
          ],
        ),
        body: Center(
          child: infoPageContent(context),
        ));
  }

  Widget infoPageContent(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          Firestore.instance.collection("app").document("about-us").snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        } else {
          return renderLinkList(snapshot);
        }
      },
    );
  }

  renderLinkList(AsyncSnapshot<DocumentSnapshot> snapshot) {
    // return Text(snapshot.data.data.toString());
    return snapshot.data.data == null ? Container() :
    ListView(
      children: <Widget>[
        Card(
            child: new Container(
          padding: EdgeInsets.all(10.0),
          child: Center(
              child: Column(
            children: <Widget>[
              Container(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Image.asset(
                    "assets/images/logo.png",
                    height: 120,
                  ),
                ),
              ),
              Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    snapshot.data.data["app-name"] ??= "",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ))
            ],
          )),
        )),
        snapshot.data.data["feedback"] != null ? InkWell(
          onTap: () {
            _launchURL(Uri.encodeFull(snapshot.data.data["feedback"]));
          },
          child: Card(
            child: ListTile(
              leading: Icon(Icons.feedback, color: Colors.green),
              title: Text(
                snapshot.data.data["feedback-title"] ?? "Give us your feedback",
                style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
        ): Container(),
        Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            snapshot.data.data["tag-line"] ??= "",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 18
              //  fontStyle: FontStyle.italic
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: Image.asset(
              "assets/images/gurutech.png",
              height: 34,
            ),
            title: Text(
              snapshot.data.data["name"] ??= "",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        snapshot.data.data["phone"] != null ? InkWell(
          onTap: () {
            _launchURL("tel:" + Uri.encodeFull(snapshot.data.data["phone"]));
          },
          child: Card(
            child: ListTile(
              leading: Icon(Icons.local_phone, color: Colors.deepPurpleAccent),
              title: Text(
                snapshot.data.data["phone"] ??= "",
                style:
                    TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold),
              ),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
        ): Container(),
        snapshot.data.data["email"] != null ? InkWell(
          onTap: () {
            _launchURL( Uri.encodeFull(snapshot.data.data["email-link"]) ??
                ("mailto:" + Uri.encodeFull(snapshot.data.data["email"])));
          },
          child: Card(
            child: ListTile(
              leading: Icon(Icons.email, color: Colors.blueAccent),
              title: Text(
                snapshot.data.data["email"] ??= "",
                style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
        ): Container(),
        snapshot.data.data["web"] != null ? InkWell(
          onTap: () {
            _launchURL(Uri.encodeFull(snapshot.data.data["web"]));
          },
          child: Card(
            child: ListTile(
              leading: Icon(Icons.web, color: Colors.blueAccent),
              title: Text(
                snapshot.data.data["web"] ??= "",
                style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
        ): Container(),
        
      ],
    );
  }

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  updateStatusBarColor(){
    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.deepPurpleAccent, // Color for Android
                statusBarBrightness: Brightness.light // Dark == white status bar -- for IOS.
              ));
    } else if (Platform.isIOS) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.white, // Color for Android
                statusBarBrightness: Brightness.light // Dark == white status bar -- for IOS.
              ));
    }
    setState(() {
    });
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_dialog/easy_dialog.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'appNavBar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'utils/firebase_anon_auth.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MaterialApp(
      title: 'Sikh Games of NY',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics()),
      ],
      theme: new ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: MyApp(),
    ));
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final FirebaseAnonAuth firebaseAuth = FirebaseAnonAuth();
  
  bool displayDialog = true;
  dynamic appConfig = {};

  @override
  void initState() {
    _firebaseMessaging.configure(onLaunch: (Map<String, dynamic> msg) {
      print("onLaunch called");
      return Future<dynamic>.value(msg);
    }, onMessage: (Map<String, dynamic> msg) {
      print("onMessage called");
      return Future<dynamic>.value(msg);
    }, onResume: (Map<String, dynamic> msg) {
      print("onResume called");
      return Future<dynamic>.value(msg);
    });
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, alert: true, badge: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings setting) {
      print("iOS settings registered");
    });
    _firebaseMessaging.getToken().then((token) {
      update(token);
    });
    firebaseAuth.isLoggedIn().then((user) {
      if (user != null && user.uid != null && user.uid != "") {
      } else {
        firebaseAuth.signInAnon().then((anonUser) { 
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 500), () {
      fetchAppHomePageData();
    });
    return AppNavBar();
  }

  fetchAppHomePageData() {
    Firestore.instance
        .collection("app")
        .document("homeScreen")
        .snapshots()
        .listen((onData) {
      if (onData != null) {
        appConfig = onData.data;
        if(appConfig["displayDialog"] == true){
          displayWelcomeDialog();
        }
      }
    });
  }
  displayWelcomeDialog() {
    double heigh = (MediaQuery.of(context).size.height - 80.0);
    double width = (MediaQuery.of(context).size.width - 20.0);
    double heightFactor = appConfig["heightFactor"] ?? 1.49053857351;
    double widthFactor =  appConfig["widthFactor"] ?? 0.6708984375;
    if(heigh > (width * heightFactor)){
      heigh = width * heightFactor;
    } else {
      width = heigh * widthFactor;
    }
    if (displayDialog) {
      displayDialog = false;
      EasyDialog(
          cornerRadius: 10.0,
          fogOpacity: 0.1,
          height: heigh,
          width: width,
          contentPadding: EdgeInsets.all(10.0), // Needed for the button design
          contentList: [
            Container(
                child: Image(
                    image: NetworkImage( appConfig["dialogImage"] ??
                        "https://firebasestorage.googleapis.com/v0/b/sgny-app.appspot.com/o/2019%2F2019-08-02%2020:36:21.108647.jpg?alt=media&token=ee697845-545e-4429-a6dd-ab45566af543"),
                    fit: BoxFit.cover)),
          ]).show(context);
    }
  }

  void update(String token) {}
}

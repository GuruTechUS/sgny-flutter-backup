import 'dart:io';

import 'package:flutter/services.dart';
import 'package:sgny/pages/home/addEvent.dart';
import 'package:sgny/pages/home/eventDetails.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sgny/utils/firebase_anon_auth.dart';

//import 'package:cloud_firestore/cloud_firestore.dart';

// DateTime parseTime(dynamic date) {
//   return Platform.isIOS ? (date as Timestamp).toDate() : (date as DateTime);
// }

class ScheduleScreen extends StatefulWidget {
  final dynamic sportsItem;
  final dynamic category;
  final bool gender;

  ScheduleScreen(this.sportsItem, this.category, this.gender) {
    fetchUserToken();
  }

  fetchUserToken() async {}

  @override
  State<StatefulWidget> createState() {
    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.deepPurpleAccent, // Color for Android
          statusBarBrightness:
              Brightness.light // Dark == white status bar -- for IOS.
          ));
    }
    Future.delayed(const Duration(milliseconds: 150), () {
      updateStatusBarColor();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      updateStatusBarColor();
    });

    return _ScheduleScreenState(sportsItem, category, gender);
  }

  updateStatusBarColor() {
    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.deepPurpleAccent, // Color for Android
          statusBarBrightness:
              Brightness.light // Dark == white status bar -- for IOS.
          ));
    } else if (Platform.isIOS) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.white, // Color for Android
          statusBarBrightness:
              Brightness.light // Dark == white status bar -- for IOS.
          ));
    }
  }
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final dynamic sportsItem;
  final dynamic category;
  final bool gender;
  String userId;
  bool recordExist = false;
  bool isAdminLoggedIn = false;

  Map<String, dynamic> subscription = new Map<String, dynamic>();

  final FirebaseAnonAuth firebaseAnonAuth = new FirebaseAnonAuth();

  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  _ScheduleScreenState(this.sportsItem, this.category, this.gender) {
    firebaseAnonAuth.isLoggedIn().then((user) {
      if (user != null && user.uid != null) {
        setState(() {
          this.userId = user.uid;
          if (user.isAnonymous == false) {
            isAdminLoggedIn = true;
          }
        });
        fetchUserPreferences();
      } else {
        firebaseAnonAuth.signInAnon().then((anonUser) {
          if (anonUser != null && anonUser.uid != null) {
            setState(() {
              this.userId = anonUser.uid;
            });
            fetchUserPreferences();
          }
        });
      }
    });
  }

  fetchUserPreferences() async {
    await fetchSubscriptionData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: scheduleList(context),
    ));
  }

  Widget scheduleList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection("events")
          .where("category", isEqualTo: category["name"])
          .where("gender", isEqualTo: gender)
          .where("sport", isEqualTo: sportsItem["name"])
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        } else {
          //return ListView(children: getExpenseItems(snapshot));
          return eventsList(snapshot);
        }
      },
    );
  }

  eventsList(AsyncSnapshot<QuerySnapshot> snapshot) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          backgroundColor: Colors.deepPurpleAccent,
          expandedHeight: 50.0,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            title: Text("Schedule: " +
                (gender ? "Boys" : "Girls") +
                " / " +
                sportsItem["title"] +
                " / " +
                category["name"]),
          ),
          actions: <Widget>[
            isAdminLoggedIn
                ? IconButton(
                    icon: Icon(Icons.add),
                    tooltip: 'Download',
                    onPressed: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => AddEvent(gender,
                                  sportsItem["name"], category["name"])));
                    },
                  )
                : Container(),
          ],
        ),
        snapshot.data.documents.length == 0
            ? SliverFillRemaining(
                child: Card(
                child: Center(
                  child: Text("No events available yet!"),
                ),
              ))
            : SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => EventDetails(
                                    userId,
                                    snapshot.data.documents[index].documentID,
                                    (gender == true ? "Boys" : "Girls") +
                                        " / " +
                                        sportsItem["title"] +
                                        " / " +
                                        category["name"])));
                      },
                      child: Card(
                        child: new Container(
                            padding: EdgeInsets.all(10.0),
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                    child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    displayTeams(snapshot.data.documents[index]
                                        ["teams"]),
                                    displayLocation(snapshot
                                        .data.documents[index]["location"]),
                                    displayStatus(snapshot.data.documents[index]
                                        ["status"])
                                  ],
                                )),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    snapshot.data.documents[index]
                                                ["startTime"] !=
                                            null
                                        ? displayTimeAndDate(snapshot
                                            .data.documents[index]["startTime"])
                                        : Text(""),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    subscribeToEvent(snapshot
                                        .data.documents[index].documentID),
                                  ],
                                )
                              ],
                            )),
                      ));
                }, childCount: snapshot.data.documents.length),
              )
      ],
    );
  }

  displayTeams(teams) {
    if (teams != null && teams.length == 2) {
      return Text(
          (teams[0]["name"] != null ? teams[0]["name"] : "--") +
              " vs " +
              (teams[1]["name"] != null ? teams[1]["name"] : "--"),
          style: TextStyle(
              color: Colors.black,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              fontFamily: "WorkSansSemiBold"));
    } else if (teams != null && teams.length == 1) {
      return Text(
          (teams[0]["name"] != null ? teams[0]["name"] : "--") + " vs --",
          style: TextStyle(
              color: Colors.black,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              fontFamily: "WorkSansSemiBold"));
    } else if (teams != null && teams.length >= 2) {
      return Text("");
    } else {
      return Text("");
    }
  }

  displayLocation(location) {
    if (location != null) {
      return Text(location, textAlign: TextAlign.left);
    } else {
      return Text("");
    }
  }

  dynamic months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  displayTimeAndDate(Timestamp startTime) {
    DateTime date = startTime.toDate();
    //DateTime date = DateTime.parse(startTime.toString());
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          getTime(date),
          getDate(date),
        ]);
  }

  getDate(DateTime startTime) {
    if (startTime != null) {
      return Text(startTime.day.toString() + " " + months[startTime.month - 1]);
    } else {
      return Text("");
    }
  }

  getTime(DateTime startTime) {
    if (startTime != null) {
      String padding = startTime.minute <= 9 ? "0" : "";
      String hour = startTime.hour.toString();
      String sufix = "AM";
      if (startTime.hour >= 12) {
        hour = (startTime.hour - 12).toString();
        if (hour == '0') {
          hour = '12';
        }
        sufix = "PM";
      }
      return Text(
          hour + ":" + padding + startTime.minute.toString() + " " + sufix,
          style: TextStyle(fontSize: 24.0));
    } else {
      return Text("");
    }
  }

  displayStatus(String status) {
    if (status != null) {
      return Text(status);
    } else {
      return Text("");
    }
  }

  subscribeToEvent(documentID) {
    subscription.putIfAbsent(documentID, () => false);
    return Container(
        padding: EdgeInsets.all(10.0),
        child: InkWell(
            onTap: () {
              updateData(documentID);
            },
            child: Image.asset(
              subscription[documentID]
                  ? "assets/images/bell-solid.png"
                  : "assets/images/bell-regular.png",
              width: 30,
            )));
  }

  updateData(key) {
    DocumentReference subscriptionDocumentReference = Firestore.instance
        .collection("devices")
        .document("preferences")
        .collection(this.userId)
        .document("subscriptions");
    if (!subscription[key]) {
      subscribeToTopic(key);
    } else {
      unSubscribeToTopic(key);
    }
    if (!recordExist) {
      subscriptionDocumentReference.setData({key: !subscription[key]});
    } else {
      subscriptionDocumentReference.updateData({key: !subscription[key]});
    }
  }

  subscribeToTopic(key) {
    print("subscribed: " + key);
    firebaseMessaging.subscribeToTopic(key);
  }

  unSubscribeToTopic(key) {
    print("unsubscribed: " + key);
    firebaseMessaging.unsubscribeFromTopic(key);
  }

  fetchSubscriptionData() {
    Stream<DocumentSnapshot> subscriptionSnapshot = Firestore.instance
        .collection("devices")
        .document("preferences")
        .collection(this.userId)
        .document("subscriptions")
        .snapshots();

    subscriptionSnapshot.listen((documentData) {
      if (!mounted) return;
      setState(() {
        if (documentData.data == null) {
          subscription = {};
        } else {
          subscription = documentData.data;
          recordExist = true;
        }
      });
    });
  }
}

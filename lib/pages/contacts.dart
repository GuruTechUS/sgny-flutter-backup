import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:sgny/utils/firebase_anon_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Contacts extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
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
    return _ContactsState();
  }
}

class _ContactsState extends State<Contacts> {
  FirebaseAnonAuth firebaseAuth = FirebaseAnonAuth();
  bool adminLoggedIn = false;

  _ContactsState() {
    // firebaseAuth.isLoggedIn().then((user){
    //   if(user !=null && user.uid != null && user.uid != ""){
    //     if(user.isAnonymous == false){
    //       setState(() {
    //           adminLoggedIn = true;
    //       });
    //     }
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurpleAccent,
          title: Text("Contacts"),
        ),
        body: Center(
          child: infoPageContent(context),
        ));
  }

  Widget infoPageContent(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection("contacts").snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        } else {
          return renderLinkList(snapshot);
        }
      },
    );
  }

  renderLinkList(AsyncSnapshot<QuerySnapshot> snapshot) {
    return CustomScrollView(
      slivers: <Widget>[
        snapshot.data.documents.length == 0
            ? SliverFillRemaining(
                child: Card(
                child: Center(
                  child: Text("No contacts available!!"),
                ),
              ))
            : SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return Card(
                    child: new Container(
                        padding: EdgeInsets.all(10.0),
                        child: Column(
                          children: <Widget>[
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  (snapshot.data.documents[index]["title"] !=
                                          null
                                      ? Text(
                                          snapshot.data.documents[index]
                                                  ["title"] ??
                                              "",
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold))
                                      : Container())
                                ]),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    contactIcon(),
                                  ],
                                ),
                                Expanded(
                                    child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    (snapshot.data.documents[index]["name"] !=
                                            null
                                        ? Text(
                                            snapshot.data.documents[index]
                                                    ["name"] ??
                                                "",
                                            style: TextStyle(fontSize: 16.0))
                                        : Container()),
                                    (snapshot.data.documents[index]["number"] !=
                                            null
                                        ? Text(snapshot.data.documents[index]
                                                ["number"] ??
                                            "")
                                        : Container()),
                                    (snapshot.data.documents[index]["email"] !=
                                            null
                                        ? Text(snapshot.data.documents[index]
                                                ["email"] ??
                                            "")
                                        : Container()),
                                  ],
                                )),
                                (snapshot.data.documents[index]["email"] !=
                                            null ? Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    displayEmailButton(snapshot.data.documents[index]["email"]),
                                  ],
                                ): Container()),
                                (snapshot.data.documents[index]["number"] !=
                                            null ? Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    displayCallButton(snapshot.data.documents[index]["number"]),
                                  ],
                                ): Container()),
                              ],
                            ),
                            (snapshot.data.documents[index]["info"] != null ? moreInfo(snapshot.data.documents[index]["info"]) : Container())
                          ],
                        )),
                  );
                }, childCount: snapshot.data.documents.length),
              )
      ],
    );
  }

  moreInfo(info) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(info ?? ""),
        )
      ],
    );
  }

  displayCallButton(url) {
    return Container(
        padding: EdgeInsets.all(10.0),
        child: InkWell(
            onTap: () {
              _launchURL("tel:" + Uri.encodeFull(url));
            },
            child: Icon(Icons.call, color: Colors.blueAccent)));
  }

  displayEmailButton(url) {
    return Container(
        padding: EdgeInsets.all(10.0),
        child: InkWell(
            onTap: () {
              _launchURL("mailto:" + Uri.encodeFull(url));
            },
            child: Icon(Icons.email, color: Colors.blueAccent)));
  }

  contactIcon() {
    return Container(
        padding: EdgeInsets.all(10.0),
        child: Image.asset(
          "assets/images/contact.png",
          width: 30,
        ));
  }

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

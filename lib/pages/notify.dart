import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sgny/utils/firebase_anon_auth.dart';
import 'package:flutter/material.dart';

class NotifyPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NotifyPageState();
  }
}

class _NotifyPageState extends State<NotifyPage> {
  final _formKey = GlobalKey<FormState>();
  FirebaseAnonAuth firebaseAuth = FirebaseAnonAuth();
  String _title;
  String _body;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Send new notification"),
          backgroundColor: Colors.deepPurpleAccent,
        ),
        body: SingleChildScrollView(
          child: notifyForm(),
        ));
  }

  notifyForm() {
    return Form(
        key: _formKey,
        child: SafeArea(
            child: Container(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                      labelText: 'Title', hintText: 'Notification title'),
                  validator: (value) {
                    _title = value;
                    if (value.isEmpty) {
                      return 'Enter title';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration:
                      InputDecoration(labelText: 'Body', hintText: 'Notification body'),
                  validator: (value) {
                    _body = value;
                    if (value.isEmpty) {
                      return 'Enter notification content';
                    }
                    return null;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: RaisedButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        notifyUser();
                        setState(() {});
                      }
                    },
                    child: Text('Notify'),
                  ),
                ),
              ],
            ),
          ),
        )));
  }

  notifyUser() async {
    try {
      CollectionReference notificationList = Firestore.instance.collection("notifications");
      await notificationList.add({
        "event": _title,
        "body": _body,
        "timestamp": DateTime.now(),
        "type": "generic"
      });
      Navigator.pop(context, true);
    } catch (e) {
      if (e != null && e.message != null) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              e.message,
              style: TextStyle(color: Colors.white),
            )));
      } else {
        _scaffoldKey.currentState
            .showSnackBar(SnackBar(content: Text('Notification Failed')));
      }
    }
  }
}

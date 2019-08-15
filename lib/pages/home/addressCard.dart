import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddressCard extends StatefulWidget{

  final AsyncSnapshot<DocumentSnapshot> eventData;

  AddressCard(this.eventData);

  @override
  State<StatefulWidget> createState() {
    return _AddressCardState();
  }

}

class _AddressCardState extends State<AddressCard>{
  @override
  Widget build(BuildContext context) {
    return Card(
        child: Container(
            padding: EdgeInsets.all(5.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.all(5),
                    child: RichText(
                      text: new TextSpan(
                        // Note: Styles for TextSpans must be explicitly defined.
                        // Child text spans will inherit styles from parent
                        style: new TextStyle(
                          fontSize: 14.0,
                          color: Colors.black,
                        ),
                        children: <TextSpan>[
                          new TextSpan(
                              text: 'Location: ',
                              style:
                                  new TextStyle(fontWeight: FontWeight.bold)),
                          new TextSpan(
                              text: (widget.eventData.data["location"] ?? ""))
                        ],
                      ),
                    ))
              ],
            )));
  }
  
}
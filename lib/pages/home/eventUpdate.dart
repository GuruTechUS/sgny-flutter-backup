import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sgny/utils/timeAgoCalculator.dart';
import 'package:flutter/material.dart';

class EventUpdateCard extends StatefulWidget{

  final String documentId;
  final double updatesCardHeight;

  EventUpdateCard(this.documentId, this.updatesCardHeight);

  @override
  State<StatefulWidget> createState() {
    return _EventUpdateCardState();
  }
}

class _EventUpdateCardState extends State<EventUpdateCard>{

  TimeAgoCalculator timeAgo = new TimeAgoCalculator();
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection("events")
                                .document(widget.documentId)
                                .collection("updates")
                                .orderBy("timestamp", descending: true)
                                .snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if(!snapshot.hasData){
          return CircularProgressIndicator();
        } else {
          //return ListView(children: getExpenseItems(snapshot));
          return scheduleList(context, snapshot);
        }
      },
    );
  }

  Widget scheduleList(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    int count = snapshot.data.documents != null ? snapshot.data.documents.length : 0;
    
    return count == 0 ? noUpdatesCard() : 
    Card(
        color: Colors.white70,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              title: Text("Event Updates"),
              pinned: true,
              automaticallyImplyLeading: false
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return Card(
                    color: Colors.amberAccent,
                    child: Container(
                      padding: EdgeInsets.all(10.0),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                updatesCard(snapshot.data.documents[index])
                              ],
                            )
                          ),
                        ],
                      )
                    ), //: noUpdatesCard(widget.updatesCardHeight),
                );
              },
              childCount: count
              ),
            )
        ])
      
    );
  }

  noUpdatesCard(){
    return Card(
      child: Container(
              padding: EdgeInsets.all(10.0),
              child: Center(
                child: Column(
                  children: <Widget>[
                    Image.asset(
                        'assets/images/no-updates.png',
                        width: MediaQuery.of(context).size.width - 40,
                        height: widget.updatesCardHeight - 80,
                      ),
                    Text("No New Updates")
                  ],
                )
              ),
            )
        );
  }  

  updatesCard(dynamic update){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
            timeAgo.calculate(update["timestamp"].toDate()),
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold
            ),
          ),
        Text(update["content"])
      ],
    );
    //Text(update["content"]);
  }
}
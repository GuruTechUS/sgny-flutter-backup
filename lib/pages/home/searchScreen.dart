
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sgny/utils/firebase_anon_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'eventDetails.dart';

class SearchScreen extends StatefulWidget {

  SearchScreen();

  @override
  State<StatefulWidget> createState() {
    return _SearchScreenState();
  }
}

class _SearchScreenState extends State<SearchScreen> {
  
  String genderValue="Boys & Girls";
  String categoryValue = "All Categories";
  String sportValue = "All Sports";
  String searchSrting = "";
  String userId;
  bool recordExist = false;

  bool isAdminLoggedIn = false;

  dynamic sport = {
    "soccer" : "Soccer",
    "basketball": "Basketball",
    "badminton": "Badminton",
    "volleyball": "Volleyball",
    "tabletennis": "Table Tennis",
    "track": "Track",
  };

  Stream<QuerySnapshot> eventStream = Firestore.instance.collection("events").snapshots();

  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  Map<String, dynamic> subscription = new Map<String, dynamic>();
  
  final FirebaseAnonAuth firebaseAnonAuth = new FirebaseAnonAuth();

  _SearchScreenState(){
    firebaseAnonAuth.isLoggedIn().then((user){
      if(user != null && user.uid != null){
        setState(() {
          this.userId = user.uid;
        });
        fetchUserPreferences();
      } else {
        firebaseAnonAuth.signInAnon().then((anonUser) {
          if(anonUser != null && anonUser.uid != null){
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
    return searchScreenLayout(context);
    
  }

  searchScreenLayout(BuildContext context){
    return StaggeredGridView.count(
      crossAxisCount: 1,
      crossAxisSpacing: 0.0,
      mainAxisSpacing: 0.0,
      children: <Widget>[
        Container(
          color: Colors.deepPurpleAccent.withOpacity(0.8),
          child: searchBar(context),
        ),
          fetchSearchResults(context)
        ],
      staggeredTiles: [
        StaggeredTile.extent(1, 60),
        StaggeredTile.extent(1, MediaQuery.of(context).size.height - 280),
      ],
    );
  }

  searchBar(BuildContext context){
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
          genderDropDown(),
          sportsDropDown(),
          categoryDropDown(),
          searchBarField()
        ],
      )
    );
  }

  genderDropDown(){
    return Container(
      decoration: new BoxDecoration(
                  color: Colors.white, //new Color.fromRGBO(255, 0, 0, 0.0),
                  borderRadius: new BorderRadius.only(
                    topLeft:  const  Radius.circular(25.0),
                    topRight: const  Radius.circular(25.0),
                    bottomLeft: const  Radius.circular(25.0),
                    bottomRight: const  Radius.circular(25.0))
                ),
                padding: EdgeInsets.only(left:10, right: 10),
                margin: EdgeInsets.all(5),
      child: DropdownButton<String>(
        hint: Text("Gender"),
        value: genderValue,
        onChanged: (String newValue) {
          setState(() {
            genderValue = newValue;
          });
          updateStream();
        },
        items: <String>['Boys & Girls', 'Boys', 'Girls']
          .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          })
          .toList(),
          )
      );   
  }

  categoryDropDown(){
    return Container(
      decoration: new BoxDecoration(
                  color: Colors.white, //new Color.fromRGBO(255, 0, 0, 0.0),
                  borderRadius: new BorderRadius.only(
                    topLeft:  const  Radius.circular(25.0),
                    topRight: const  Radius.circular(25.0),
                    bottomLeft: const  Radius.circular(25.0),
                    bottomRight: const  Radius.circular(25.0))
                ),
                padding: EdgeInsets.only(left:10, right: 10),
                margin: EdgeInsets.all(5),
      child: DropdownButton<String>(
        hint: Text("Category"),
        value: categoryValue,
        onChanged: (String newValue) {
          setState(() {
            categoryValue = newValue;
          });
          updateStream();
        },
        items: <String>['All Categories','u10', 'u14', 'u18', 'a18']
          .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          })
          .toList(),
          )
      );   
  }

  sportsDropDown(){
    return Container(
      decoration: new BoxDecoration(
                  color: Colors.white, //new Color.fromRGBO(255, 0, 0, 0.0),
                  borderRadius: new BorderRadius.only(
                    topLeft:  const  Radius.circular(25.0),
                    topRight: const  Radius.circular(25.0),
                    bottomLeft: const  Radius.circular(25.0),
                    bottomRight: const  Radius.circular(25.0))
                ),
                padding: EdgeInsets.only(left:10, right: 10),
                margin: EdgeInsets.all(5),
      child: DropdownButton<String>(
        hint: Text("Sport"),
        value: sportValue,
        onChanged: (String newValue) {
          setState(() {
            sportValue = newValue;
          });
          updateStream();
        },
        items: <String>['All Sports','Soccer', 'Basketball', 'Badminton', 'Volleyball', 'Table Tennis', 'Track']
          .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          })
          .toList(),
          )
      );   
  }

  searchBarField(){
    return Container(
      width: 200,
      decoration: new BoxDecoration(
                  color: Colors.white, //new Color.fromRGBO(255, 0, 0, 0.0),
                  borderRadius: new BorderRadius.only(
                    topLeft:  const  Radius.circular(25.0),
                    topRight: const  Radius.circular(25.0),
                    bottomLeft: const  Radius.circular(25.0),
                    bottomRight: const  Radius.circular(25.0))
                ),
                padding: EdgeInsets.only(left:10, right: 10, top:5),
                margin: EdgeInsets.all(5),
      child: Column(
          children: <Widget>[
            Expanded(
              child: TextField(
                onChanged: (data){
                  setState(() {
                    searchSrting = data;
                  });
                  updateStream();
                },
                decoration: new InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search team'
                ),
              )
            )
          ],
        )
      ); 
  }

  updateStream() {
    CollectionReference collectionRef = Firestore.instance.collection("events");
    bool gender;
    String sport;
    String category;

    if(genderValue == "Boys"){
      gender = true;
    } else if(genderValue == "Girls"){
      gender = false;
    } else {
      gender = null;
    }
    if(sportValue == "Soccer"){
      sport = "soccer";
    } else if(sportValue == "Basketball"){
      sport = "basketball";
    } else if(sportValue == "Volleyball"){
      sport = "volleyball";
    } else if(sportValue == "Track"){
      sport = "track";
    } else if(sportValue == "Badminton"){
      sport = "badminton";
    } else if(sportValue == "Table Tennis"){
      sport = "tabletennis";
    }

    if(categoryValue == "u10" || categoryValue == "u14" || categoryValue == "u18" || categoryValue == "a10"){
      category = categoryValue;
    } 

    eventStream = collectionRef.where("gender", isEqualTo: gender)
                                .where("sport", isEqualTo: sport)
                                .where("category", isEqualTo: category)
                                .snapshots();
  }

  fetchSearchResults(BuildContext context){
    return eventList(context);
  }

  Widget eventList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: eventStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if(!snapshot.hasData){
          return CircularProgressIndicator();
        } else {
          return Scaffold(
            body: Center(
              child: eventsListDisplay(snapshot),
            )
          );
        }
      },
    );
  }

  eventsListDisplay(AsyncSnapshot<QuerySnapshot> snapshot){

    List<dynamic> events = [];
    if(searchSrting != null && searchSrting != ""){
      events = snapshot.data.documents.where(
                                (event) => (
                                      (event["isTeamSport"] != null && event["isTeamSport"] == true) &&
                                      (event["teams"] != null && 
                                        (
                                          (event["teams"][0] != null && event["teams"][0]["name"].toString().toUpperCase().contains(searchSrting.toUpperCase())) || 
                                          (event["teams"][1] != null && event["teams"][1]["name"].toString().toUpperCase().contains(searchSrting.toUpperCase()))
                                        )
                                      )
                                    )
                                ).toList();
    } else {
      events = snapshot.data.documents;
    }

      return CustomScrollView(
        slivers: <Widget>[
          snapshot.data.documents.length == 0
            ? SliverFillRemaining(
              child:Card(
                child: Center(
                  child: Text("No search results found!"),
                ),
              ))
        : SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return InkWell(
                onTap: (){ 
                  Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) =>
                                     EventDetails(userId, events[index].documentID, (snapshot.data.documents[index]["gender"] ==true?"Boys":"Girls") + " / "+ snapshot.data.documents[index]["sport"] + " / "+snapshot.data.documents[index]["category"])));
                      
                },
                child: Card(
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            displayInfo(events[index]),
                            events[index]["isTeamSport"] != null &&
                            events[index]["isTeamSport"] == true ?
                             displayTeams(events[index]["teams"]) : Container(),
                            displayLocation(events[index]["location"]),
                            displayStatus(events[index]["status"])
                          ],
                        )
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          displayTimeAndDate(events[index]["startTime"]),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          subscribeToEvent(events[index].documentID),
                        ],
                      ) 
                    ],
                  )
                ),
              ));
            },
            childCount: events.length
            ),
          )
        ],
      );
  }

  displayInfo(event){
    return Text((event["gender"] == true ? "Boys":"Girls") + " / "+
              sport[event["sport"]] + " / " + event["category"]  
              );
  }

  displayTeams(teams) {
    if(teams != null && teams.length == 2){
      return Text(
        teams[0]["name"]+" vs "+teams[1]["name"],
        style: TextStyle(
            color: Colors.black,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: "WorkSansSemiBold"
          )
        );
    } else if(teams != null && teams.length == 1){
      return Text(
        teams[0]["name"]+" vs --",
         style: TextStyle(
            color: Colors.black,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: "WorkSansSemiBold"
          ));
    } else if(teams != null && teams.length >= 2){
      return Text("");
    } else {
      return Text("");
    }                     
  }
  displayLocation(location) {
    if(location != null){
      return Text(
        "Location: " + location,
        textAlign: TextAlign.left);
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

  displayTimeAndDate(Timestamp startTime){
    if(startTime != null){
      DateTime date = startTime.toDate();
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          getTime(date),
          getDate(date),        
      ]);
    } else {
      return Container();
    }
    
  }

  getDate(DateTime startTime){
    if(startTime != null){
      return Text(startTime.day.toString()+" "+months[startTime.month - 1]);
    } else {
      return Text("");
    }
  }

  getTime(DateTime startTime){
    if(startTime != null){
      String padding = startTime.minute <= 9 ? "0": "";
      String hour = startTime.hour.toString();
      String sufix = "AM";
      if(startTime.hour >= 12){
        hour = (startTime.hour-12).toString();
        if(hour == '0'){
          hour = '12';
        }
        sufix = "PM";
      }
      return Text(
        hour
        +":"
        +padding
        +startTime.minute.toString()
        +" "
        +sufix,
        style: TextStyle(
          fontSize: 24.0    
        ));
    } else {
      return Text("");
    }
  }
  
  displayStatus(String status){
    if(status != null){
      return Text("Status: " + status);
    } else {
      return Text("");
    } 
  }

  
  subscribeToEvent(documentID){
    subscription.putIfAbsent(documentID, () => false);
    return Container(
      padding: EdgeInsets.all(10.0),
      child: InkWell(
            onTap: () {
              updateData(documentID);
            },
            child: Image.asset(
                 subscription[documentID]?"assets/images/bell-solid.png":"assets/images/bell-regular.png",
                width: 30,
              )));
  }

  updateData(key){
    DocumentReference subscriptionDocumentReference =  Firestore.instance.collection("devices").document("preferences").collection(this.userId).document("subscriptions");
    if(!subscription[key]){
      subscribeToTopic(key);
    } else {
      unSubscribeToTopic(key);
    }
    if(!recordExist){
      subscriptionDocumentReference.setData({key: !subscription[key]});
    } else {
      subscriptionDocumentReference.updateData({key: !subscription[key]});
    }
  }

  subscribeToTopic(key){
    firebaseMessaging.subscribeToTopic(key);
  }

  unSubscribeToTopic(key){
    firebaseMessaging.unsubscribeFromTopic(key);
  }

  fetchSubscriptionData(){
    Stream<DocumentSnapshot> subscriptionSnapshot = Firestore.instance.collection("devices").document("preferences").collection(this.userId).document("subscriptions").snapshots();
  
    subscriptionSnapshot.listen((documentData) {
      if (!mounted) return;
      setState(() {
        if(documentData.data == null){
          subscription = {};
        } else {
          subscription = documentData.data;
          recordExist = true;
        }
      });
    });   
  }
}

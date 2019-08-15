import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  String location = '';
  String round = '';
  String status = '';
  DateTime startTime = DateTime.now();

  String category = '';
  String sport = '';
  bool gender = false;

  bool isTeamSport = false;
  List teams;

  setTeamSport(bool value){
    if(value != null){
      isTeamSport = value;
    }
  }

  getTeamSport(){
    return isTeamSport;
  }

  save() async {
    CollectionReference eventList = Firestore.instance.collection("events");
    await eventList.add({
      "category": category,
      "sport": sport,
      "gender": gender,
      "location": location,
      "round": round,
      "status": status,
      "startTime": startTime,
      "isTeamSport": isTeamSport,
      "teams": teams
    });
    return true;
  }

  update(String documentId) {
    print(startTime);
    Firestore.instance.collection("events").document(documentId).updateData({
      "category": category,
      "sport": sport,
      "gender": gender,
      "location": location,
      "round": round,
      "status": status,
      "startTime": startTime,
      "isTeamSport": isTeamSport,
      "teams": teams
    });
    return true;
  }

  setTeamList() {
    teams = [];
    Map<String, dynamic> team1 = Map<String, dynamic>();
    Map<String, dynamic> team2 = Map<String, dynamic>();
    teams.add(team1);
    teams.add(team2);
  }

  void setTeamA(teamName) {
    if (teams == null || teams.length != 2) {
      setTeamList();
    }
    teams[0]["name"] = teamName;
    teams[0]["score"] = 0;
  }

  getTeamA() {
    if (teams == null || teams.length != 2) {
      return "";
    } else {
      return teams[0]["name"];
    }
  }

  void updateTeamA(teamName) {
    if (teams == null || teams.length != 2) {
      setTeamList();
    }
    teams[0]["name"] = teamName;
    if (teams[0]["score"] == null) {
      teams[0]["score"] = 0;
    }
  }

  void setTeamB(teamName) {
    if (teams == null || teams.length != 2) {
      setTeamList();
    }
    teams[1]["name"] = teamName;
    teams[1]["score"] = 0;
  }

  void updateTeamB(teamName) {
    if (teams == null || teams.length != 2) {
      setTeamList();
    }
    teams[1]["name"] = teamName;
    if (teams[1]["score"] == null) {
      teams[1]["score"] = 0;
    }
  }

  getTeamB() {
    if (teams == null || teams.length != 2) {
      return "";
    } else {
      return teams[1]["name"];
    }
  }

  resetTeamList() {
    teams = null;
  }
}

class DocumentReference {}

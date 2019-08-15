import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:sgny/model/eventModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditEvent extends StatefulWidget{
  final String documentId;

  EditEvent(this.documentId);

  @override
  State<StatefulWidget> createState() {
    return _EditEventState();
  }

}

class _EditEventState extends State<EditEvent>{

  final _formKey = GlobalKey<FormState>();
  EventModel _event;
  final dateFormat2 = DateFormat("d MMMM yyyy 'at' hh:mm:ss a");
  bool isSubmitting = false;
  bool firstLoad = true;
  

  @override
  void initState() {
    _event = EventModel();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurpleAccent,
        ),
        body: SingleChildScrollView(
          child: isSubmitting ? submitIndecator(context) : streamBulderForEvent(context)//addEventForm(context),
        ),
    );
  }

  streamBulderForEvent(BuildContext context){
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance.collection("events").document(widget.documentId).snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if(!snapshot.hasData){
          return CircularProgressIndicator();
        } else {
          return addEventForm(context, snapshot);
        }
      },
    );
  }

  fetchEventData(eventData) {
        if(firstLoad == true && eventData != null && eventData.data != null){
          _event.location = eventData.data["location"];
          _event.round = eventData.data["round"];
          _event.status = eventData.data["status"];
          _event.sport = eventData.data["sport"];
          _event.category = eventData.data["category"];
          _event.gender = eventData.data["gender"];
          if(eventData.data["isTeamSport"] == true){
               _event.isTeamSport = !_event.isTeamSport;
          }
          _event.startTime = (eventData.data["startTime"] as Timestamp).toDate();
          _event.teams = eventData.data["teams"];
          firstLoad = false;
        }
      
  }

  Widget addEventForm(BuildContext context, AsyncSnapshot<dynamic> snapshot) {
    fetchEventData(snapshot);
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
                    initialValue: _event.round,
                    decoration: InputDecoration(
                      labelText: 'Round'
                    ),
                    validator: (value) {
                      _event.round = value;
                      if (value.isEmpty) {
                        return 'Enter round details';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    initialValue: _event.status,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      hintText: 'Scheduled, On Time..'
                    ),
                    validator: (value) {
                      _event.status = value;
                      if (value.isEmpty) {
                        return 'Enter status';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    initialValue: _event.location,
                    decoration: InputDecoration(
                      labelText: 'Location',
                      hintText: 'Ground details'
                    ),
                    validator: (value) {
                      _event.location = value;
                      if (value.isEmpty) {
                        return 'Enter location';
                      }
                      return null;
                    }
                  ),
                  DateTimePickerFormField(
                    initialValue: _event.startTime,
                    decoration: InputDecoration(
                      labelText: 'Start Date & Time',
                    ),
                    format: dateFormat2,
                    onChanged: (dateTime) {
                      if(dateTime != null){
                        setState(() {
                            _event.startTime = dateTime;
                        });
                      }
                    },
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          "Team Sport",
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 18
                          ),
                        ),
                      ),
                      Switch(
                        value: _event.isTeamSport,
                        onChanged: (value) {
                          setState(() {
                            _event.isTeamSport = value;
                            if(value){
                              _event.setTeamList();
                            } else {
                              _event.resetTeamList();
                            }
                          });
                        },
                        activeTrackColor: Colors.lightGreenAccent, 
                        activeColor: Colors.green,
                      ),
                    ],
                  ),
                  _event.isTeamSport ? teamDetails(context) : Container(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: RaisedButton(
                      onPressed: () {
                        // Validate returns true if the form is valid, or false
                        // otherwise.
                        if (_formKey.currentState.validate()) {
                          // If the form is valid, display a Snackbar.
                          //_event.gender = widget.gender == null ? widget.gender : false;
                          //_event.category = widget.category;
                          //_event.sport = widget.sport;
                          setState(() {
                            isSubmitting = true;
                          });
                            _event.update(widget.documentId);
                            Navigator.pop(context);
                        }
                      },
                      child: Text('Update'),
                    ),
                  ),
                ],
              ), 
            ),
          )
      )
    );
  }

  teamDetails(BuildContext context){
    return Column(
      children: <Widget>[
        TextFormField(
          initialValue: _event.getTeamA(),
          decoration: InputDecoration(
            labelText: 'Team A Name'
          ),
          validator: (val){
            _event.updateTeamA(val);
          },
        ),
        TextFormField(
          initialValue: _event.getTeamB(),
          decoration: InputDecoration(
            labelText: 'Team B Name'
          ),
          validator: (val){
            _event.updateTeamB(val);
          },
        ),
      ],
    );
  }

  submitIndecator(BuildContext context){
    return Container(
        height: MediaQuery.of(context).size.height - 100,
        child: Center(
            child: new CircularProgressIndicator(),
          )
        );
  }
}
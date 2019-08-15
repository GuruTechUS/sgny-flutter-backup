import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:sgny/model/eventModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddEvent extends StatefulWidget{
  final bool gender;
  final String sport;
  final String category;

  AddEvent(this.gender, this.sport, this.category);

  @override
  State<StatefulWidget> createState() {
    return _AddEventState();
  }

}

class _AddEventState extends State<AddEvent>{

  final _formKey = GlobalKey<FormState>();
  EventModel _event = EventModel();
  final dateFormat = DateFormat("EEEE, MMMM d, yyyy 'at' h:mma");
  final dateFormat2 = DateFormat("d MMMM yyyy 'at' hh:mm:ss a");
  bool isSubmitting = false;
  
  _AddEventState();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurpleAccent,
        ),
        body: SingleChildScrollView(
          child: isSubmitting ? submitIndecator(context) : addEventForm(context),
        ),
    );
  }

  Widget addEventForm(BuildContext context) {
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
                    decoration: InputDecoration(
                      labelText: 'Start Date & Time',
                    ),
                    format: dateFormat2,
                    onChanged: (dateTime) {
                      if(dateTime != null){
                        _event.startTime = dateTime;
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
                          if(widget.gender == true){
                            _event.gender = !_event.gender;
                          }
                          _event.category = widget.category;
                          _event.sport = widget.sport;
                          setState(() {
                            isSubmitting = true;
                          });
                          _event.save();
                          Navigator.pop(context);
                        }
                      },
                      child: Text('Add'),
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
          decoration: InputDecoration(
            labelText: 'Team A Name'
          ),
          validator: (val){
            _event.setTeamA(val);
          },
        ),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Team B Name'
          ),
          validator: (val){
            _event.setTeamB(val);
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
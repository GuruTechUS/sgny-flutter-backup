import 'dart:io';

import 'package:easy_dialog/easy_dialog.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:url_launcher/url_launcher.dart';

import 'searchScreen.dart';
import 'package:sgny/utils/tab_indication_painter.dart';
import 'package:flutter/material.dart';
import 'scheduleScreen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _MainScreenState();
  }
}

class _MainScreenState extends State<MainScreen> {
  bool _isSearchSelected = false;
  Color left = Colors.black;
  Color right = Colors.white;
  bool displayDialog = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setStatusBarColor();
    return Scaffold(
      body: staggeredView(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _launchURL("https://www.google.com/maps/place/Robert+M.+Finley+Middle+School/@40.8711936,-73.6305071,17z/data=!3m1!4b1!4m5!3m4!1s0x89c2851af29a52eb:0xe38aab0d7f82b05!8m2!3d40.8711936!4d-73.6283184");
        },
        icon: Icon(Icons.location_on),
        label: Text("Event Location"),
      ),
    );
  }  

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  displayWelcomeDialog() {
    double heigh = (MediaQuery.of(context).size.height - 80.0);
    double width = (MediaQuery.of(context).size.width - 20.0);
    if(heigh > (width * 1.49053857351)){
      heigh = width * 1.49053857351;
    } else {
      width = heigh * 0.6708984375;
    }
    if (displayDialog) {
      //displayDialog = false;
      EasyDialog(
          cornerRadius: 10.0,
          fogOpacity: 0.1,
          height: heigh,
          width: width,
          contentPadding: EdgeInsets.all(10.0), // Needed for the button design
          contentList: [
            Container(
                child: Image(
                    image: NetworkImage(
                        "https://firebasestorage.googleapis.com/v0/b/sgny-app.appspot.com/o/2019%2F2019-08-02%2020:36:21.108647.jpg?alt=media&token=ee697845-545e-4429-a6dd-ab45566af543"),
                    fit: BoxFit.cover)),
          ]).show(context);
    }
  }

  Widget staggeredView(BuildContext context) {
    return StaggeredGridView.count(
      crossAxisCount: 1,
      crossAxisSpacing: 10.0,
      mainAxisSpacing: 10.0,
      //padding: EdgeInsets.all(5.0),
      children: <Widget>[header(context), homeBodyContent(context)],
      staggeredTiles: [
        StaggeredTile.extent(1, 110),
        StaggeredTile.extent(1, MediaQuery.of(context).size.height - 220),
      ],
    );
  }

  setStatusBarColor() async {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white, // Color for Android
        statusBarBrightness:
            Brightness.light // Dark == white status bar -- for IOS.
        ));
  }

  header(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 10.0), child: _buildLogo(context)),
        Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: _buildMenuBar(context),
        ),
      ],
    );
  }

  Widget homeBodyContent(BuildContext context) {
    return _isSearchSelected
        ? _searchScreen()
        : SingleChildScrollView(
            //SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height >= 650.0
                  ? MediaQuery.of(context).size.height
                  : 650.0,
              decoration: new BoxDecoration(
                gradient: new LinearGradient(
                    colors: [Colors.white, Colors.white],
                    begin: const FractionalOffset(0.0, 0.0),
                    end: const FractionalOffset(1.0, 1.0),
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp),
              ),
              child: Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
                Container(
                  child: _categoryList(context),
                )
              ]),
            ),
          );
  }

  _searchScreen() {
    return Container(
      //height: 60,
      width: MediaQuery.of(context).size.width,
      child: SearchScreen(),
    );
    //
  }

  Widget _categoryList(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: EdgeInsets.only(left: 35.0, top: 10.0),
              child: Text(
                "Girls",
                style: TextStyle(
                    color: Colors.pinkAccent,
                    fontSize: 24.0,
                    fontFamily: "WorkSansSemiBold"),
              ),
            ),
          ),
          _buildCards(context, false),
          Container(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: EdgeInsets.only(left: 35.0, top: 10.0),
                child: Text(
                  "Boys",
                  style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 24.0,
                      fontFamily: "WorkSansSemiBold"),
                ),
              )),
          _buildCards(context, true),
        ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          child: SpinKitRipple(
            color: Colors.deepPurple,
            size: 100.0,
          ),
        ),
        Positioned(
            left: 20.0,
            top: 20.0,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(30.0),
                child: Container(
                    decoration: BoxDecoration(color: Colors.white),
                    child: Padding(
                      padding: EdgeInsets.all(0.0),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 60.0,
                        height: 60.0,
                      ),
                    ))))
      ],
    );
  }

  Widget _buildMenuBar(BuildContext context) {
    var flatButton = FlatButton(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onPressed: _onHomSelected,
      child: Text(
        "Home",
        style: TextStyle(
            color: left, fontSize: 16.0, fontFamily: "WorkSansSemiBold"),
      ),
    );
    return Container(
        width: 200.0,
        height: 50.0,
        decoration: BoxDecoration(
          color: Colors.deepPurpleAccent, //Color(0x552B2B2B),
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
        child: Column(
          children: <Widget>[
            CustomPaint(
              painter: TabIndicationPainter(position: _isSearchSelected),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: flatButton,
                  ),
                  //Container(height: 33.0, width: 1.0, color: Colors.white),
                  Expanded(
                    child: FlatButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onPressed: _onSearchSelected,
                      child: Text(
                        "Search",
                        style: TextStyle(
                            color: right,
                            fontSize: 16.0,
                            fontFamily: "WorkSansSemiBold"),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }

  void _onHomSelected() {
    setState(() {
      this._isSearchSelected = false;
      this.left = Colors.deepPurple;
      this.right = Colors.white;
    });
  }

  void _onSearchSelected() {
    setState(() {
      this._isSearchSelected = true;
      this.right = Colors.deepPurple;
      this.left = Colors.white;
    });
  }

  Widget _buildCards(BuildContext context, bool gender) {
    final sportsList = [
      {"name": "soccer", "title": "Soccer"},
      {"name": "basketball", "title": "Basketball"},
      {"name": "badminton", "title": "Badminton"},
      {"name": "volleyball", "title": "Volleyball"},
      {"name": "tabletennis", "title": "Table Tennis"},
      {"name": "track", "title": "Track"}
    ];
    return Container(
        child: Padding(
            padding: EdgeInsets.only(left: 0.0, top: 10.0),
            child: SizedBox(
              height: 220.0,
              child: ListView.builder(
                itemCount: sportsList.length,
                padding: EdgeInsets.only(left: 30.0),
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  return _buildSportCard(
                      context, index, sportsList[index], gender);
                },
              ),
            )));
  }

  Widget _buildSportCard(
      BuildContext context, int index, dynamic sportsItem, bool gender) {
    final categoryList = [
      {"name": "u10", "desc": "Under 10"},
      {"name": "u14", "desc": "Under 14"},
      {"name": "u18", "desc": "Under 18"},
      {"name": "a18", "desc": "18 & Above"}
    ];
    return Container(
      width: 180.0,
      child: Card(
          color: gender ? Colors.blueAccent : Colors.pinkAccent,
          elevation: 5.0,
          child: Wrap(
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 5.0),
                  child: Center(
                      child: Text(
                    sportsItem["title"],
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: "WorkSansSemiBold"),
                  ))),
              Container(
                width: 180.0,
                height: 180.0,
                child: GridView.builder(
                    itemCount: categoryList.length,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2),
                    itemBuilder: (BuildContext context, int index) {
                      return _categoryItem(context, index, sportsItem,
                          categoryList[index], gender);
                    }),
              )
              /**/
            ],
          )),
    );
  }

  Widget _categoryItem(BuildContext context, int index, dynamic sportsItem,
      dynamic button, bool gender) {
    return Center(
        child: Stack(children: <Widget>[
      Positioned(
          top: 10.0,
          child: MaterialButton(
            shape: new CircleBorder(),
            elevation: 0.0,
            padding: const EdgeInsets.all(15.0),
            color: Colors.white,
            child: Transform.rotate(
                angle: -0.5,
                child: Text(
                  button['name'],
                  style: TextStyle(
                      color: gender ? Colors.blueAccent : Colors.pinkAccent,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: "WorkSansSemiBold"),
                )),
            onPressed: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (context) {
                return ScheduleScreen(sportsItem, button, gender);
              }));
              Future.delayed(const Duration(milliseconds: 150), () {
                updateStatusBarColor();
              });
              Future.delayed(const Duration(milliseconds: 500), () {
                updateStatusBarColor();
              });
            },
          )),
      Positioned(
          top: 60.0,
          child: Container(
              width: 88.0,
              child: Center(
                  child: Text(
                button['desc'],
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: "WorkSansSemiBold"),
              ))))
    ]));
  }

  updateStatusBarColor() {
    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.white, // Color for Android
          statusBarBrightness: Brightness.dark));
    } else if (Platform.isIOS) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.white, // Color for Android
          statusBarBrightness:
              Brightness.light // Dark == white status bar -- for IOS.
          ));
    }
    setState(() {});
  }
}

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sgny/pages/gallery/photoView.dart';
import 'package:sgny/utils/firebase_anon_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:image_picker/image_picker.dart';

import 'package:image/image.dart' as IMG;
import 'package:path_provider/path_provider.dart';

class Gallery extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.deepPurpleAccent, // Color for Android
                statusBarBrightness: Brightness.light // Dark == white status bar -- for IOS.
              ));
    } else if (Platform.isIOS) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.white, // Color for Android
                statusBarBrightness: Brightness.light // Dark == white status bar -- for IOS.
              ));
    }
    return _GalleryState();
  }
}

class _GalleryState extends State<Gallery> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  StreamSubscription<QuerySnapshot> subscription;
  List<DocumentSnapshot> photoList;
  final CollectionReference collectionReference =
      Firestore.instance.collection("gallery");

  final FirebaseAnonAuth firebaseAnonAuth = new FirebaseAnonAuth();

  dynamic appConfig = {};

  String userId;
  bool isAdminLoggedIn = false;

  _GalleryState() {
    firebaseAnonAuth.isLoggedIn().then((user) {
      if (user != null && user.uid != null) {
        setState(() {
          this.userId = user.uid;
          if (user.isAnonymous == false) {
            isAdminLoggedIn = true;
          }
        });
      }
    });

    Firestore.instance
        .collection("app")
        .document("config")
        .snapshots()
        .listen((onData) {
      if (onData != null) {
        appConfig = onData.data;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    subscription = collectionReference.snapshots().listen((datasnapshot) {
      setState(() {
        photoList = datasnapshot.documents;
      });
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: Text("Gallery"),
          backgroundColor: Colors.deepPurpleAccent,
          actions: <Widget>[
            isAdminLoggedIn
                ? IconButton(
                    icon: Icon(Icons.add),
                    tooltip: 'Add Photo',
                    onPressed: () {
                      openGallery();
                    },
                  )
                : FlatButton.icon(
                    icon: Icon(Icons.send),
                    splashColor: Colors.white,
                    label: Text('Add photos'),
                    textColor: Colors.white,
                    onPressed: () async {
                      _scaffoldKey.currentState.showSnackBar(SnackBar(
                          backgroundColor: Colors.amber,
                          content: Text(
                            appConfig["submit_photos_message"] != null
                                ? appConfig["submit_photos_message"]
                                : 'Send us your photos on whatsapp. We will add them to the gallery once reviewed!',
                            style: TextStyle(color: Colors.black),
                          )));
                      if (appConfig["submit_photos"] != null ||
                          appConfig["submit_photos_backup"] != null) {
                        try {
                          if (await canLaunch(
                              Uri.encodeFull(appConfig["submit_photos"]))) {
                            _launchURL(
                                Uri.encodeFull(appConfig["submit_photos"]));
                          } else if (await canLaunch(Uri.encodeFull(
                              appConfig["submit_photos_backup"]))) {
                            _launchURL(Uri.encodeFull(
                                appConfig["submit_photos_backup"]));
                          }
                        } catch (e) {
                          _launchURL(Uri.encodeFull(
                              "https://web.whatsapp.com/send?phone=14123453825&text=&source=&data="));
                        }
                      } else {
                        _launchURL(Uri.encodeFull(
                            "https://web.whatsapp.com/send?phone=14123453825&text=&source=&data="));
                      }
                    },
                  )
          ],
        ),
        body: photoList != null
            ? new StaggeredGridView.countBuilder(
                padding: const EdgeInsets.all(8.0),
                crossAxisCount: 4,
                itemCount: photoList.length,
                itemBuilder: (context, i) {
                  return new Material(
                    elevation: 8.0,
                    borderRadius:
                        new BorderRadius.all(new Radius.circular(8.0)),
                    child: new InkWell(
                      onTap: () async {
                        await Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) =>
                                    PhotoViewer(i, isAdminLoggedIn)));
                        Future.delayed(const Duration(milliseconds: 150), () {
                            updateStatusBarColor();
                        });
                        Future.delayed(const Duration(milliseconds: 500), () {
                            updateStatusBarColor();
                        });
                      },
                      child: new Hero(
                        tag: photoList[i].documentID,
                        child: new FadeInImage(
                          image: new NetworkImage(photoList[i].data['thumbnailUrl'] ?? photoList[i].data['url']),
                          fit: BoxFit.cover,
                          placeholder:
                              new AssetImage("assets/images/placeholder.png"),
                        ),
                      ),
                    ),
                  );
                },
                staggeredTileBuilder: (i) =>
                    new StaggeredTile.count(2, i.isEven ? 2 : 3),
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
              )
            : new Center(
                child: new CircularProgressIndicator(),
              ));
  }

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  updateStatusBarColor(){
    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.deepPurpleAccent, // Color for Android
                statusBarBrightness: Brightness.light // Dark == white status bar -- for IOS.
              ));
    } else if (Platform.isIOS) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.white, // Color for Android
                statusBarBrightness: Brightness.light // Dark == white status bar -- for IOS.
              ));
    }
  }

  Future openGallery() async {
    File picture = await ImagePicker.pickImage(source: ImageSource.gallery);
    uploadImageToStorage(picture);
  }

  uploadImageToStorage(File picture) async {
    List<String> fileNameSplit = picture.toString().split(".");
    String fileName = DateTime.now().toString() +
        "." +
        fileNameSplit[fileNameSplit.length - 1];
    fileName = fileName.split("'")[0];

    File thumbnail = await generateThumbnail(picture, "thumbnail_" + fileName);

    
    final StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child("2019/" + fileName);
    final StorageUploadTask storageUploadTask =
        firebaseStorageRef.putFile(picture);

    final StorageTaskSnapshot downloadUrl =
        (await storageUploadTask.onComplete);
    final String url = (await downloadUrl.ref.getDownloadURL());


    /* Thumbnail */

    final StorageReference firebaseStorageThumbnailRef =
        FirebaseStorage.instance.ref().child("2019_thumbnails/" + fileName);
    final StorageUploadTask storageUploadThumbnailTask =
        firebaseStorageThumbnailRef.putFile(thumbnail);

    final StorageTaskSnapshot thumbnailDownloadUrl =
        (await storageUploadThumbnailTask.onComplete);
    final String thumbnailUrl = (await thumbnailDownloadUrl.ref.getDownloadURL());

    if (url != null && thumbnailUrl != null) {
      saveLinkToFireStore(url, thumbnailUrl);
    } else {
       _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(
          "Uploaded Failed!",
          style: TextStyle(color: Colors.white),
        )));
    }
    
  }

  Future<File> generateThumbnail(File picture, filename) async {
    final bytes = await picture.readAsBytes();

    IMG.Image image = IMG.decodeImage(bytes);
    IMG.Image thumbnail = IMG.copyResize(
      image,
      width: 400,
    );
    File tn = await _localFile(filename);
    tn.writeAsBytesSync(IMG.encodePng(thumbnail));
    print(picture.lengthSync());
    print(tn.lengthSync());
    return tn;
  }

  Future<String> get _localPath async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  Future<File> _localFile(String fileName) async {
  final path = await _localPath;
  return File('$path/$fileName');
}

  saveLinkToFireStore(String url, String thumbnailUrl) async {
    await Firestore.instance.collection("gallery").add({
      "url": url,
      "thumbnailUrl": thumbnailUrl
    });

    _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: Colors.amber,
        content: Text(
          "Uploaded Successfully..!",
          style: TextStyle(color: Colors.black),
        )));
  }
}

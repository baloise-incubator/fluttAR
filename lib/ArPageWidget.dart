import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'Location.dart';

class ArPageWidget extends StatelessWidget {
  static const platform = const MethodChannel('com.baloise/ARKit');
  static const String COLLECTION_NAME = "Locations";

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('ARKit in Flutter')),
      body: Container(
          child: RaisedButton(
        child: Text('start AR'),
        onPressed: _startARSesssionAndSetLocations,
      )));

  Future<void> _startARSesssionAndSetLocations() async {
    _startARSesssion();
    initDatabase();

    platform.setMethodCallHandler((MethodCall call) async {
      print("Flutter received call for" + call.method);
      if (call.method == "dispatchLocation") {
        print("Arguments received are : ${call.arguments}");
        var arguments = call.arguments;
        Location location =
            new Location(arguments[0], arguments[1], arguments[2]);
        _persistToDB(location);
      }
    });
  }

  Future<void> _startARSesssion() async {
    try {
      await platform.invokeMethod('startARSession');
      print("AR Session started");
    } on PlatformException catch (e) {
      print("AR Session not started - " + e.toString());
    }
  }

  Future<void> _transmitLocationInformation(Location loc) async {
    try {
      List<double> list =
          {loc.latitude, loc.longitude, loc.meterOverNull}.toList();
      final int result = await platform.invokeMethod('setLocation', list);
      print("Location send");
    } on PlatformException catch (e) {
      print("Location not send - " + e.toString());
    }
  }

  Future<void> _persistToDB(Location location) async {
    await Firebase.initializeApp();
    print("Saving information");
    print(location.toDataStoreMap());
    print(location.identifyingName());
    FirebaseFirestore.instance
        .collection(COLLECTION_NAME)
        .doc(location.identifyingName())
        .set(location.toDataStoreMap());
  }

  Future<void> initDatabase() async {
    await Firebase.initializeApp();
    FirebaseFirestore.instance
        .collection(COLLECTION_NAME)
        .snapshots()
        .listen((event) {
      event.docChanges.forEach((element) {
        if (element.type == DocumentChangeType.added) {
          var data = element.doc.data();
          print("Document Added event received");
          _transmitLocationInformation(Location.fromDataStoreMap(data));
        }
      });
    });
  }
}

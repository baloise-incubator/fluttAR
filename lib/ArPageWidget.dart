import 'package:fluttAR/DatabaseHandler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'Location.dart';

class ArPageWidget extends StatelessWidget {
  static const platform = const MethodChannel('com.baloise/ARKit');
  static const String COLLECTION_NAME = "Locations";

  DataBaseHandler handler;

  ArPageWidget(DataBaseHandler handler){
    this.handler = handler;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      body: Container(
          child: RaisedButton(
        child: Text('start AR'),
        onPressed: _startARSesssionAndSetLocations,
      ),
      ));

  Future<void> _startARSesssionAndSetLocations() async {
    _startARSesssion();

    platform.setMethodCallHandler((MethodCall call) async {
      print("Flutter received call for" + call.method);
      if (call.method == "dispatchLocation") {
        print("Arguments received are : ${call.arguments}");
        var arguments = call.arguments;
        Location location =
            new Location(arguments[0], arguments[1], arguments[2]);
        handler.persistToDB(location);
      }
    });
  }

  Future<void> _startARSesssion() async {
    try {
      await platform.invokeMethod('startARSession');
      List<Function> functionList = new List<Function>();
      functionList.add((loc) =>{ this.receivedLocationInformation(loc)});
      handler.addListeners(functionList);
      print("AR Session started");
    } on PlatformException catch (e) {
      print("AR Session not started - " + e.toString());
    }
  }

  Future<void> receivedLocationInformation(Location loc) async {
    try {
      print("AR:ADD:CALLED");
      List<dynamic> list =
          {loc.latitude, loc.longitude, loc.meterOverNull, loc.name}.toList();
      final int result = await platform.invokeMethod('setLocation', list);
      print("Location set");
    } on PlatformException catch (e) {
      print("Location not set - " + e.toString());
    }
  }


}

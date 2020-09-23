import 'dart:developer';
import 'dart:ffi';

import 'package:fluttAR/Location.dart';
import 'package:flutter/material.dart';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const platform = const MethodChannel('com.baloise/ARKit');
  ARKitController arkitController;
  String anchorId;
  ARKitSphere sphere;

  @override
  void dispose() {
    arkitController?.dispose();
    super.dispose();
  }

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
    _transmitLocationInformation();

    platform.setMethodCallHandler((MethodCall call) async {
      print("Flutter received call for" + call.method);
      if(call.method == "dispatchLocation") {
        print("Arguments received are : ${call.arguments}");
        var arguments = call.arguments;
          Location location = new Location(
              arguments[0], arguments[1], arguments[2]);
          _persistToDB(location);
        }
    });

  }

  Future<void> _startARSesssion() async {
    try {
      final int result = await platform.invokeMethod('startARSession');
      print("AR Session started");
    } on PlatformException catch (e) {
      print("AR Session not started - " + e.toString());
    }
  }

  Future<void> _transmitLocationInformation() async {
    try {
      Location loc = new Location(46.536671, 7.962324, 4158);
      List<double> list = {loc.latitude, loc.longitude, loc.meterOverNull}.toList();
      final int result = await platform.invokeMethod('setLocation', list);
      print("Location send");
    } on PlatformException catch (e) {
      print("Location not send - " + e.toString());
    }
  }

  Future<void> _persistToDB(Location location) async {
    print("Saving information");
  }

}

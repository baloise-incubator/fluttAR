import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttAR/DatabaseHandler.dart';
import 'package:fluttAR/main.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'Location.dart';

class MapPageWidget extends StatelessWidget {
  GoogleMapController mapController;

  static const String COLLECTION_NAME = "Locations";

  Set<Marker> _markers = new HashSet<Marker>();
  int markerIDCounter = 0;
  LatLng center;

  MyAppState state;

  MapPageWidget( LatLng center, MyAppState appstate) {
    this.center = center;
    this.state = appstate;
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void receivedLocationInformation(Location loc) {
    print("MAP:ADD:CALLED");
    _setMarker(LatLng(loc.latitude, loc.longitude), true);
  }

  void _setMarker(LatLng point, bool dontStore) {
    this.state.setState(() {
      print("Updating state");
      final String markerIDVal = "ID${markerIDCounter}";
      markerIDCounter++;
      _markers.add(
        Marker(
          markerId: MarkerId(markerIDVal),
          position: point,
        ),
      );
      Location loc = Location(point.latitude, point.longitude, 1200);
      if (!dontStore) {
        persistToDB(loc);
      }
    });
    //this.build(this.state.context);
  }


  Future<void> persistToDB(Location location) async {
    await Firebase.initializeApp();
    print("Saving information");
    print(location.toDataStoreMap());
    print(location.identifyingName());
    FirebaseFirestore.instance
        .collection(COLLECTION_NAME)
        .doc(location.identifyingName())
        .set(location.toDataStoreMap());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: this.center,
              zoom: 11.0,
            ),
            markers: _markers,
            myLocationEnabled: true,
            onTap: (point) {
              _setMarker(point, false);
            }),
      ),
    );
  }
}

import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttAR/main.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'Location.dart';

class MapPageWidget extends StatefulWidget {

  LatLng center;

  MapPageWidget( LatLng center) {
    this.center = center;
  }

  @override
    MapState createState() => MapState(center);
}

class MapState extends State<MapPageWidget> {

  GoogleMapController mapController;
  LatLng center;

  Set<Marker> _markers = new HashSet<Marker>();
  int markerIDCounter = 0;

  static const String COLLECTION_NAME = "Locations";

  MapState(LatLng center){
    this.center = center;
  }

  @override
  void initState() {
    initMarkers();
  }

  Future<void> initMarkers() async {
    await Firebase.initializeApp();
    FirebaseFirestore.instance
        .collection(COLLECTION_NAME).get().then((value) => {
          value.docs.forEach((element) {
            var map = element.data();
            var latitude = map["latitude"];
            var longitude = map["longitude"];
            _setMarker(LatLng(latitude, longitude), true);
          })
    });
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


  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void receivedLocationInformation(Location loc) {
    print("MAP:ADD:CALLED");
    _setMarker(LatLng(loc.latitude, loc.longitude), true);
  }

  void _setMarker(LatLng point, bool dontStore) {
    setState(() {
      print("Updating state");
      final String markerIDVal = "ID${markerIDCounter}";
      markerIDCounter++;
      _markers.add(
        Marker(
          markerId: MarkerId(markerIDVal),
          position: point,
          icon: BitmapDescriptor.defaultMarker
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

}

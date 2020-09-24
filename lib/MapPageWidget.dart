import 'dart:collection';

import 'package:fluttAR/DatabaseHandler.dart';
import 'package:fluttAR/main.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'Location.dart';

class MapPageWidget extends StatelessWidget {
  GoogleMapController mapController;

  Set<Marker> _markers = new HashSet<Marker>();
  int markerIDCounter = 0;
  LatLng center;
  DataBaseHandler handler;
  MyAppState parentState;

  MapPageWidget(DataBaseHandler handler, LatLng center, MyAppState parentState) {
    this.handler = handler;
    this.center = center;
    this.parentState = parentState;
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void receivedLocationInformation(Location loc) {
    print("MAP:ADD:CALLED");
    _setMarker(LatLng(loc.latitude, loc.longitude), true);
  }

  void _setMarker(LatLng point, bool dontStore) {
    this.parentState.setState(() {
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
        handler.persistToDB(loc);
      }
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
}

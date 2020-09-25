import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttAR/main.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'Location.dart';

class MapPageWidget extends StatefulWidget {
  LatLng center;

  MapPageWidget(LatLng center) {
    this.center = center;
  }

  @override
  MapState createState() => MapState(center);
}

class MapState extends State<MapPageWidget> {
  GoogleMapController mapController;
  TextEditingController editController;
  LatLng center;

  Set<Marker> _markers = new HashSet<Marker>();
  int markerIDCounter = 0;

  static const String COLLECTION_NAME = "Locations";

  MapState(LatLng center) {
    this.center = center;
  }

  @override
  void initState() {
    super.initState();
    editController = TextEditingController();
    initMarkers();
  }

  Future<void> initMarkers() async {
    await Firebase.initializeApp();
    FirebaseFirestore.instance
        .collection(COLLECTION_NAME)
        .get()
        .then((value) => {
              value.docs.forEach((element) {
                var map = element.data();
                var latitude = map["latitude"];
                var longitude = map["longitude"];
                var name = map["name"];
                _setMarker(LatLng(latitude, longitude), true, name);
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
                showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    elevation: 0.0,
                    backgroundColor: Colors.transparent,
                    child: Center(
                      child: new Container(
                        decoration: new BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10.0,
                              offset: const Offset(0.0, 10.0),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: new TextField(
                              decoration: new InputDecoration(
                                  hintText: "Set Text for Marker"),
                              controller: editController,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: new FlatButton(
                              color: Colors.blueAccent,
                              textColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2),
                                side: BorderSide(color: Colors.blueAccent),
                              ),
                              child: new Text("Create"),
                              onPressed: () {
                                _setMarker(point, false, editController.text);
                                Navigator.pop(context);
                              },
                            ),
                          )
                        ],
                        ),
                    ),
                  ),
                )
                );
            }),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void receivedLocationInformation(Location loc) {
    _setMarker(LatLng(loc.latitude, loc.longitude), true, loc.name);
  }

  void _setMarker(LatLng point, bool dontStore, String name) {
    setState(() {
      final String markerIDVal = "ID${markerIDCounter}";
      markerIDCounter++;
      _markers.add(
        Marker(
            markerId: MarkerId(markerIDVal),
            position: point,
            infoWindow: InfoWindow(title: name),
            onTap:  () =>   mapController.showMarkerInfoWindow(MarkerId(markerIDVal)),
            icon: BitmapDescriptor.defaultMarker),
      );
      Location loc = Location(point.latitude, point.longitude, 1200, name);
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

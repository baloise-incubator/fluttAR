import 'dart:collection';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttAR/main.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'Location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
                var location = Location.fromDataStoreMap(element.data());
                _setMarkerFromLocation(location);
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
                                      side:
                                          BorderSide(color: Colors.blueAccent),
                                    ),
                                    child: new Text("Create"),
                                    onPressed: () {
                                      _setMarker(point, editController.text);
                                      Navigator.pop(context);
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ));
            }),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void receivedLocationInformation(Location loc) {
    _setMarkerFromLocation(loc);
  }

  void _setMarker(LatLng point, String name) {
    setState(() {
      final String markerIDVal = "ID${markerIDCounter}";
      markerIDCounter++;
      _markers.add(
        Marker(
            markerId: MarkerId(markerIDVal),
            position: point,
            infoWindow: InfoWindow(title: name),
            onTap: () =>
                mapController.showMarkerInfoWindow(MarkerId(markerIDVal)),
            icon: BitmapDescriptor.defaultMarker),
      );
      fetchAltitudeAndSetMarker(point, name);
    });
  }

  void _setMarkerFromLocation(Location location) {
    setState(() {
      final String markerIDVal = "ID${markerIDCounter}";
      markerIDCounter++;
      _markers.add(
        Marker(
            markerId: MarkerId(markerIDVal),
            position: LatLng(location.latitude, location.longitude),
            infoWindow: InfoWindow(title: location.name),
            onTap: () =>
                mapController.showMarkerInfoWindow(MarkerId(markerIDVal)),
            icon: BitmapDescriptor.defaultMarker),
      );
    });
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

  Future<void> fetchAltitudeAndSetMarker(LatLng position, String name) async {
    dynamic url = "https://maps.googleapis.com/maps/api/elevation/json?";
    dynamic key = "&key=AIzaSyD6viKyHOHLaKUOMay_WOEkup-YXyMMR04";
    dynamic location = "locations=${position.latitude},${position.longitude}";
    var response = await http.get(url + location + key);
    Location loc = Location(position.latitude, position.longitude, 1200, name);
    if(response.statusCode == 200) {
      var parsedJson = json.decode(response.body);
      print(parsedJson.toString());
      var altitude = parsedJson["results"][0]["elevation"];
      loc.meterOverNull = altitude;
    }
    persistToDB(loc);
  }
}

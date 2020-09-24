import 'package:fluttAR/DatabaseHandler.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'ArPageWidget.dart';
import 'Location.dart';
import 'MapPageWidget.dart';

void main() {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  PageController _controller = PageController(
    initialPage: 0,
  );

  LatLng _center = LatLng(46.689520, 7.762714);
  DataBaseHandler handler = DataBaseHandler();
  ArPageWidget arPage;
  MapPageWidget mapPage;

  @override
  void initState(){
    super.initState();
    GeolocatorPlatform.instance.getCurrentPosition().then((value) =>
    _center = LatLng(value.latitude, value.longitude));
    arPage = ArPageWidget(handler);
    mapPage = MapPageWidget(handler, _center, this);
    //List<Function> functionList = new List<Function>();
    //functionList.add((loc) =>{ mapPage.receivedLocationInformation(loc)});
    //handler.addListeners(functionList);
  }

  int bottomSelectedIndex = 0;

  List<BottomNavigationBarItem> buildBottomNavBarItems() {
    return [
      BottomNavigationBarItem(
          icon: new Icon(Icons.photo_camera), title: new Text('AR')),
      BottomNavigationBarItem(
        icon: new Icon(Icons.map),
        title: new Text('MAP'),
      ),
    ];
  }

  void pageChanged(int index) {
    setState(() {
      bottomSelectedIndex = index;
    });
  }

  void bottomTapped(int index) {
    setState(() {
      bottomSelectedIndex = index;
      _controller.animateToPage(index,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("FluttAR"),
      ),
      body: PageView(
        controller: _controller,
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          pageChanged(index);
        },
        children: [
          arPage,
          mapPage,
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: bottomSelectedIndex,
        onTap: (index) {
          bottomTapped(index);
        },
        items: buildBottomNavBarItems(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

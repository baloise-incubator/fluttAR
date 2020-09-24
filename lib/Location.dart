import 'dart:collection';

class Location {

  double latitude;
  double longitude;
  double meterOverNull;
  String name;

  Location(double latitude, double longitude, double meterOverNull,[String name = ""]){
    this.latitude = latitude;
    this.longitude = longitude;
    this.meterOverNull = meterOverNull;
    this.name = name;
  }

  Map<String, dynamic> toDataStoreMap(){
    var map = new HashMap<String, dynamic>();
    var mapEntryLat = new MapEntry("latitude", latitude);
    var mapEntryLong = new MapEntry("longitude", longitude);
    var mapEntryAlt = new MapEntry("altitude", meterOverNull);
    var mapEntryName = new MapEntry("name", name);

    map.addEntries({mapEntryLat, mapEntryLong, mapEntryAlt, mapEntryName});
    return map;
  }

  static Location fromDataStoreMap(Map<String, dynamic> map){
    var latitude = map["latitude"];
    var longitude = map["longitude"];
    var meterOverNull = map["altitude"];
    var name = map["name"];
    return new Location(latitude, longitude, meterOverNull, name);
  }

  String identifyingName(){
    return latitude.toString() + "_" + longitude.toString() + "_" + meterOverNull.toString() + "_" + name;
  }

}
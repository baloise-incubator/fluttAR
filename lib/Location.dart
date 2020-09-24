import 'dart:collection';

class Location {

  double latitude;
  double longitude;
  double meterOverNull;

  Location(double latitude, double longitude, double meterOverNull){
    this.latitude = latitude;
    this.longitude = longitude;
    this.meterOverNull = meterOverNull;
  }

  Map<String, dynamic> toDataStoreMap(){
    var map = new HashMap<String, dynamic>();
    var mapEntryLat = new MapEntry("latitude", latitude);
    var mapEntryLong = new MapEntry("longitude", longitude);
    var mapEntryAlt = new MapEntry("altitude", meterOverNull);

    map.addEntries({mapEntryLat, mapEntryLong, mapEntryAlt});
    return map;
  }

  static Location fromDataStoreMap(Map<String, dynamic> map){
    var latitude = map["latitude"];
    var longitude = map["longitude"];
    var meterOverNull = map["altitude"];
    return new Location(latitude, longitude, meterOverNull);
  }

  String identifyingName(){
    return latitude.toString() + "_" + longitude.toString() + "_" + meterOverNull.toString();
  }

}
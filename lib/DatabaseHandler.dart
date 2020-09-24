import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

import 'Location.dart';

class DataBaseHandler {

  static const platform = const MethodChannel('com.baloise/ARKit');

  static const String COLLECTION_NAME = "Locations";

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


  Future<void> addListeners(List<Function> functions) async {
    await Firebase.initializeApp();
    FirebaseFirestore.instance
        .collection(COLLECTION_NAME)
        .snapshots()
        .listen((event) {
      event.docChanges.forEach((element) {
        if (element.type == DocumentChangeType.added) {
          var data = element.doc.data();
          print("Document Added event received");
          functions.forEach((element) {
            element(Location.fromDataStoreMap(data));
          });
        }
      });
    });
  }

  Future getInitialData(Function function) async {
    print("AR:INITIAL:CALLED");
    await Firebase.initializeApp();
    FirebaseFirestore.instance.collection(COLLECTION_NAME).snapshots().last.then((value) => {
      function(value.docs.last)
    });

  }

}
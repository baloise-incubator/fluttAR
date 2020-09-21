import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
      body: ARKitSceneView(
          onARKitViewCreated: onARKitViewCreated,
          showFeaturePoints: true,
          showWorldOrigin: true,
          enableTapRecognizer: true,
          planeDetection: ARPlaneDetection.horizontalAndVertical
      ));

  void onARKitViewCreated(ARKitController arkitController) {
    this.arkitController = arkitController;
    final material = ARKitMaterial(
    diffuse: ARKitMaterialProperty(
    color: Colors.yellow,
    ));
    sphere = ARKitSphere(
      materials: [material],
      radius: 0.1,
    );

    final node = ARKitNode(
      name: 'sphere',
      geometry: sphere,
      position: vector.Vector3(0, 0, -0.5),
    );
    this.arkitController.add(node);
    //this.arkitController.onAddNodeForAnchor = _handleAddAnchor;
    this.arkitController.onARTap = (results) => onTapHandler(results);
    //this.arkitController.onNodeTap = (nodes) => onNodeTapHandler(nodes);
  }

  void _handleAddAnchor(ARKitAnchor anchor) {
    if (anchor is ARKitPlaneAnchor) {
      _addPlane(arkitController, anchor);
    }
  }

  void _addPlane(ARKitController controller, ARKitPlaneAnchor anchor) {
    anchorId = anchor.identifier;
    final node =  ARKitNode(
        geometry: ARKitSphere(radius: 0.1), position: vector.Vector3(0, 0, -0.5));
    this.arkitController.add(node);
  }

  void onTapHandler(List<ARKitTestResult> results) {
    final color = sphere.materials.value.first.diffuse.color == Colors.green
        ? Colors.red
        : Colors.green;
    sphere.materials.value = [
      ARKitMaterial(diffuse: ARKitMaterialProperty(color: color))
    ];
    log( "Tap found" + results.length.toString());
    if(results.isEmpty){
      return;
    } else {
      results.forEach((element) {
         vector.Vector4 vector4 = element.worldTransform.getColumn(3);
         final node =  ARKitNode(
             geometry: ARKitSphere(radius: 0.1), position: vector.Vector3(vector4.x, vector4.y, vector4.z));
         this.arkitController.add(node);
      });
    }
  }

}
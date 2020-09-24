//
//  ContentView.swift
//  NoFluttAR
//
//  Created by Lukas Brendle on 21.09.20.
//

import SwiftUI
import RealityKit
import ARKit
import CoreLocation
import ARKit_CoreLocation

struct ContentView :View {
    
    var body: some View {
        return ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

class GameViewController: UIViewController, UIGestureRecognizerDelegate, ARSessionDelegate {
    
    @IBOutlet var arview : ARView!
    
    var sceneLocation : SceneLocationView!
    var locationManager: CLLocationManager!
    
    var arTrackingType = SceneLocationView.ARTrackingType.worldTracking
    var scalingScheme = ScalingScheme.normal
    var flutterMethodHandler : FlutterMethodHandler!
    
    var continuallyAdjustNodePositionWhenWithinRange = false
    var continuallyUpdatePositionAndScale = false
    var annotationHeightAdjustmentFactor = 1
    
    override func viewDidLoad() {
        print("Test")
        
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
//        arview = ARViewContainer().makeUIView()
//        arview.session.delegate = self
        view.isUserInteractionEnabled = true

        sceneLocation = SceneLocationView.init(trackingType : .worldTracking)
        sceneLocation.debugOptions = [.showFeaturePoints, .showWorldOrigin]
        sceneLocation.session.delegate = self
        sceneLocation.showAxesNode = true
        sceneLocation.run()
        sceneLocation.isUserInteractionEnabled = true
        view.addSubview(sceneLocation)
        setupGestures()
        //view.addSubview(arview)
        
        let coordinate = CLLocationCoordinate2D(latitude: 46.536671, longitude: 7.962324)
        let location = CLLocation(coordinate: coordinate, altitude: 4158)
        //let image = UIImage(named: "pin")!
        //let annotationNode = LocationAnnotationNode(location: location, image: image)
        let annotationNode = LocationAnnotationNode(location: location,
                                                    view: UIView.prettyLabeledView(text: "Jungfrau", backgroundColor: UIColor.orange, borderColor: UIColor.black))
        addScenewideNodeSettings(annotationNode)
        sceneLocation.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
    }
    
    func addNodeAtSpecifiedLocation( lat : Double, long : Double, alt : Double){
        let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: long), altitude: alt)
        let image = UIImage(named: "pin")!

        let annotationNode = LocationAnnotationNode(location: location, image: image)
        
        addScenewideNodeSettings(annotationNode)
        sceneLocation.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
    }
    
    func addScenewideNodeSettings(_ node: LocationNode) {
        if let annoNode = node as? LocationAnnotationNode {
            annoNode.annotationHeightAdjustmentFactor = Double(annotationHeightAdjustmentFactor)
        }
        node.scalingScheme = .normal
        
        node.continuallyAdjustNodePositionWhenWithinRange = continuallyAdjustNodePositionWhenWithinRange
        node.continuallyUpdatePositionAndScale = continuallyUpdatePositionAndScale
    }
    
    override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()

      sceneLocation.frame = view.bounds
    }
    
    private func setupGestures(){
        // set up docent gesture recognizer
        let taprecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        taprecognizer.numberOfTouchesRequired = 1
        taprecognizer.delegate = self
        sceneLocation.addGestureRecognizer(taprecognizer)
    }
    
    @IBAction
    func onTap(_ sender: UITapGestureRecognizer) {
        
        print("tap found")
        let tapLocation: CGPoint = sender.location(in: sceneLocation)
        let result: [SCNHitTestResult] = sceneLocation.hitTest(tapLocation)
        
        guard let hitTest: SCNHitTestResult = result.first
        else { return }
        
        addObject(position: hitTest.worldCoordinates)
        //let entity: Entity = hitTest.entity
        //print(entity.name)
    }
    
    func addObject(position: SCNVector3) {
        print("adding object at point: \(position)")
        
        let image = UIImage(named: "pin")!
        let currentLocationNode = LocationAnnotationNode(location: locationManager.location, image: image)
        
      
        sceneLocation.addLocationNodeWithConfirmedLocation(locationNode: currentLocationNode)
        flutterMethodHandler.dispatchLocation(location: currentLocationNode.location)
    }
    
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.debugOptions = [.showFeaturePoints]
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        arView.session.run(configuration)
    
        
        let anchor = AnchorEntity(.plane([.horizontal, .vertical],
                                         classification: [.wall, .table, .floor],
                                         minimumBounds: [0.1, 0.1]))
        
        
        
//        let location = CLLocationCoordinate2D(46.6917499,7.7640721)
//        let geoAnchor = ARGeoAnchor(coordinate: location)
        // Load the "Box" scene from the "Experience" Reality File
//        let boxAnchor = try! Experience.loadBox()
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(anchor)
        
        return arView
    }
    
    func makeUIView() -> ARView {
        let arView = ARView(frame: UIScreen.main.bounds)
        arView.debugOptions = [.showFeaturePoints]
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        arView.session.run(configuration)
        
        
        let anchor = AnchorEntity(.plane([.horizontal, .vertical],
                                         classification: [.wall, .table, .floor],
                                         minimumBounds: [0.1, 0.1]))
        
        
        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadBox()
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxAnchor)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
    }

    
}

extension UIView {
    /// Create a colored view with label, border, and rounded corners.
    class func prettyLabeledView(text: String,
                                 backgroundColor: UIColor = .systemBackground,
                                 borderColor: UIColor = .black) -> UIView {
        let font = UIFont.preferredFont(forTextStyle: .title2)
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = (text as NSString).size(withAttributes: fontAttributes)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))

        let attributedString = NSAttributedString(string: text, attributes: [NSAttributedString.Key.font: font])
        label.attributedText = attributedString
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true

        let cframe = CGRect(x: 0, y: 0, width: label.frame.width + 20, height: label.frame.height + 10)
        let cview = UIView(frame: cframe)
        cview.translatesAutoresizingMaskIntoConstraints = false
        cview.layer.cornerRadius = 10
        cview.layer.backgroundColor = backgroundColor.cgColor
        cview.layer.borderColor = borderColor.cgColor
        cview.layer.borderWidth = 1
        cview.addSubview(label)
        label.center = cview.center

        return cview
    }

}


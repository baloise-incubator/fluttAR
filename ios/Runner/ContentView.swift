//
//  ContentView.swift
//  FluttAR
//
//  Created by Lukas Brendle on 21.09.20.
//

import SwiftUI
import RealityKit
import ARKit
import CoreLocation
import ARKit_CoreLocation

class GameViewController: UIViewController, UIGestureRecognizerDelegate, ARSessionDelegate, ARSCNViewDelegate {
    
    @IBOutlet var arview : ARView!
    
    var sceneLocation : SceneLocationView!
    var locationManager: CLLocationManager!
    
    var arTrackingType = SceneLocationView.ARTrackingType.orientationTracking
    var scalingScheme = ScalingScheme.normal
    var flutterMethodHandler : FlutterMethodHandler!
    
    var continuallyAdjustNodePositionWhenWithinRange = true
    var continuallyUpdatePositionAndScale = true
    var annotationHeightAdjustmentFactor = 0.1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        view.isUserInteractionEnabled = true

        sceneLocation = SceneLocationView.init(trackingType : arTrackingType)
        sceneLocation.debugOptions = [.showFeaturePoints, .showWorldOrigin]
        sceneLocation.session.delegate = self
        sceneLocation.showAxesNode = true
        sceneLocation.translatesAutoresizingMaskIntoConstraints = false
        sceneLocation.arViewDelegate = self
        sceneLocation.orientToTrueNorth = true
        sceneLocation.locationEstimateMethod = LocationEstimateMethod.mostRelevantEstimate
        sceneLocation.autoenablesDefaultLighting = true
        sceneLocation.showsStatistics = true
        sceneLocation.isUserInteractionEnabled = true
        view.addSubview(sceneLocation)
       
        setupGestures()
    
        addNodeAtSpecifiedLocation(lat: 46.655417, long: 7.771430, alt: 575, name: "Leissingen")
        addNodeAtSpecifiedLocation(lat: 46.577619, long: 8.005736, alt: 3970, name: "Eiger")
        
        sceneLocation.run()
    }
    
    func addNodeAtSpecifiedLocation( lat : Double, long : Double, alt : Double, name : String){
        let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: long), altitude: alt)
        var annotationNode : LocationAnnotationNode!
        if(!name.isEmpty){
            annotationNode = LocationAnnotationNode(location: location,
                                                    view: UIView.prettyLabeledView(text: name, backgroundColor: UIColor.lightGray, borderColor: UIColor.black))
        } else {
            let image = UIImage(named: "pin")!
            annotationNode = LocationAnnotationNode(location: location, image: image)
        }
        
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
    }
    
    func addObject(position: SCNVector3) {
        print("adding object at point: \(position)")
        
        let image = UIImage(named: "pin")!
        let currentLocationNode = LocationAnnotationNode(location: locationManager.location, image: image)
        
        let locationNode = LocationNode(location: locationManager.location)
        sceneLocation.addLocationNodeWithConfirmedLocation(locationNode: locationNode)
        flutterMethodHandler.dispatchLocation(location: locationNode.location)
        
        //sceneLocation.addLocationNodeWithConfirmedLocation(locationNode: currentLocationNode)
        //flutterMethodHandler.dispatchLocation(location: currentLocationNode.location)
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


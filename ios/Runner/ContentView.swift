//
//  ContentView.swift
//  NoFluttAR
//
//  Created by Lukas Brendle on 21.09.20.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView :View {
    
    var body: some View {
        return ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

class GameViewController: UIViewController, UIGestureRecognizerDelegate, ARSessionDelegate {
    
    @IBOutlet var arview : ARView!
    
    override func viewDidLoad() {
        print("Test")
        
        super.viewDidLoad()
        arview = ARViewContainer().makeUIView()
        arview.session.delegate = self
        view.isUserInteractionEnabled = true
        arview.isUserInteractionEnabled = true
        setupGestures()
        view.addSubview(arview)
        
    }
    
    private func setupGestures(){
        // set up docent gesture recognizer
        let taprecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        taprecognizer.numberOfTouchesRequired = 1
        taprecognizer.delegate = self
        arview.addGestureRecognizer(taprecognizer)
    }
    
    @IBAction
    func onTap(_ sender: UITapGestureRecognizer) {
        
        print("tap found")
        let tapLocation: CGPoint = sender.location(in: arview)
        let result: [CollisionCastHit] = arview.hitTest(tapLocation)
        
        guard let hitTest: CollisionCastHit = result.first
        else { return }
        
        addObject(position: hitTest.position)
        let entity: Entity = hitTest.entity
        print(entity.name)
    }
    
    func addObject(position: SIMD3<Float>) {
        print("adding object at point: \(position)")
        let boxAnchor = try! Experience.loadBox()
        boxAnchor.position = position
        arview.scene.anchors.append(boxAnchor)
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


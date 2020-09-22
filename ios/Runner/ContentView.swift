//
//  ContentView.swift
//  NoFluttAR
//
//  Created by Lukas Brendle on 21.09.20.
//

import SwiftUI
import RealityKit

struct ContentView :View {
        
    var body: some View {
        return ARViewContainer().edgesIgnoringSafeArea(.all)
    }
    
    var uiView : some UIView {
        return ARViewContainer().makeUIView()
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadBox()
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxAnchor)
        
        return arView
    }
    
    
    func makeUIView() -> ARView {
        
        let arView = ARView(frame: .zero)
        
        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadBox()
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxAnchor)
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}


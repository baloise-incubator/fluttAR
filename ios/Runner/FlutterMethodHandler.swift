//
//  FlutterMethodHandler.swift
//  Runner
//
//  Created by Lukas Brendle on 23.09.20.
//

import Foundation
import CoreLocation

class FlutterMethodHandler {
    
    var window : UIWindow!
    var gameViewController :GameViewController!
    var methodChannel : FlutterMethodChannel!
    
    init(window : UIWindow) {
        self.window = window
    }
    
    func setupMethodCallHandler() {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        methodChannel = FlutterMethodChannel(name: "com.baloise/ARKit",
                                                 binaryMessenger: controller.binaryMessenger)
        
        methodChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
            
            switch call.method {
            case "startARSession":
                self?.startARSession()
            case "setLocation":
                print("setLocationCalled")
                let arguments = call.arguments as! Array<Double>
                guard arguments.count == 3 else {
                    break
                }
                self?.setLocation(lat :arguments[0], long :arguments[1], alt : arguments[2] )
            default:
                print("Nothing")
            }
            
        })
    }
    
    func startARSession(){
        gameViewController = GameViewController()
        gameViewController.flutterMethodHandler = self
        gameViewController.view.frame = self.window.rootViewController?.view.frame ?? gameViewController.view.frame
        gameViewController.modalPresentationStyle = .fullScreen
        self.window?.rootViewController?.present(gameViewController, animated: false)
        self.window.makeKeyAndVisible()
    }
    
    func setLocation(lat : Double, long : Double, alt : Double){
        gameViewController.addNodeAtSpecifiedLocation(lat: lat, long: long, alt: alt)
    }
    
    func dispatchLocation(location : CLLocation){
        let locationInfos =  [location.coordinate.latitude, location.coordinate.longitude, location.altitude]
        print("Sending locationInfos " + locationInfos.description)
        methodChannel.invokeMethod("dispatchLocation", arguments: locationInfos)
    }
}

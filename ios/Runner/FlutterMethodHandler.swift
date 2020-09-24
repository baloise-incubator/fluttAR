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
                let arguments = call.arguments as! Array<Any>
                guard arguments.count == 4 else {
                    break
                }
                var lat = arguments[0] as! Double
                var long = arguments[1] as! Double
                var alt = arguments[2] as! Double
                var name = arguments[3] as! String
                
                self?.setLocation(lat : lat, long : long, alt: alt, name: name)
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
    
    func setLocation(lat : Double, long : Double, alt : Double, name : String){
        gameViewController.addNodeAtSpecifiedLocation(lat: lat, long: long, alt: alt, name : name)
    }
    
    func dispatchLocation(location : CLLocation){
        let locationInfos =  [location.coordinate.latitude, location.coordinate.longitude, location.altitude]
        print("Sending locationInfos " + locationInfos.description)
        methodChannel.invokeMethod("dispatchLocation", arguments: locationInfos)
    }
}

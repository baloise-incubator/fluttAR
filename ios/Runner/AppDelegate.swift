import UIKit
import Flutter
import SwiftUI
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    var flutterMethodHandler :FlutterMethodHandler!
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        flutterMethodHandler = FlutterMethodHandler(window: self.window)
        flutterMethodHandler.setupMethodCallHandler()
        GeneratedPluginRegistrant.register(with: self)
        GMSServices.provideAPIKey("AIzaSyD6viKyHOHLaKUOMay_WOEkup-YXyMMR04")
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
}

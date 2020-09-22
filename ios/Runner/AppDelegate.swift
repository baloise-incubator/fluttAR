import UIKit
import Flutter
import SwiftUI

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

   
      let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
      let batteryChannel = FlutterMethodChannel(name: "com.baloise/ARKit",
                                                binaryMessenger: controller.binaryMessenger)
      batteryChannel.setMethodCallHandler({
        [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
      
        let contentView = ContentView()
        var child = UIHostingController(rootView: contentView)
        child.view.frame = self?.window.rootViewController?.view.frame ?? child.view.frame
        self?.window?.rootViewController?.present(child, animated: false)
        self?.window?.rootViewController?.present(child, animated: false)
        self?.window.makeKeyAndVisible()
        
      })

      GeneratedPluginRegistrant.register(with: self)
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func receiveBatteryLevel(result: FlutterResult) {
      let device = UIDevice.current
      device.isBatteryMonitoringEnabled = true
      if device.batteryState == UIDevice.BatteryState.unknown {
        result(FlutterError(code: "UNAVAILABLE",
                            message: "Battery info unavailable",
                            details: nil))
      } else {
        result(Int(device.batteryLevel * 100))
      }
    }
}

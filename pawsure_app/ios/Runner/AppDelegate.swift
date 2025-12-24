import UIKit
import Flutter
import GoogleMaps  // <--- Added this

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // <--- Added API Key Registration
    GMSServices.provideAPIKey("AIzaSyD7frUQtG4bJH2ohOz6IndpZ7a2EeEaves")
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
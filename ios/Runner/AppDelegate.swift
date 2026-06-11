import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let sharedDefaults = UserDefaults(suiteName: "group.com.example.vitasens.shared")

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let controller = window?.rootViewController as? FlutterViewController {
      let shareChannel = FlutterMethodChannel(name: "com.vitasense/share", binaryMessenger: controller.binaryMessenger)
      
      shareChannel.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        guard call.method == "getSharedUrl" else {
          result(FlutterMethodNotImplemented)
          return
        }
        
        // Bezpiecznie sprawdzamy, czy UserDefaults istnieje i czy zawiera URL
        if let sharedDefaults = self?.sharedDefaults,
           let url = sharedDefaults.string(forKey: "pendingRecipeURL") {
          sharedDefaults.removeObject(forKey: "pendingRecipeURL")
          result(url)
        } else {
          result(nil)
        }
      })
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}

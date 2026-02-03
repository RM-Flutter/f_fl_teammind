import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    let controller = window?.rootViewController as! FlutterViewController
    let secureChannel = FlutterMethodChannel(
      name: "com.rightminddev.rmemp/secure",
      binaryMessenger: controller.binaryMessenger
    )

    secureChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      switch call.method {
      case "enableSecureFlag":
        if #available(iOS 13.0, *) {
          UIApplication.shared.windows.first?.layer.contents = nil
          let privacyView = UIView(frame: UIScreen.main.bounds)
          privacyView.backgroundColor = .white
          privacyView.tag = 1234
          UIApplication.shared.windows.first?.addSubview(privacyView)
        }
        result(nil)

      case "isDeveloperModeEnabled":
        // iOS does not expose a standard "developer mode" like Android.
        // Always return false so the Flutter side only enforces this on Android.
        result(false)

      case "isDeviceRooted":
        result(isDeviceJailbroken())

      default:
        result(FlutterMethodNotImplemented)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func isDeviceJailbroken() -> Bool {
    #if targetEnvironment(simulator)
    // Simulator should not be treated as jailbroken
    return false
    #else
    // 1) Check for existence of common jailbreak files
    let jailbreakPaths = [
      "/Applications/Cydia.app",
      "/Library/MobileSubstrate/MobileSubstrate.dylib",
      "/bin/bash",
      "/usr/sbin/sshd",
      "/etc/apt",
      "/private/var/lib/apt/"
    ]
    for path in jailbreakPaths {
      if FileManager.default.fileExists(atPath: path) {
        return true
      }
    }

    // 2) Try writing outside of the sandbox
    let testPath = "/private/" + UUID().uuidString
    do {
      try "test".write(toFile: testPath, atomically: true, encoding: .utf8)
      // If write succeeded, device is likely jailbroken
      try FileManager.default.removeItem(atPath: testPath)
      return true
    } catch {
      // Ignore, this is expected on non‑jailbroken devices
    }

    return false
    #endif
  }
}

import UIKit
import Flutter


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        var stringSender:StringSender?
        
        var stringReciever:StringReciever?
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let sessionChannel = FlutterMethodChannel(name: "sessionChannel", binaryMessenger: controller.binaryMessenger)
        
        sessionChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            switch call.method {
                
            case "createSender":
                stringSender = StringSender(sessionId: call.arguments as? String ?? "default", sessionChannel: sessionChannel)
                
            case "sendData":
                stringSender?.send(str: call.arguments as? String ?? "data error")
                
            case "createReciever":
                stringReciever = StringReciever(sessionId: call.arguments as? String ?? "default", sessionChannel: sessionChannel)
                
            default:
                return
            }
        })
        
        GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

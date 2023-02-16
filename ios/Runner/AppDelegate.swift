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
                guard let args = call.arguments as? [String: String] else {return}
                print("arguments ::::::")
                print(args)
                stringReciever = StringReciever(sessionId: args["channelId"]!,urlToFolder: args["toFolderUrl"]!, sessionChannel: sessionChannel)
                
            case "sendFile":
                stringSender?.sendFile(url: (call.arguments as? String)!)
                
            default:
                return
            }
        })
        
        GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

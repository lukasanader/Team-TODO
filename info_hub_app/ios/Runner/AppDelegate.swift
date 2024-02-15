import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let filePickerChannel = FlutterMethodChannel(name: "com.example/file_picker", binaryMessenger: controller.binaryMessenger)
        filePickerChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
            // Handle method calls here
            if call.method == "pickVideo" {
                // Perform file picking operation here
                // You can use UIImagePickerController to pick a video file
                // Example:
                let imagePickerController = UIImagePickerController()
                imagePickerController.sourceType = .photoLibrary
                imagePickerController.mediaTypes = ["public.movie", "public.image", "public.audio", "public.text", "public.data"]
                controller.present(imagePickerController, animated: true, completion: nil)
            } else {
                result(FlutterMethodNotImplemented)
            }
        })
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

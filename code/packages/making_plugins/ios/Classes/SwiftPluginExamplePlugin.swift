import Flutter
import UIKit

public class PluginExample: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel =
    	FlutterMethodChannel(
    		name: "example.com/plugin_swift",
    		binaryMessenger: registrar.messenger()
    	)
    let handler = PluginExample()
    registrar.addMethodCallDelegate(handler, channel: channel)
  }
  public func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
    if(call.method == "runExampleMethod") {
    	result(DATA)
    }
  }
}

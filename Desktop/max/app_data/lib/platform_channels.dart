import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PlatformChannels {
  static const MethodChannel _channel =
      MethodChannel('com.example.app_data/connectivity');

  static Future<void> initialize() async {
    _channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'connectivityChanged':
          String connectivityStatus = call.arguments;
          Fluttertoast.showToast(
            msg: "Connectivity changed: $connectivityStatus",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
          break;
        case 'batteryThresholdReached':
          Fluttertoast.showToast(
            msg: "Battery reached 90%",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
          break;
        default:
          throw MissingPluginException('Not implemented: ${call.method}');
      }
    });
  }
}

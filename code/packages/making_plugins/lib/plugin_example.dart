import 'dart:async';
import 'package:flutter/services.dart';

class PluginExample {
  static const _platformChannel =
      MethodChannel('example.com/plugin_example');
  static Future<type> exampleMethod async {
    return await _platformChannel.invokeMethod('runExampleMethod');
  }
}

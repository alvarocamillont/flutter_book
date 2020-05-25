/***
 * Excerpted from "Programming Flutter",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/czflutr for more book information.
***/
package com.example.pluginexample;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry.Registrar;

public class PluginExample implements MethodCallHandler {
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
      new MethodChannel(registrar.messenger(), "example.com/plugin_example");
    channel.setMethodCallHandler(new PluginExample());
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("runExampleMethod")) {
      result.success(DATA_TO_RESPOND_WITH);
    } else {
      result.notImplemented();
    }
  }
}

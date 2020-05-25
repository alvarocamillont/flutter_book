/***
 * Excerpted from "Programming Flutter",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/czflutr for more book information.
***/
#import "PluginExamplePlugin.h"
#import <plugin_example/plugin_example-Swift.h>

@implementation PluginSwiftPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPluginSwiftPlugin registerWithRegistrar:registrar];
}
@end

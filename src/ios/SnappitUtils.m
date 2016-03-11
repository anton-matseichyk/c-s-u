#import "SnappitUtils.h"
#import <Cordova/CDVPlugin.h>
#import <sys/utsname.h>

@implementation SnappitUtils

- (void)getDeviceName:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    //NSString* echo = [command.arguments objectAtIndex:0];

    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString* echo = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if (echo != nil && [echo length] > 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Device name"
                              message:echo
                              delegate:self
                              cancelButtonTitle:@"Got it"
                              otherButtonTitles: nil
                              ];
        [alert show];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
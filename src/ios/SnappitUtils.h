 #import <Cordova/CDVPlugin.h>

@interface SnappitUtils : CDVPlugin

- (void)getDeviceName:(CDVInvokedUrlCommand*)command;
- (void)initMobilePay:(CDVInvokedUrlCommand*)command;
- (void)payWithMobilePay:(CDVInvokedUrlCommand*)command;
- (void)handleOpenUrl:(CDVInvokedUrlCommand*)command;

@property (nonatomic, strong) UIAlertView *errorInOrderAlertView;
@end
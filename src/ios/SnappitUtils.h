 #import <Cordova/CDVPlugin.h>

@interface SnappitUtils : CDVPlugin

- (void)getDeviceName:(CDVInvokedUrlCommand*)command;
- (void)initMobilePay:(CDVInvokedUrlCommand*)command;
- (void)payWithMobilePay:(CDVInvokedUrlCommand*)command;
- (void)handleMobilePayment:(CDVInvokedUrlCommand*)command;
- (void)enableKeyboardRequiresUserAction:(CDVInvokedUrlCommand*)command;
- (void)disableKeyboardRequiresUserAction:(CDVInvokedUrlCommand*)command;

@property (nonatomic, strong) UIAlertView *errorInOrderAlertView;
@end
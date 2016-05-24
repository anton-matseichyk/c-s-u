#import "SnappitUtils.h"
#import "ViewHelper.h"
#import <Cordova/CDVPlugin.h>
#import <sys/utsname.h>
#import "MobilePayManager.h"
#import "MobilePayPayment.h"

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

-(void)initMobilePay:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* result = @"MobilePay: Ok";

    [[MobilePayManager sharedInstance] setupWithMerchantId:@"APPDK0000000000" merchantUrlScheme:@"fruitshop" country:MobilePayCountry_Denmark];
    
    //success
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];    

    //error
    //pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)payWithMobilePay:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* result = @"MobilePay: MobilePay flow started";
    
    MobilePayPayment *payment = [[MobilePayPayment alloc]initWithOrderId:@"123456"
                                                            productPrice:0.01];
    
    //No need to start a payment if one or more parameters are missing
    if (payment && (payment.orderId.length > 0) && (payment.productPrice >= 0)) {
        
        [[MobilePayManager sharedInstance]beginMobilePaymentWithPayment:payment error:^(NSError * _Nonnull error) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error.localizedDescription
                                                            message:[NSString stringWithFormat:@"reason: %@, suggestion: %@",error.localizedFailureReason, error.localizedRecoverySuggestion]
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Install MobilePay",nil];
            [alert show];
            
        }];
        
    }else{
        self.errorInOrderAlertView = [[UIAlertView alloc] initWithTitle:@"Error in your order"
                                                        message:@"One or more parameters in your order is invalid"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Ok",nil];
        [self.errorInOrderAlertView show];
    }

    
    //success
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
    
    //error
    //pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if((buttonIndex == 1) && (![alertView isEqual:self.errorInOrderAlertView])) /* NO = 0, YES = 1 */
    {
        //This could also be the Norwegian or the Finish app you want to link to - this is just an example
        //[MobilePayManager sharedInstance].mobilePayAppStoreLinkNO
        //[MobilePayManager sharedInstance].mobilePayAppStoreLinkFI
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[MobilePayManager sharedInstance].mobilePayAppStoreLinkDK]];
    }
}

-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options
{
    //IMPORTANT - YOU MUST USE THIS IF YOU COMPILING YOUR AGAINST IOS9 SDK
    [self handleMobilePayPaymentWithUrl:url];
    return YES;
}

- (void)handleMobilePayPaymentWithUrl:(NSURL *)url
{
    [[MobilePayManager sharedInstance]handleMobilePayPaymentWithUrl:url success:^(MobilePaySuccessfulPayment * _Nullable mobilePaySuccessfulPayment) {
        NSString *orderId = mobilePaySuccessfulPayment.orderId;
        NSString *transactionId = mobilePaySuccessfulPayment.transactionId;
        NSString *amountWithdrawnFromCard = [NSString stringWithFormat:@"%f",mobilePaySuccessfulPayment.amountWithdrawnFromCard];
        NSLog(@"MobilePay purchase succeeded: Your have now paid for order with id '%@' and MobilePay transaction id '%@' and the amount withdrawn from the card is: '%@'", orderId, transactionId,amountWithdrawnFromCard);
        [ViewHelper showAlertWithTitle:@"MobilePay Succeeded" message:[NSString stringWithFormat:@"You have now paid with MobilePay. Your MobilePay transactionId is '%@'", transactionId]];
        
    } error:^(NSError * _Nonnull error) {
        NSDictionary *dict = error.userInfo;
        NSString *errorMessage = [dict valueForKey:NSLocalizedFailureReasonErrorKey];
        NSLog(@"MobilePay purchase failed:  Error code '%li' and message '%@'",(long)error.code,errorMessage);
        [ViewHelper showAlertWithTitle:[NSString stringWithFormat:@"MobilePay Error %li",(long)error.code] message:errorMessage];
        
        //Show an appropriate error message to the user. Check MobilePayManager.h for a complete description of the error codes
        
        //An example of using the MobilePayErrorCode enum
        //if (error.code == MobilePayErrorCodeUpdateApp) {
        //    NSLog(@"You must update your MobilePay app");
        //}
    } cancel:^(MobilePayCancelledPayment * _Nullable mobilePayCancelledPayment) {
        NSLog(@"MobilePay purchase with order id '%@' cancelled by user", mobilePayCancelledPayment.orderId);
        [ViewHelper showAlertWithTitle:@"MobilePay Canceled" message:@"You cancelled the payment flow from MobilePay, please pick a fruit and try again"];
        
    }];
}

@end
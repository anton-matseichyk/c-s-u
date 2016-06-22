#import "SnappitUtils.h"
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
    NSMutableDictionary* options = [command.arguments objectAtIndex:0];
    id merchantId = [options objectForKey:@"merchantId"];
    id merchantUrlScheme = [options objectForKey:@"merchantUrlScheme"];

    [[MobilePayManager sharedInstance] setupWithMerchantId:merchantId
                                         merchantUrlScheme:merchantUrlScheme
                                            timeoutSeconds:0
                                             returnSeconds:5
                                               captureType:MobilePayCaptureType_Reserve
                                                   country:MobilePayCountry_Norway];
    
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
    NSMutableDictionary* options = [command.arguments objectAtIndex:0];
    id orderId = [options objectForKey:@"orderId"];
    id price = [options objectForKey:@"price"];

    
    MobilePayPayment *payment = [[MobilePayPayment alloc]initWithOrderId:orderId
                                                            productPrice:[price floatValue]];
    
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
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[MobilePayManager sharedInstance].mobilePayAppStoreLinkNO]];
    }
}



- (void)handleMobilePayment:(CDVInvokedUrlCommand*)command
{
    NSMutableDictionary* options = [command.arguments objectAtIndex:0];
    NSURL *url = [NSURL URLWithString:[options objectForKey:@"url"]];
       
    __block CDVPluginResult* pluginResult = nil;
    [[MobilePayManager sharedInstance]handleMobilePayPaymentWithUrl:url success:^(MobilePaySuccessfulPayment * _Nullable mobilePaySuccessfulPayment) {
        
        NSString *orderId = mobilePaySuccessfulPayment.orderId;
        NSString *transactionId = mobilePaySuccessfulPayment.transactionId;
        NSString *amountWithdrawnFromCard = [NSString stringWithFormat:@"%f",mobilePaySuccessfulPayment.amountWithdrawnFromCard];
        NSLog(@"MobilePay purchase succeeded: Your have now paid for order with id '%@' and MobilePay transaction id '%@' and the amount withdrawn from the card is: '%@'", orderId, transactionId,amountWithdrawnFromCard);
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: [NSString stringWithFormat:@"{\"orderId\": \"%@\",\"transactionId\": \"%@\",\"message\": \"Success\",\"success\":\"true\"}", orderId, transactionId]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } error:^(NSError * _Nonnull error) {
        
        NSDictionary *dict = error.userInfo;
        NSString *errorMessage = [dict valueForKey:NSLocalizedFailureReasonErrorKey];
        NSLog(@"MobilePay purchase failed:  Error code '%li' and message '%@'",(long)error.code,errorMessage);
        
        //Show an appropriate error message to the user. Check MobilePayManager.h for a complete description of the error codes
        
        //An example of using the MobilePayErrorCode enum
        //if (error.code == MobilePayErrorCodeUpdateApp) {
        //    NSLog(@"You must update your MobilePay app");
        //}
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: [NSString stringWithFormat:@"{\"orderId\": \"null\",\"transactionId\": \"null\",\"message\": \"%@\",\"success\":\"false\"}", [NSString stringWithFormat:@"MobilePay Error %li",(long)error.code]]];
        

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    } cancel:^(MobilePayCancelledPayment * _Nullable mobilePayCancelledPayment) {
        
        NSLog(@"MobilePay purchase with order id '%@' cancelled by user", mobilePayCancelledPayment.orderId);
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: [NSString stringWithFormat:@"{\"orderId\": \"%@\",\"transactionId\": \"null\",\"message\": \"Cancel\",\"success\":\"false\"}", mobilePayCancelledPayment.orderId]];
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

@end
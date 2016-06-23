package com.snappit;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.UUID;

import dk.danskebank.mobilepay.sdk.CaptureType;
import dk.danskebank.mobilepay.sdk.Country;
import dk.danskebank.mobilepay.sdk.MobilePay;
import dk.danskebank.mobilepay.sdk.ResultCallback;
import dk.danskebank.mobilepay.sdk.model.FailureResult;
import dk.danskebank.mobilepay.sdk.model.Payment;
import dk.danskebank.mobilepay.sdk.model.SuccessResult;

public class SnappitUtils extends CordovaPlugin {
    int MOBILEPAY_PAYMENT_REQUEST_CODE = 1337;
    CallbackContext currentContext = null;

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        currentContext = callbackContext;
        if(action.equals("getDeviceName")) {
            //String message = args.getString(0);
            this.getDeviceName(callbackContext);
            return true;
        }
        if(action.equals("initMobilePay")) {
            JSONObject arg_object = args.getJSONObject(0);

            String merchantId = arg_object.getString("merchantId");
            this.initMobilePay(merchantId);
            return true;
        }
        if(action.equals("payWithMobilePay")) {
            JSONObject arg_object = args.getJSONObject(0);
            String orderId = arg_object.getString("orderId");
            String price = arg_object.getString("price");
            this.payWithMobilePay(orderId, price);
            return true;
        }
        return false;
    }

    private void getDeviceName(CallbackContext callbackContext) {
        String message = Build.MODEL;
        if(message != null && message.length() > 0){
            callbackContext.success(message);
            AlertDialog.Builder ppBuilder = new AlertDialog.Builder(this.webView.getContext());
            ppBuilder.setTitle("Yazz popup");
            ppBuilder.setMessage("My message");
            ppBuilder.setPositiveButton("OK", null);
            AlertDialog dialog = ppBuilder.show();
        }else{
            callbackContext.error("Empty string");
        }
    }


    private void initMobilePay(String merchantId) {
        MobilePay.getInstance().init(merchantId, Country.NORWAY);
        MobilePay.getInstance().setCaptureType(CaptureType.PARTIAL_CAPTURE);
        currentContext.success("Init called");
    }

    private void payWithMobilePay(String orderId, String price) {

        Activity activity = this.cordova.getActivity();
        Context context = activity.getApplicationContext();

        // Check if the MobilePay app is installed on the device.
        boolean isMobilePayInstalled = MobilePay.getInstance().isMobilePayInstalled(context);

        if (isMobilePayInstalled) {
            // MobilePay is present on the system. Create a Payment object.
            Payment payment = new Payment();
            payment.setProductPrice(new BigDecimal(price));
            payment.setOrderId(orderId);

            // Create a payment Intent using the Payment object from above.
            Intent paymentIntent = MobilePay.getInstance().createPaymentIntent(payment);

            // We now jump to MobilePay to complete the transaction. Start MobilePay and wait for the result using an unique result code of your choice.
            cordova.setActivityResultCallback (this);
            activity.startActivityForResult(paymentIntent, MOBILEPAY_PAYMENT_REQUEST_CODE);
        } else {
            // MobilePay is not installed. Use the SDK to create an Intent to take the user to Google Play and download MobilePay.
            Intent intent = MobilePay.getInstance().createDownloadMobilePayIntent(context);
            activity.startActivity(intent);
        }
    }

    @Override
        public void onActivityResult(int requestCode, final int resultCode, Intent data) {
          super.onActivityResult(requestCode, resultCode, data);
          if (requestCode == MOBILEPAY_PAYMENT_REQUEST_CODE) {
            // The request code matches our MobilePay Intent
            MobilePay.getInstance().handleResult(resultCode, data, new ResultCallback() {
              @Override
              public void onSuccess(SuccessResult result) {
                  String message = "Success";
                  String orderId = result.getOrderId();
                  String transactionId = result.getTransactionId();
                  currentContext.success("{\"orderId\": \""+orderId+"\",\"transactionId\": \""+transactionId+"\",\"message\": \""+message+"\",\"success\":\"true\"}");
                // The payment succeeded - you can deliver the product.
              }
              @Override
              public void onFailure(FailureResult result) {
                  String message = result.getErrorMessage();
                  String orderId = result.getOrderId();
                  Integer errorCode = result.getErrorCode();
                  currentContext.error("{\"orderId\": \""+orderId+"\",\"transactionId\": \"null\",\"message\": \""+message+"\",\"success\":\"false\"}");
                  // The payment failed - show an appropriate error message to the user. Consult the MobilePay class documentation for possible error codes.
              }
              @Override
              public void onCancel() {
                  currentContext.success("{\"orderId\": \"null\",\"transactionId\": \"null\",\"message\": \"Cancel\",\"success\":\"false\"}");
                  // The payment was cancelled.
              }
            });
          }
        }
}
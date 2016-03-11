package com.snappit;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;

import android.app.AlertDialog;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Build;

public class SnappitUtils extends CordovaPlugin {

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if(action.equals("getDeviceName")) {
            //String message = args.getString(0);
            this.getDeviceName(callbackContext);
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
}
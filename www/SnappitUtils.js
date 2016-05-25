
var snappitUtils = {    
    getDeviceName: function(successCallback, errorCallback) {
        cordova.exec(
            successCallback,
            errorCallback,
            "SnappitUtils",
            "getDeviceName",
            []
        );
    },
    initMobilePay: function(successCallback, errorCallback, options) {
        cordova.exec(
            successCallback,
            errorCallback,
            "SnappitUtils",
            "initMobilePay",
                     [options]
        );
    },
    payWithMobilePay: function(successCallback, errorCallback, options) {
        cordova.exec(
            successCallback,
            errorCallback,
            "SnappitUtils",
            "payWithMobilePay",
            [options]
        );
    },
    handleMobilePayment: function(successCallback, errorCallback, options) {
        cordova.exec(
            successCallback,
            errorCallback,
            "SnappitUtils",
            "handleMobilePayment",
                     [options]
        );
    }
};

module.exports = snappitUtils;

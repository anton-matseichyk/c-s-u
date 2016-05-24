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
    initMobilePay: function(successCallback, errorCallback) {
        cordova.exec(
            successCallback,
            errorCallback,
            "SnappitUtils",
            "initMobilePay",
            []
        );
    },
    payWithMobilePay: function(successCallback, errorCallback) {
        cordova.exec(
            successCallback,
            errorCallback,
            "SnappitUtils",
            "payWithMobilePay",
            []
        );
    }
};

module.exports = snappitUtils;
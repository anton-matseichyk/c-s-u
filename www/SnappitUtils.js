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
    },
    handleOpenUrl: function(successCallback, errorCallback, options) {
        cordova.exec(
            successCallback,
            errorCallback,
            "SnappitUtils",
            "handleOpenUrl",
            [options]
        );
    }
};

module.exports = snappitUtils;
var snappitUtils = {
    
    getDeviceName: function(successCallback, errorCallback) {
        cordova.exec(
            successCallback,
            errorCallback,
            "SnappitUtils",
            "getDeviceName",
            []
        );
    }
    
};

module.exports = snappitUtils;

var app = {
    // Application Constructor
    initialize: function() {
        this.bindEvents();
    },
    // Bind Event Listeners
    //
    // Bind any events that are required on startup. Common events are:
    // 'load', 'deviceready', 'offline', and 'online'.
    bindEvents: function() {
        document.addEventListener('deviceready', this.onDeviceReady, false);
    },
    // deviceready Event Handler
    //
    // The scope of 'this' is the event. In order to call the 'receivedEvent'
    // function, we must explicitly call 'app.receivedEvent(...);'
    onDeviceReady: function() {
        var buttonElement = document.getElementById('snappit-plugin');
        buttonElement.addEventListener('click', app.handleButtonClick, false);
        window.handleOpenUrl = function(url){
            snappitUtils.handleOpenURL(function(success){
                alert('success');
            },
            function(error){
                alert(error);
            },
            {
                "url": url
            });
        };
    },
    handleButtonClick: function(){
        if(window.snappitUtils){
                snappitUtils.initMobilePay(function(success){
                    console.log(success);
                    snappitUtils.payWithMobilePay();
                })
           }else{
                alert("no plugin");
           }
    }
};

app.initialize();
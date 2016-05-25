
var app = {
    initialize: function() {
        this.bindEvents();
    },
    bindEvents: function() {
        document.addEventListener('deviceready', this.onDeviceReady, false);
    },
    onDeviceReady: function() {
        var buttonElement = document.getElementById('snappit-plugin');
        buttonElement.addEventListener('click', app.handleButtonClick, false);
        window.handleOpenURL = function(result){
            setTimeout(function(){
                console.log(result);
                //only for ios
                snappitUtils.handleMobilePayment(
                    app.handleMobilePaymentResponse,
                    app.handleMobilePaymentResponse,
                    {
                        "url": result
                    });
            },0);
        };
    },
    handleButtonClick: function(){

        if(window.snappitUtils){
                snappitUtils.initMobilePay(
                    function(success){
                        console.log(success);
                        snappitUtils.payWithMobilePay(
                            app.handleMobilePaymentResponse,
                            app.handleMobilePaymentResponse,
                            {
                                "orderId":"123456",
                                "price":"0.01"
                            });
                    },
                    function(error){},
                    {
                        "merchantId":"APPDK0000000000",
                        "merchantUrlScheme":"snappshop"
                    })
           }else{
                alert("no plugin");
           }
    },
    handleMobilePaymentResponse: function(result){
        console.log(result);
        alert(result);
    }
};

app.initialize();
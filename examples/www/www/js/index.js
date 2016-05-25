
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
                snappitUtils.handleMobilePayment(
                    function(result){
                        console.log(result);
                        alert(result);
                    },
                    function(error){
                        console.log(error);
                        alert(error);
                    },
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
                        snappitUtils.payWithMobilePay(
                            function(){},
                            function(){},
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
    }
};

app.initialize();
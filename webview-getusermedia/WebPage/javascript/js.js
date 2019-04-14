
var ABswitch = false;

function test(val) {

    var canvas = document.getElementById("canvas");
    var context = canvas.getContext("2d");


            console.log('haha')


    if(ABswitch){
        var imageA = new Image();
        ABswitch = !ABswitch
        document.getElementById("img").src = val;
        document.getElementById("h1").innerHTML = "yuck";
        imageA.src = val
            document.getElementById("h1").innerHTML = val;
            context.drawImage(imageA, 0, 0)
            webkit.messageHandlers.callbackHandler.postMessage(val);
    }
    else{
        var imageB = new Image();
        ABswitch = !ABswitch
        imageB.src = val
            context.drawImage(imageB, 0, 0)
            webkit.messageHandlers.callbackHandler.postMessage(val);
    }

}



var ABswitch = false;

function test(val) {

    var canvas = document.getElementById("canvas");
    var context = canvas.getContext("2d");
    var imageA = new Image();
    var imageB = new Image();


    if(ABswitch){
        ABswitch = !ABswitch
        imageA.src = val
        imageA.onload = function() {
            context.clearRect(0, 0, canvas.width, canvas.height);

            context.drawImage(imageA, 0, 0)
        };
    }
    else{
        ABswitch = !ABswitch
        imageA.src = val
        imageB.src = val
        imageB.onload = function() {
            context.clearRect(0, 0, canvas.width, canvas.height);

            context.drawImage(imageB, 0, 0)
        };
    }

    video.onended = function(){
        webkit.messageHandlers.callbackHandler.postMessage(val);
    }
}


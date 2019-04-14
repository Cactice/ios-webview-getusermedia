var ABswitch = false;

var initialCall = true;
var canvas = document.getElementById("canvas");
var context = canvas.getContext("2d");

function playOnCanvas(video){
    draw(video,context,canvas.width,canvas.height);
}


var videoStream = [] //FIFO

function addVideo(url){
    var newVid = document.createElement('video');
    newVid.addEventListener('play', function(){playOnCanvas(newVid)});
    newVid.addEventListener('ended',switchOnCanvas2);
    newVid.setAttribute("playsinline",null);
    newVid.setAttribute("webkit-playsinline",null);
    newVid.src = url
    newVid.muted = true
    newVid.webkitPlaysinline = true
    videoStream.push(newVid)
}

function switchOnCanvas(endedVideo,nextVideo) {
    endedVideo.play()
}

function switchOnCanvas2(endedVideo,nextVideo) {
    (function playNextVideo(){
        try {
            endedVideo = videoStream[0]
            if(videoStream.length < 2){
                nextVideo = videoStream[0]
            }else{
                nextVideo = videoStream[videoStream.length - 1]
            }
        } catch {
            setTimeout(playNextVideo, 100);
        }
        try {
            nextVideo.play().then(function() {
                webkit.messageHandlers.callbackHandler.postMessage(videoStream[0].src);
                if(videoStream.length < 2){
                    videoStream.shift()
                }else{
                    videoStream.splice(0,videoStream.length-2)
                }
            }).catch(function(error) {
                setTimeout(playNextVideo, 100);
            });
        } catch {
            setTimeout(playNextVideo, 100);
        }
    })()
}


function test(val) {
    console.log(val,)
    addVideo(val)
    if(initialCall===true){
        (function playFirstVideo(){
            videoStream[0].play().catch(function() {
                setTimeout(playFirstVideo, 100);
            });
        })()
        initialCall = false
    }

}

function draw(v,c,w,h) {
    if(v.paused || v.ended) return false;
    c.drawImage(v,0,0,w,h);
    setTimeout(draw,20,v,c,w,h);
}
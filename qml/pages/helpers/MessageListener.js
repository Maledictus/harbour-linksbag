window.WebPirate_MessageListenerObject = function() {
    navigator.qt.onmessage = this.onMessage.bind(this);
};

window.WebPirate_MessageListenerObject.prototype.onMessage = function(message) {
    var obj = JSON.parse(message.data);
    var data = obj.data;

    if(obj.type === "readermodehandler_enable")
        WebPirate_ReaderModeHandler.switchMode(true);
};

window.WebPirate_MessageListener = new window.WebPirate_MessageListenerObject();

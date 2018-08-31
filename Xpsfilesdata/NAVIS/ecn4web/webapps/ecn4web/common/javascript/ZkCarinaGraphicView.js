var ZkCarinaGraphicView = $.extend({}, ZkGraphicScript, {

    //observer: null,

    realize: function () {
        console.log('ZkCarinaGraphicView.realize: ' + this._domId);
        init(this);
        // this is sample code for adding an observer to the websocket connection
        // observer = new NavisWebSocketObserver();
        // observer.update = function (value) {
        //     console.log('ZkCarinaGraphicView.update: ' + value);
        // };
        // NavisWebSocket.getInstance().addObserver(observer);
    },

    sendMessage: function (msg) {
        NavisWebSocket.getInstance().sendMessage(JSON.stringify(msg));
    },

    // dispose: function () {
    //     NavisWebSocket.getInstance().removeObserver(observer);
    // }

});

console.log('loaded carinaGraphicView.js');

window['com.navis.registry'].push(ZkCarinaGraphicView);

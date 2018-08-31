/*
 * Copyright (c) 2017 Navis LLC. All Rights Reserved.
 *
 */

zk.afterLoad('zul.mesh,zul.sel', function() {

    var navisWebSocket = NavisWebSocket.getInstance();

    liveStreaming = {
        keepColumnWidths : function(head) {
            var header = head.firstChild;
            var width = zk(header).offsetWidth();
            /*simulates a manual column resize freezing the column widths*/
            zul.mesh.HeaderWidget._aftersizing({control: header, _zszofs: width}, {data: {}});
        },

        // callback by navis web socket observer api.
        update : function(context) {
            //debugger;
            // message.uuid, command, and data are defined in LiveStreamingModel.sendWidgetCommand()
            var message = JSON.parse(context);
            var targetWidget = zk.$('#' + message.uuid);
            var command = message.command;
            if (command == "streamingUpdate") {
                updateItems(targetWidget, message.data.updatedItems);
            } else if (command == 'requestSynchronizeAddedRemovedEvent') {
                liveStreaming.sendEvent(targetWidget, 'onRequestSynchronizeAddedRemoved');
                // } else {
                //     zk.log("Unknown command: " + message.command);
            }
        },

        startLiveUpdates : function (widget) {
            _initializeWebSocketIfNull();

            //debugger;
            console.log("startLiveUpdates() " + widget);
            if(!widget.liveStreamingConnected) {
                widget.liveStreamingConnected = true;
                console.log("connect widget", widget.domExtraAttrs['serverTableHash'], liveStreaming.currentWidgetCount);
                var sendLiveStreamingReady = function() {
                    liveStreaming.sendComponentMessage(widget, widget.domExtraAttrs['serverTableHash'], 'onLiveStreamingReady', null)
                    navisWebSocket.removeWsEventListener('open', sendLiveStreamingReady);
                };
                if(navisWebSocket.isConnected()) {
                    sendLiveStreamingReady();
                } else {
                    navisWebSocket.addWsEventListener('open', sendLiveStreamingReady);
                }
            }
            navisWebSocket.addObserver(liveStreaming);
        },

        stopLiveUpdates : function (widget) {
            _initializeWebSocketIfNull();

            console.log("disconnect widget", widget.domExtraAttrs['serverTableHash'], liveStreaming.currentWidgetCount);
            //debugger;
            navisWebSocket.removeObserver();
        },

        sendEvent: function(widget, eventName, data) {
            console.log('sendEvent via zkau', eventName);
            zAu.send(new zk.Event(widget, eventName, data, {toServer:true}));
        },

        sendComponentMessageAfterRender : function(widget, command, data) {
            console.log("requestAfterClientRenderComponentMessage() " + widget);
            // new items added on the server side, request the server to fire event.
            var listener = {onCommandReady : [widget, function() {
                liveStreaming.sendComponentMessage(widget, widget.domExtraAttrs['serverTableHash'], command, data);
                zWatch.unlisten(listener);
            }]};
            zWatch.listen(listener);
        },

        sendComponentMessage: function (widget, serverTableHash, command, data) {
            _initializeWebSocketIfNull();

            console.log('send via websocket', command);
            navisWebSocket.sendMessage(JSON.stringify({componentMessage: {tableHash: serverTableHash, command: command, data: data}}));
        }
    };

    //navisWebSocket.setOnReceiveHandler(liveStreaming.handleWidgetCommandMessage);

    function updateItems(widget, updatedItems) {
        //update rows according to gkey
        for(var elementIndex in updatedItems) {
            var entity = updatedItems[elementIndex];
            var tableIdAndTupleId = widget.domExtraAttrs['serverTableHash'] + entity.gkey;
            var row = document.querySelector('[data-item-id="' + tableIdAndTupleId + '"]');
            if(row) {
                var fieldChanges = entity.fieldChanges;
                for (var fieldIndex in fieldChanges) {
                    var field = fieldChanges[fieldIndex];
                    var css = field.css + " z-listcell";
                    delete field.css;
                    for (var property in field) {
                        if (field.hasOwnProperty(property)) {
                            var elem = row.querySelector('[mfid="' + property + '"]');
                            if (elem) {
                                var $cells = jq(elem).find('.z-listcell-content');
                                $cells[0].innerText = field[property];
                                if (css) {
                                    elem.className = css;
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Sometimes when a user reloads the page and live streaming views are open,
    // it calls this file, except that this file was loaded before NavisWebSocket,
    // leaving navisWebSocket as null. So, just run it just in case.
    function _initializeWebSocketIfNull () {
        if (navisWebSocket == null){
            navisWebSocket = NavisWebSocket.getInstance();
        }
    }

}); //zk.afterLoad


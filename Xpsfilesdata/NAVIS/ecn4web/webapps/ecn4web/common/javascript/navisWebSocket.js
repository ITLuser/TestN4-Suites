/*
 * Copyright (c) 2016 Navis LLC. All Rights Reserved.
 *
 */

var NavisWebSocket  = (function () {
    var instance;

    var Socket = function (uri) {
        this._ws = new ReconnectingWebSocket(uri,null,{debug: false, reconnectInterval: 3000});

        this._ws.onopen = this._handleOpen.bind(this);
        this._ws.onerror = this._handleError.bind(this);
        this._ws.onmessage = this._handleMessage.bind(this);
        this._ws.onclose = this._handleClose.bind(this);
    };

    Socket.prototype = {
        onopen: null,
        onerror: null,
        onmessage: null,

        _handleOpen: function () {
            if (this.onopen) {
                this.onopen();
            }
        },

        _handleError: function (error) {
            if (this.onerror) {
                this.onerror(error);
            }
        },

        _handleMessage: function (msg) {
            if (this.onmessage) {
                this.onmessage(msg);
            }
        },

        _handleClose: function () {
            if (this.onclose) {
                this.onclose();
            }
        },

        send: function (msg) {
            this._ws.send(msg);
        }
    };

    var ObserverList = function () {
        this.observerList = [];
    }

    ObserverList.prototype.add = function (obj) {
        return this.observerList.push(obj);
    };

    ObserverList.prototype.count = function () {
        return this.observerList.length;
    };

    ObserverList.prototype.get = function (index) {
        if (index > -1 && index < this.observerList.length) {
            return this.observerList[index];
        }
    };

    ObserverList.prototype.indexOf = function (obj, startIndex) {
        var i = startIndex;

        while (i < this.observerList.length) {
            if (this.observerList[i] === obj) {
                return i;
            }
            i++;
        }

        return -1;
    };

    ObserverList.prototype.removeAt = function (index) {
        this.observerList.splice(index, 1);
    };

    ObserverList.prototype.clear = function () {
        this.observerList = [];
    };

    function init(desktopUuid) {
        var _websocket;
        var _observers;
        if (desktopUuid != null) {
            var wsUrl = window.location.href.replace(/^http(s?:\/\/.*)\/.*$/, 'ws$1/' + 'navisWebSocketEntryPoint') + '?dtid=' + desktopUuid;
            //zk.log("ws connecting to " + wsUrl);
            _websocket = new Socket(wsUrl);
            _observers = new ObserverList();
        } else {
            console.log("ws conntecting to null");
        }
        return {
            isConnected: function () {
                if (_websocket == null) {
                    return false;
                }
                return _websocket._ws.readyState == WebSocket.OPEN;
            },
            sendMessage: function (msg) {
                //zk.log('NavisWebSocket.sendMessage: ' + msg);
                _websocket.send(msg);
            },
            setOnConnectHandler: function (f) {
                _websocket.onopen = f;
            },
            setOnReceiveHandler: function (f) {
                if (_websocket != null) {
                    _websocket.onmessage = f;
                }
            },

            addWsEventListener: function (eventName, f) {
				console.log("addWsEventListener() eventName:" + eventName);
            	_websocket._ws.addEventListener(eventName, f);
            },
            removeWsEventListener: function (eventName, f) {
                console.log("removeWsEventListener() eventName:" + eventName);
            	_websocket._ws.removeEventListener(eventName, f);
            },
            getObserverCount: function() {
                _observers.length;
            },
            addObserver: function (observer) {
                _observers.add(observer);
            },
            removeObserver: function (observer) {
                _observers.removeAt(_observers.indexOf(observer, 0));
            },
            removeAllObservers: function (observer) {
                _observers.clear();
            },
            notify: function (context) {
                var observerCount = _observers.count();
                for (var i = 0; i < observerCount; i++) {
                    _observers.get(i).update(context);
                }
            }
        };
    };

    return {
        connect: function (desktopUuid) {
            if (!instance) {
                instance = init(desktopUuid);
            }
            return instance;
        },
        isConnected: function () {
            if (instance != null) {
                return instance.isConnected();
            } else {
                return false;
            }
        },
        getInstance: function() {
            return instance;
        }
    };
})();

function NavisWebSocketObserver () {
    this.update = function (value) {
        //zk.log('NavisWebSocketObserver.update :' + value);
    };
}
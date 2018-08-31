/**
 * Provides application lifecycle and client-server communication support between a client-side widget
 * (i.e. ZkScriptWrapper.js) and its server-side component peer (i.e. ZkScriptWrapper.java).
 * <p>
 * The user MUST create a custom view
 * widget script by extending one of the scripts in this file and registering an instance with the system.
 * Registration is achieved by including a statement
 * of the form "window['com.navis.registry'].push(myViewScript);", where "myViewScript" is a reference to the view script instance.
 * Note that only the first script in the registry is used.  The view widget script and any other system and user widget scripts
 * (e.g. graphics libraries used by the view script) will be loaded by the system, and the
 * user's view script will be "realized", thereby establishing two-way messaging between the the server component
 * and the client widget view peers.
 * <p>
 * The global variable "log" is available for log4j-like logging support (e.g. log.warn('my message') to generate a warning level message).
 * By default the reporting threshold is set to WARN.  Use log.setLevel(log4javascript.Level.???) to adjust the reporting level
 * (e.g. Level.ALL for all levels, including trace).
 *
 * NOTE, given javascript's prototypical inheritance nature, there is no point to make ZkSystemScript prototype.  Thus, we delcare it in a way
 * to reuse the same instance when it already exists.  It's also generally true for our application developers who want to create javascript
 * utillity library.  It's good idea to make the utility js class singleton.
 */

if (typeof log == 'undefined' && typeof log4javascript != 'undefined') {
    log = log4javascript.getDefaultLogger();
    log.setLevel(log4javascript.Level.WARN);
}

var ZkSystemScript = ZkSystemScript || {
    /**
     * Gets the DOM ID of the view widget, which is that of the root DOM element.
     * @return ID string.
     */
    getDomId: function() {
        return this._domId;
    },

    /**
     * Gets the root DOM element for the view widget, which is what presents the view widget to the user via a browser.
     * In ZK, a client widget may be comprised of multiple HTML elements, with the "mold" orchestrating how to compose
     * the elements to form a widget.  The DOM root element should be used for accessing widget styling.
     * @return Exposed DOM element.
     */
    getDomWidget: function() {
        return this._zkWidget.$n();
    },

    /**
     * Gets the cave DOM element for the view widget. ZK uses the "cave" node child of the root node to hold the actual content of
     * the view widget.  The DOM cave element should be used for accessing widget geometry (size, position), which may be different
     * from that of the root since the root may contain widget decorations.
     * @return Exposed DOM element.
     */
    getDomWidgetCave: function() {
        return this._zkWidget.getCaveNode();
    },

    /**
     * Gets the ZK proxy for the view widget, which hosts and wraps this view widget script.
     * @return Exposed ZK object, type ZkScriptWrapper.
     */
    getZkWidget: function() {
        return this._zkWidget;
    },

    /**
     * Gets the attributes associated with this client-side widget.  Initialized by
     * the server-side component upon widget realization.
     * @return Shared exposed attribute map (Map<String, Object>). Never null.
     */
    getAttributes: function() {
        return this._zkWidget.getAttributes();
    },

    /**
     * Called by the user to send a message to this widget's server component, as a data map.
     * @param inMessage Temp input data map (Map<String,Object>).
     */
    sendMessage: function(inMessage) {
        this._zkWidget.sendMessage(inMessage); // notify server-side component
    },

    /**
     * Called by the system to receive a message from this widget's server component, as a data map.
     * @param inMessage Ceded data map (Map<String,Object>).
     */
    receiveMessage: function(inMessage) {
        log.info('ZkSystemScript.receiveWidgetMessage: Override to do something. id=' + this._domId);
    },

    /**
     * Called by the system after the client-side widget has been initialized, but before the server-side component
     * has been realized.  Allows the client-side widget to complete realization.  When called, the widget size
     * (getWidth(), getHeight()) should be valid.
     */
    realize: function() {
        log.info('ZkSystemScript.realize: Override to do something. id=' + this._domId);
    },

    /**
     * A right-mouse click hook to allow subclass to override.
     * @param inEvent click event
     */
    onRightClick: function(inEvent) {
        log.info('ZkSystemScript.onRightClick: Override to do something. id=' + this._domId);
    },

    /**
     * Called by the system after the client-side widget is disposed.  This hook provides the custom
     * application a chance to clean up any resource it created.
     */
    dispose: function() {
        log.info('ZkSystemScript.dispose: Override to do something. id=' + this._domId);
    },

    /**
     * Called by the user to report an error to this widget's server component, as a string message.
     * A stack trace will be included automatically.
     * @param inMessage Temp input message (String).
     */
    sendError: function(inMessage) {
        var error = new Error(inMessage);
        var errorMessage = error.stack;
        this._zkWidget.sendError(errorMessage); // notify server-side component
    },

    // personal

    /** Private constructor called by the system when an instance is created. */
    __construct: function() { // private constructor
        log.trace("ZkSystemScript.construct: Begin");
        // nothing to do
    }(),

    /**
     * Must be called by subclasses before general use.
     * @param inZkWidget Shared exposed client-side view peer. Never null.
     */
    initZkSystemScript: function(inZkWidget) {
        this._zkWidget = inZkWidget;
        this._domId = inZkWidget.$n().id;

        log.trace('ZkSystemScript.initZkSystemScript: End. id=' + this._domId);
    },

    _domId: '',
    _zkWidget: null // ZK widget wrapping this view widget script
};

/**
 * A ZkSystemScript that provides specific support for a graphical canvas view.  Client-side layout of the view widget, with
 * possible user interaction, determines its width and height.
 */
var ZkGraphicScript = ZkGraphicScript || $.extend({}, ZkSystemScript, {
    getWidth: function() {
        return this._width;
    },

    getHeight: function() {
        return this._height;
    },

    /**
     * Called by the system, after realization, when the widget size changes, whether due to user
     * interaction on the client-side, or application interaction from the server-side.  Not called
     * during start up -- use realize() instead.  Default does nothing.
     */
    updateSize : function(inWidth, inHeight) {
        log.info('ZkGraphicScript.updateSize: Override to do something. id=' + this._domId);
    },

    /**
     * Called by the system, after realization, to command the widget to sync its layout geometry.
     * Intended for use by an ancestor controller for syncing the mutual layout of its descendant graphic views after
     * they are realized. Typicaly, if enabled, the widget publishes its key layout geometry.  Default does nothing.
     */
    syncLayout: function() {
        log.info('ZkGraphicScript.syncLayout: Override to do something. id=' + this._domId);
    },

    // personal

    /** Private constructor called by the system when an instance is created. */
    __construct: function() { // private constructor
        log.trace("ZkGraphicScript.construct: Begin");
        // nothing to do
    }(),

    /**
     * Must be called by subclasses before general use.
     * @param inZkWidget Shared exposed client-side view peer. Never null.
     */
    initZkGraphicScript : function(inZkWidget) {
        this.initZkSystemScript(inZkWidget);

        // get initial screen size
        this._width = inZkWidget.getCaveNode().offsetWidth;
        this._height = inZkWidget.getCaveNode().offsetHeight;
    },

    _width: 0,			// canvas width (pixels)
    _height: 0			// canvas height (pixels)
});

/**
 * Create a singleton global view widget script "registry". The user must add a reference to the view widget script
 * to this registry so that ZkScriptWrapper can connect it to its peers and "realize" it.
 */
if (window['com.navis.registry'] == null) {
    window['com.navis.registry'] = []; // empty
}
/**
 * Create a singleton global view library "registry".  Loaded javascript is recorded in this variable.  This is used to prevent any previously
 * loaded javascript from loading again.
 */
if (window['com.navis.loaded.js'] == null) {
    window['com.navis.loaded.js'] = []; // empty
}
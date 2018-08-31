/*
 * Copyright (c) 2010 Zebra Technologies Corp. All Rights Reserved.
 * $Id: $
 */
/*
 * This javascript file represents extensions and overrides to the OpenLayers javascript library.
 * It should always be loaded after the OpenLayers javascript library has loaded because of dependencies
 */

OpenLayers.ImgPath = 'common/images/openlayers/';
// Augment the Map class with a new function to trigger the opening of the context menu
OpenLayers.Map.prototype.triggerContextMenuClick = function (evt) {
    var layers = this.layers;
    var feature = null, eventFeature = null;
    var marker = null, eventMarker = null;

    evt.xy = this.events.getMousePosition(evt);

    /* precedence ranks to facilitate feature selection when more than one feature intersect; smallest vector gets the lowest precedence rank & wins
    selection; precedece is defined here and set before adding a vector to a layer. Default precedence is 99 and set in ZVector. Validation here
    is second level to check precedence across layers. */
    var precedence = 100;
    for(var i = 0; i < layers.length; i++) {
        var layer = layers[i];
        if(layer.visibility) {
            if (layer.getFeatureFromEvent) {
                feature = layer.getFeatureFromEvent(evt);
                if (feature && feature.attributes && (!feature.attributes.selectionPrecedence || precedence > feature.attributes.selectionPrecedence)) {
                    eventFeature = feature;
                    precedence = feature.attributes.selectionPrecedence;
                }
            }
            if (layer.getMarkerFromEvent) {
                marker = layer.getMarkerFromEvent(evt);
                if (marker) {
                    eventMarker = marker;
                    break;
                }

            }
        }
    }
    this.events.triggerEvent("contextMenuClick", {
        pageX: evt.pageX,
        pageY: evt.pageY,
        xy: evt.xy,
        feature: eventFeature,
        marker: eventMarker,
        excludeGeometry: true
    });
};
// Change the default order for the vector layer
OpenLayers.Layer.Vector.prototype.renderers = ["Canvas", "SVG", "VML"];

/**
 * Override the default OpenLayers behavior - 1) to disable those controls referring to a layer when the layer is hidden
 * 2) add one more parameter to setVisibility() to let the caller set whether to trigger the event or not.
 */
zk.$package("com.navis.OpenLayers.Layer");
com.navis.OpenLayers.Layer.Vector = OpenLayers.Class(OpenLayers.Layer.Vector, {
    EVENT_TYPES: ["refreshbbox"],
    initialize: function(name, options) {
        // concatenate events specific to vector with those from the base
        OpenLayers.Layer.Vector.prototype.EVENT_TYPES =
            com.navis.OpenLayers.Layer.Vector.prototype.EVENT_TYPES.concat(
            OpenLayers.Layer.Vector.prototype.EVENT_TYPES
        );
        OpenLayers.Layer.Vector.prototype.initialize.apply(this, arguments);
        this.events.register("visibilitychanged",this,this.onVisibilityChanged);
    },

    onVisibilityChanged : function() {
        this.resetControls();
    },

    resetControls : function() {
        if (this.map) {
            var controls = this.map.controls;
            for (var i = 0; i < controls.length; i++) {
                var control = controls[i];
                if (control instanceof com.navis.OpenLayers.Control.Panel) {
                    var panelControls = control.getControls();
                    for (var p = 0; p < panelControls.length; p++) {
                        this.resetControl(panelControls[p]);
                    }
                }
            }
            return true;
        }
        return false;
    },


    resetControl : function(inControl) {
        if (inControl.layer && inControl.layer.name === this.name) {
            if (this.visibility) {
                inControl.enable();
            } else {
                inControl.disable();
            }
        }
    },

    setVisibility: function(visibility, options) {
        if (visibility != this.visibility) {
            this.visibility = visibility;
            this.display(visibility);
            this.redraw();
            var notify = !options || !options.silent;
            if(notify) {
                if (this.map != null) {
                    this.map.events.triggerEvent("changelayer", {
                        layer: this,
                        property: "visibility"
                    });
                }
                this.events.triggerEvent("visibilitychanged");
            }
        }
    },

    CLASS_NAME: "com.navis.OpenLayers.Layer.Vector"
});

/**
 * Override the default OpenLayers behavior - 1) add new state 'disabled' to the control.
 */
zk.$package('com.navis.OpenLayers');
com.navis.OpenLayers.Control = OpenLayers.Class(OpenLayers.Control, {

    disabled:false,

    EVENT_TYPES: ["disabled", "enabled"],

    initialize: function (options) {
        this.EVENT_TYPES =
                com.navis.OpenLayers.Control.prototype.EVENT_TYPES.concat(
                        OpenLayers.Control.prototype.EVENT_TYPES
                        );
        OpenLayers.Control.prototype.initialize.apply(this, [options]);
    },

    disable: function () {
        if (!this.disabled) {
            this.deactivate();
            if (this.map) {
                this.div.setAttribute("unselectable", "on", 0);
                this.div.onselectstart = OpenLayers.Function.False;
                OpenLayers.Element.addClass(
                        this.map.viewPortDiv,
                        this.displayClass.replace(/ /g, "") + "Disabled"
                        );
            }
            this.disabled = true;
            this.events.triggerEvent("disabled");
            return true;
        }
        return false;
    },

    enable: function () {
        if (this.disabled) {
            this.div.removeAttribute("unselectable");
            this.div.onselectstart = OpenLayers.Function.True;
            if (this.map) {
                OpenLayers.Element.removeClass(
                        this.map.viewPortDiv,
                        this.displayClass.replace(/ /g, "") + "Disabled"
                        );
            }
            this.disabled = false;
            this.events.triggerEvent("enabled");
            return true;
        }
        return false;
    },

    CLASS_NAME: "com.navis.OpenLayers.Control"
});

/**
 * To extend our new com.navis.OpenLayers.Control so that it can have the new state 'disabled/enabled'
 */
zk.$package('com.navis.OpenLayers.Control');
com.navis.OpenLayers.Control.DrawFeature = OpenLayers.Class(OpenLayers.Control.DrawFeature, com.navis.OpenLayers.Control, {

    initialize: function(inLayer, inHandler, inOptions) {
        OpenLayers.Control.DrawFeature.prototype.initialize.apply(this, arguments);
    },

    CLASS_NAME: "com.navis.OpenLayers.Control.DrawFeature"
});

/**
 * To extend our new com.navis.OpenLayers.Control so that it can have the new state 'disabled/enabled'
 */
zk.$package('com.navis.OpenLayers.Control');
com.navis.OpenLayers.Control.ModifyFeature = OpenLayers.Class(OpenLayers.Control.ModifyFeature, com.navis.OpenLayers.Control, {

    EVENT_TYPES: [],
    /**
     * Constructor: OpenLayers.Control.ModifyFeature
     * Create a new modify feature control.
     *
     * Parameters:
     * layer - {<OpenLayers.Layer.Vector>} Layer that contains features that
     *     will be modified.
     * options - {Object} Optional object whose properties will be set on the
     *     control.
     */
    initialize: function(inLayer, inOptions) {
        this.EVENT_TYPES =
                com.navis.OpenLayers.Control.prototype.EVENT_TYPES.concat(
                        OpenLayers.Control.prototype.EVENT_TYPES
                        );
        OpenLayers.Control.ModifyFeature.prototype.initialize.apply(this, arguments);

        this.deleteCodes = [46];
    },

    activate:function() {
        return OpenLayers.Control.ModifyFeature.prototype.activate.apply(this, arguments);
    },

    /**
     * APIMethod: deactivate
     * Deactivate the control.
     *
     * Returns:
     * {Boolean} Successfully deactivated the control.
     */
    deactivate: function() {
        return OpenLayers.Control.ModifyFeature.prototype.deactivate.apply(this, arguments);
    },

    setMap: function(map) {
        OpenLayers.Control.ModifyFeature.prototype.setMap.apply(this, arguments);
    },

    CLASS_NAME: "com.navis.OpenLayers.Control.ModifyFeature"
});

/**
 * OverviewMapWithZoomBar is a composite of an overview with a nested zoom bar.
 */
zk.$package('com.navis.OpenLayers.Control');
com.navis.OpenLayers.Control.OverviewMapWithZoomBar = OpenLayers.Class(OpenLayers.Control.OverviewMap, {
    /**
     * Method: draw
     * Render the control in the browser.
     */
    draw: function() {
        OpenLayers.Control.OverviewMap.prototype.draw.apply(this, arguments);
		if (this.div != null && this.map.baseLayer) {
		    var panZoom = new com.navis.OpenLayers.Control.ZoomBar();
            //panZoom.panIcons = false;  // this property will be available in operlayers version 2.11. See comment in ZoomBar class below.
			panZoom.div = this.div.children[0];
			this.map.addControl(panZoom);
		}
        return this.div;
    },

    CLASS_NAME: "com.navis.OpenLayers.Control.OverviewMapWithZoomBar"
});

/**
 * The only purpose of ZoomBar is to hide the pan buttons inside OverviewMapWithZoomBar.  When we upgrade to operlayers version 2.11, we
 * can use "panZoomBar.panIcons = false", and remove this com.navis.OpenLayers.Control.ZoomBar class all together.
 */
zk.$package('com.navis.OpenLayers.Control');
com.navis.OpenLayers.Control.ZoomBar = OpenLayers.Class(OpenLayers.Control.PanZoomBar, {
    /**
     * Method: draw
     *
     * Parameters:
     * px - {<OpenLayers.Pixel>}
     */
    draw: function(px) {
        // initialize our internal div
    	OpenLayers.Control.prototype.draw.apply(this, arguments);
        px = this.position.clone();

        // place the controls
        this.buttons = [];

        var sz = new OpenLayers.Size(18,18);
        var centered = new OpenLayers.Pixel(px.x+sz.w/2, px.y-25);

        var zInButton = this._addButton("zoomin", "null_16x16.png", centered.add(0, sz.h+5), sz);
        zInButton.className = "zoomin"
        centered = this._addZoomBar(centered.add(0, sz.h*2 + 5));
        var zOutButton = this._addButton("zoomout", "null_16x16.png", centered, sz);
        zOutButton.className = "zoomout"
    	return this.div;
    },
    CLASS_NAME: "com.navis.OpenLayers.Control.ZoomBar"
});

zk.$package('com.navis.OpenLayers.Control');
com.navis.OpenLayers.Control.DrawMarker = OpenLayers.Class(OpenLayers.Control, {

    /**
     * Property: layer
     * {<OpenLayers.Layer.Markers>}
     */
    layer: null,

    /**
     * Property: icon
     * {<OpenLayers.Icon.}
     */
    icon: null,

    /**
     * Constant: EVENT_TYPES
     *
     * Supported event types:
     * markeradded - Triggered when a feature is added
     */
    EVENT_TYPES: ["markeradded"],

    /**
     * Constructor: OpenLayers.Control.DrawFeature
     *
     * Parameters:
     * inLayer - {<OpenLayers.Layer.Vector>}
     * inIcon - {<OpenLayers.Icon>}
     * inOptions - {Object}
     */
    initialize: function(inLayer, inIcon, inOptions) {

        // concatenate events specific to vector with those from the base
        this.EVENT_TYPES =
            com.navis.OpenLayers.Control.DrawMarker.prototype.EVENT_TYPES.concat(
            OpenLayers.Control.prototype.EVENT_TYPES
        );

        OpenLayers.Control.prototype.initialize.apply(this, [inOptions]);

        this.layer = inLayer;
        this.icon = inIcon;

        this.handler = new OpenLayers.Handler.Click(this, {
            click: this.drawMarker
        });
    },

    destroy: function() {
        if (this.icon) {
            this.icon.destroy();
        }
        this.icon = null;

        if (this.handler) {
            this.handler.destroy();
        }
        this.handler = null;

        OpenLayers.Control.prototype.destroy.apply(this, arguments);
    },

    /**
     * Method is called when a new marker should be drawn
     *
     * Parameters:
     * inEvent - {<OpenLayers.Event>}
     */
    drawMarker: function(inEvent) {
        var lonlat = this.map.getLonLatFromPixel(inEvent.xy);
        var marker = new OpenLayers.Marker(lonlat, this.icon.clone());
        this.layer.addMarkers(marker);
        this.events.triggerEvent("markeradded",{marker : marker});
    },

    CLASS_NAME: "com.navis.OpenLayers.Control.DrawMarker"
});

zk.$package('com.navis.OpenLayers.Control');
com.navis.OpenLayers.Control.SelectMarker = OpenLayers.Class(OpenLayers.Control, {
    /**
     * Constant: EVENT_TYPES
     *
     * Supported event types:
     *  - *beforemarkerhighlighted* Triggered before a marker is highlighted
     *  - *markerhighlighted* Triggered when a marker is highlighted
     *  - *markerunhighlighted* Triggered when a marker is unhighlighted
     */
    EVENT_TYPES: ["beforemarkerhighlighted", "markerhighlighted", "markerunhighlighted"],

    /**
     * Property: layers
     * {Array(<OpenLayers.Layer.Vector>} The layers this control will work on,
     * or null if the control was configured with a single layer
     */
    layers: null,

    /**
     * Constructor: com.navis.OpenLayers.Control.SelectMarker
     */
    initialize: function(layers, options) {
        this.EVENT_TYPES =
            com.navis.OpenLayers.Control.SelectMarker.prototype.EVENT_TYPES.concat(
            OpenLayers.Control.prototype.EVENT_TYPES
        );

        OpenLayers.Control.prototype.initialize.apply(this, [options]);

        if(!(layers instanceof Array)) {
            layers = [layers];
        }

        this.layers = layers;

        var callbacks = {
            click: this.clickMarker,
            clickout: this.clickoutMarker
        };

        this.callbacks = OpenLayers.Util.extend(callbacks, this.callbacks);
        this.handlers = {
            marker: new com.navis.OpenLayers.Handler.Marker(this, this.layers, this.callbacks)
        };
    },

    /**
     * Method: destroy
     */
    destroy: function() {
        OpenLayers.Control.prototype.destroy.apply(this, arguments);
    },

    /**
     * Method: clickMarker
     * Called on click in a marker
     *
     * Parameters:
     * marker - {<OpenLayers.Marker>}
     * layer - {<OpenLayers.Layer.Markers>}
     */
    clickMarker: function(marker, layer) {
        var selected = (OpenLayers.Util.indexOf(layer.selectedMarkers, marker) > -1);
        if(selected) {
            this.unselectAll({except: marker});
        } else {
            this.unselectAll({except: marker});
            this.select(marker, layer);
        }
    },

    /**
     * Method: clickoutMarker
     * Called on click outside a previously clicked (selected) marker.
     * Only responds if this.hover is false.
     *
     * Parameters:
     * marker - {<OpenLayers.Marker>}
     * layer - {<OpenLayers.Layer.Markers>}
     */
    clickoutMarker: function(marker, layer) {
        if(this.clickout) {
            this.unselectAll();
        }
    },

    /**
     * Method: activate
     * Activates the control.
     *
     * Returns:
     * {Boolean} The control was effectively activated.
     */
    activate: function () {
        if (!this.active) {
            this.handlers.marker.activate();
        }
        return OpenLayers.Control.prototype.activate.apply(this, arguments);
    },

    /**
     * Method: deactivate
     * Deactivates the control.
     *
     * Returns:
     * {Boolean} The control was effectively deactivated.
     */
    deactivate: function () {
        if (this.active) {
            this.handlers.marker.deactivate();
        }
        return OpenLayers.Control.prototype.deactivate.apply(this, arguments);
    },

    /**
     * Method: highlight
     * Redraw marker with the select style.
     *
     * Parameters:
     * marker - {<OpenLayers.Marker>}
     */
    highlight: function(marker) {
        var layer = marker.layer;
        var cont = this.events.triggerEvent("beforemarkerhighlighted", {
            marker : marker
        });
        if(cont !== false) {
            marker._prevHighlighter = marker._lastHighlighter;
            marker._lastHighlighter = this.id;
            this.events.triggerEvent("markerhighlighted", {marker : marker});
        }
    },

    /**
     * Method: unhighlight
     * Redraw marker with the "default" style
     *
     * Parameters:
     * marker - {<OpenLayers.Marker>}
     */
    unhighlight: function(marker) {
        var layer = marker.layer;
        marker._lastHighlighter = marker._prevHighlighter;
        delete marker._prevHighlighter;
        this.events.triggerEvent("markerunhighlighted", {marker : marker});
    },

    /**
     * Method: select
     * Add marker to the layer's selectedMarker array, render the marker as
     * selected, and call the onSelect function.
     *
     * Parameters:
     * marker - {<OpenLayers.Marker>}
     * layer - {<OpenLayers.Layer.Markers>}
     */
    select: function(marker, layer) {
        this.highlight(marker);
        if (layer) {
            layer.selectedMarkers.push(marker);
            // if the marker handler isn't involved in the marker
            // selection (because the box handler is used or the
            // marker is selected programatically) we fake the
            // marker handler to allow unselecting on click
            if(!this.handlers.marker.lastMarker) {
                this.handlers.marker.lastMarker = layer.selectedMarkers[0];
            }
            layer.events.triggerEvent("markerselected", {marker: marker});
        }
    },

    /**
     * Method: unselect
     * Remove marker from the layer's selectedMarkers array, render the marker as
     * normal, and call the onUnselect function.
     *
     * Parameters:
     * marker - {<OpenLayers.Marker>}
     * layer - {<OpenLayers.Layer.Markers>}
     */
    unselect: function(marker, layer) {
        this.unhighlight(marker);
        if (layer) {
            OpenLayers.Util.removeItem(layer.selectedMarkers, marker);
            layer.events.triggerEvent("markerunselected", {marker: marker});
        }
    },

    /**
     * Method: unselectAll
     * Unselect all selected markers.  To unselect all except for a single
     *     marker, set the options.except property to the marker.
     *
     * Parameters:
     * options - {Object} Optional configuration object.
     */
    unselectAll: function(options) {
        // we'll want an option to supress notification here
        var layers = this.layers;
        var layer, marker;
        for(var l=0; l<layers.length; ++l) {
            layer = layers[l];
            for(var i=layer.selectedMarkers.length-1; i>=0; --i) {
                marker = layer.selectedMarkers[i];
                if(!options || options.except !== marker) {
                    this.unselect(marker);
                }
            }
        }
    },

    /**
    * Method: setMap
    * Set the map property for the control.
    *
    * Parameters:
    * map - {<OpenLayers.Map>}
    */
   setMap: function(map) {
       this.handlers.marker.setMap(map);
       OpenLayers.Control.prototype.setMap.apply(this, arguments);
   },

   CLASS_NAME: "com.navis.OpenLayers.Control.SelectMarker"
});

zk.$package('com.navis.OpenLayers.Handler');
com.navis.OpenLayers.Handler.Marker = OpenLayers.Class(OpenLayers.Handler,  {
    /**
     * Property: EVENTMAP
     * {Object} A object mapping the browser events to objects with callback
     *     keys for in and out.
     */
    EVENTMAP: {
        'click': {'in': 'click', 'out': 'clickout'},
        'mousemove': {'in': 'over', 'out': 'out'},
        'dblclick': {'in': 'dblclick', 'out': null},
        'mousedown': {'in': null, 'out': null},
        'mouseup': {'in': null, 'out': null}
    },

    /**
     * Property: layers
     * {<OpenLayers.Layer.Markers}
     */
    layers: null,

    /**
     * Property: marker
     * {<OpenLayers.Marker>} The last marker that was hovered.
     */
    marker: null,

    /**
     * Property: lastMarker
     * {<OpenLayers.Marker>} The last marker that was handled.
     */
    lastMarker: null,

    /**
     * Property: lastLayer
     * {<OpenLayers.Marker>} The last layer that was handled.
     */
    lastLayer: null,

    /**
     * Property: down
     * {<OpenLayers.Pixel>} The location of the last mousedown.
     */
    down: null,

    /**
     * Property: up
     * {<OpenLayers.Pixel>} The location of the last mouseup.
     */
    up: null,

    /**
     * Property: clickTolerance
     * {Number} The number of pixels the mouse can move between mousedown
     *     and mouseup for the event to still be considered a click.
     *     Dragging the map should not trigger the click and clickout callbacks
     *     unless the map is moved by less than this tolerance. Defaults to 4.
     */
    clickTolerance: 4,

    /**
     * Property: stopClick
     * {Boolean} If stopClick is set to true, handled clicks do not
     *      propagate to other click listeners. Otherwise, handled clicks
     *      do propagate. Unhandled clicks always propagate, whatever the
     *      value of stopClick. Defaults to true.
     */
    stopClick: true,

    /**
     * Property: stopDown
     * {Boolean} If stopDown is set to true, handled mousedowns do not
     *      propagate to other mousedown listeners. Otherwise, handled
     *      mousedowns do propagate. Unhandled mousedowns always propagate,
     *      whatever the value of stopDown. Defaults to true.
     */
    stopDown: true,

    /**
     * Property: stopUp
     * {Boolean} If stopUp is set to true, handled mouseups do not
     *      propagate to other mouseup listeners. Otherwise, handled mouseups
     *      do propagate. Unhandled mouseups always propagate, whatever the
     *      value of stopUp. Defaults to false.
     */
    stopUp: false,

    /**
     * Constructor: com.navis.OpenLayers.Handler.Marker
     * Create a new handler.
     *
     * Parameters:
     * control - {<OpenLayers.Control>} The control that is making use of
     *     this handler.  If a handler is being used without a control, the
     *     handler's setMap method must be overridden to deal properly with
     *     the map.
     * callbacks - {Object} An object with keys corresponding to callbacks
     *     that will be called by the handler. The callbacks should
     *     expect to recieve a single argument, the click event.
     *     Callbacks for 'click' and 'dblclick' are supported.
     * options - {Object} Optional object whose properties will be set on the
     *     handler.
     */
    initialize: function(control, layers, callbacks, options) {
        OpenLayers.Handler.prototype.initialize.apply(this, [control, callbacks, options]);
        this.layers = layers;
    },

    /**
     * Method: mousedown
     * Handle mouse down.  Stop propagation if a marker is targeted by this
     *     event (stops map dragging during marker selection).
     *
     * Parameters:
     * evt - {Event}
     */
    mousedown: function(evt) {
        this.down = evt.xy;
        return this.handle(evt) ? !this.stopDown : true;
    },

    /**
     * Method: mouseup
     * Handle mouse up.  Stop propagation if a marker is targeted by this
     *     event.
     *
     * Parameters:
     * evt - {Event}
     */
    mouseup: function(evt) {
        this.up = evt.xy;
        return this.handle(evt) ? !this.stopUp : true;
    },

    /**
     * Method: click
     * Handle click.  Call the "click" callback if click on a marker,
     *     or the "clickout" callback if click outside any marker.
     *
     * Parameters:
     * evt - {Event}
     *
     * Returns:
     * {Boolean}
     */
    click: function(evt) {
        return this.handle(evt) ? !this.stopClick : true;
    },

    /**
     * Method: mousemove
     * Handle mouse moves.  Call the "over" callback if moving in to a marker,
     *     or the "out" callback if moving out of a marker.
     *
     * Parameters:
     * evt - {Event}
     *
     * Returns:
     * {Boolean}
     */
    mousemove: function(evt) {
        if (!this.callbacks['over'] && !this.callbacks['out']) {
            return true;
        }
        this.handle(evt);
        return true;
    },

    /**
     * Method: dblclick
     * Handle dblclick.  Call the "dblclick" callback if dblclick on a marker.
     *
     * Parameters:
     * evt - {Event}
     *
     * Returns:
     * {Boolean}
     */
    dblclick: function(evt) {
        return !this.handle(evt);
    },

    /**
     * Method: handle
     *
     * Parameters:
     * evt - {Event}
     *
     * Returns:
     * {Boolean} The event occurred over a relevant marker.
     */
    handle: function(evt) {
        if(this.marker && !this.marker.events) {
            // marker has been destroyed
            this.marker = null;
        }
        var type = evt.type;
        var handled = false;
        var previouslyIn = !!(this.marker); // previously in a marker
        var click = (type === "click" || type === "dblclick");
        var markerAndLayer = this.getMarkerFromEvent(evt);
        this.marker = markerAndLayer.marker;
        var layer = markerAndLayer.layer;

        if(this.marker && !this.marker.events) {
            // marker has been destroyed
            this.marker = null;
        }
        if(this.lastMarker && !this.lastMarker.events) {
            // last marker has been destroyed
            this.lastMarker = null;
            this.lastLayer = null;
        }
        if(this.marker) {
            var inNew = (this.marker !== this.lastMarker);
            // in to a marker
            if(previouslyIn && inNew) {
                // out of last marker and in to another
                if (this.lastMarker) {
                    this.triggerCallback(type, 'out', [this.lastMarker, this.lastLayer]);
                }
                this.triggerCallback(type, 'in', [this.marker, layer]);
            } else if(!previouslyIn || click) {
                // in marker for the first time
                this.triggerCallback(type, 'in', [this.marker, layer]);
            }
            this.lastMarker = this.marker;
            this.lastLayer = layer;
            handled = true;
        } else {
            if(this.lastMarker && (previouslyIn || click)) {
                this.triggerCallback(type, 'out', [this.lastMarker, this.lastLayer]);
            }
        }
        return handled;
    },

    getMarkerFromEvent: function(evt) {
        var result = {marker: null, layer: null};
        for (var i = 0; i < this.layers.length; i++) {
            var layer = this.layers[i];
            if (!layer.visibility) {
                continue;
            }
            var marker = layer.getMarkerFromEvent(evt);
            if (marker !== null) {
                result.marker = marker;
                result.layer = layer;
                break;
            }
        }
        return result;
    },

    /**
     * Method: triggerCallback
     * Call the callback keyed in the event map with the supplied arguments.
     *     For click and clickout, the <clickTolerance> is checked first.
     *
     * Parameters:
     * type - {String}
     */
    triggerCallback: function(type, mode, args) {
        var key = this.EVENTMAP[type][mode];
        if(key) {
            if(type === 'click' && this.up && this.down) {
                // for click/clickout, only trigger callback if tolerance is met
                var dpx = Math.sqrt(
                    Math.pow(this.up.x - this.down.x, 2) +
                    Math.pow(this.up.y - this.down.y, 2)
                );
                if(dpx <= this.clickTolerance) {
                    this.callback(key, args);
                }
            } else {
                this.callback(key, args);
            }
        }
    },

    /**
     * Method: activate
     * Turn on the handler.  Returns false if the handler was already active.
     *
     * Returns:
     * {Boolean}
     */
    activate: function() {
        var activated = false;
        if(OpenLayers.Handler.prototype.activate.apply(this, arguments)) {
            activated = true;
        }
        return activated;
    },

    /**
     * Method: deactivate
     * Turn off the handler.  Returns false if the handler was already active.
     *
     * Returns:
     * {Boolean}
     */
    deactivate: function() {
        var deactivated = false;
        if(OpenLayers.Handler.prototype.deactivate.apply(this, arguments)) {
            this.marker = null;
            this.lastMarker = null;
            this.lastLayer = null;
            this.down = null;
            this.up = null;
            deactivated = true;
        }
        return deactivated;
    },

    CLASS_NAME: "com.navis.OpenLayers.Handler.Marker"
});

zk.$package('com.navis.OpenLayers.Layer');
com.navis.OpenLayers.Layer.Markers = OpenLayers.Class(OpenLayers.Layer.Markers, {

    /**
     * Property: strategies
     * {Array(<OpenLayers.Strategy>)} Optional list of strategies for the layer.
     */
    strategies: null,

    /**
     * Property: selectedMarkers
     * {Array{<OpenLayers.Strategy>)}
     */
    selectedMarkers: null,

    /**
     * Constant: EVENT_TYPES
     *
     * Supported event types:
     * markerAdded - Triggered when a marker is added
     */
    EVENT_TYPES: ["beforemarkersadded","markersadded", "beforemarkersremoved", "markersremoved",
                  "beforemarkeradded", "markeradded", "beforemarkerremoved", "markerremoved",
                  "markerselected", "markerunselected"],

    /**
     * Constructor: OpenLayers.Layer.Markers
     * Create a Markers layer.
     *
     * Parameters:
     * name - {String}
     * options - {Object} Hashtable of extra options to tag onto the layer
     */
    initialize: function(name, options) {
        // concatenate events specific to the layer with those from the base
        this.EVENT_TYPES = com.navis.OpenLayers.Layer.Markers.prototype.EVENT_TYPES.concat(
            OpenLayers.Layer.prototype.EVENT_TYPES
        );

        OpenLayers.Layer.Markers.prototype.initialize.apply(this, arguments);

        // Allow for custom layer behavior
        if(this.strategies){
            for(var i=0, len=this.strategies.length; i<len; i++) {
                this.strategies[i].setLayer(this);
            }
        }

        this.selectedMarkers = [];
    },

    /**
     * APIMethod: destroy
     * Destroy this layer
     */
    destroy: function() {
        if (this.strategies) {
            var strategy, i, len;
            for(i=0, len=this.strategies.length; i<len; i++) {
                strategy = this.strategies[i];
                if(strategy.autoDestroy) {
                    strategy.destroy();
                }
            }
            this.strategies = null;
        }

        this.selectedMarkers = null;

        OpenLayers.Layer.Markers.prototype.destroy.apply(this, arguments);
    },

    /**
     * Method: afterAdd
     * Called at the end of the map.addLayer sequence.  At this point, the map
     *     will have a base layer.  Any autoActivate strategies will be
     *     activated here.
     */
    afterAdd: function() {
        OpenLayers.Layer.Markers.prototype.afterAdd.apply(this, arguments);

        if(this.strategies) {
            var strategy, i, len;
            for(i=0, len=this.strategies.length; i<len; i++) {
                strategy = this.strategies[i];
                if(strategy.autoActivate) {
                    strategy.activate();
                }
            }
        }
    },

    /**
     * Method: removeMap
     * The layer has been removed from the map.
     *
     * Parameters:
     * map - {<OpenLayers.Map>}
     */
    removeMap: function(map) {
        OpenLayers.Layer.Markers.prototype.removeMap.apply(this, arguments);

        if(this.strategies) {
            var strategy, i, len;
            for(i=0, len=this.strategies.length; i<len; i++) {
                strategy = this.strategies[i];
                if(strategy.autoActivate) {
                    strategy.deactivate();
                }
            }
        }
    },

    /**
     * APIMethod: addMarkers
     *
     * Parameters:
     * inMarker - {Array(<OpenLayers.Marker>)}
     * inOptions - {Object}
     */
    addMarkers: function(inMarkers, inOptions) {
        if (!(inMarkers instanceof Array)) {
            inMarkers = [inMarkers];
        }

        var notify = !inOptions || !inOptions.silent;

        if (notify) {
            var event = {markers: inMarkers};
            if (this.events.triggerEvent("beforemarkersadded", event) === false) {
                return;
            }
            inMarkers = event.markers;
        }

        var markersAdded = [];
        for (var i=0, len=inMarkers.length; i<len; i++) {
            var marker = inMarkers[i];

            if (notify) {
                if(this.events.triggerEvent("beforemarkeradded",
                                            {marker: marker}) === false) {
                    continue;
                }
            }

            OpenLayers.Layer.Markers.prototype.addMarker.apply(this, [marker]);

            markersAdded.push(marker);

            if (notify) {
                this.events.triggerEvent("markeradded", {
                    marker: marker
                });
            }
        }

        if (notify) {
            this.events.triggerEvent("markersadded", {markers: markersAdded});
        }
    },

    /**
     * APIMethod: removeMarkers
     *
     * Parameters:
     * inMarker - {Array(<OpenLayers.Marker>)}
     * inOptions - {Object}
     */
    removeMarkers: function(inMarkers, inOptions) {
        if(!inMarkers || inMarkers.length === 0) {
            return;
        }

        if (inMarkers === this.markers) {
            return this.clearMarkers();
        }

        if (!(inMarkers instanceof Array)) {
            inMarkers = [inMarkers];
        }

        if (inMarkers === this.selectedMarkers) {
            inMarkers = inMarkers.slice();
        }

        var notify = !inOptions || !inOptions.silent;

        if (notify) {
            this.events.triggerEvent("beforemarkersremoved", {markers: inMarkers});
        }

        for (var i=0, len=inMarkers.length; i<len; i++) {
            var marker = inMarkers[i];

            if (notify) {
                this.events.triggerEvent("beforemarkerremoved", {marker: marker});
            }

            OpenLayers.Layer.Markers.prototype.removeMarker.apply(this, [marker]);

            if (OpenLayers.Util.indexOf(this.selectedMarkers, marker) !== -1) {
                OpenLayers.Util.removeItem(this.selectedMarkers, marker);
            }

            if (notify) {
                this.events.triggerEvent("markerremoved", {marker: marker});
            }
        }

        if (notify) {
            this.events.triggerEvent("markersremoved", {markers: inMarkers});
        }
    },

    /**
     * APIMethod: destroyMarkers
     *
     * Parameters:
     * inMarker - {Array(<OpenLayers.Marker>)}
     * inOptions - {Object}
     */
    destroyMarkers: function(inMarkers, inOptions) {
        var all = (inMarkers === undefined);
        if (all) {
            inMarkers = this.markers;
        }
        if (inMarkers) {
            for (var i = inMarkers.length - 1; i >= 0; i--) {
                var marker = inMarkers[i];
                this.removeMarker(marker);
                marker.destroy();
                inMarkers[i] = null;
            }
        }
        if (all) {
            this.markers = [];
        }
    },

    /**
     * Method: clearMarkers
     * This method removes all markers from a layer. The markers are not destroyed
     * by this function, but are removed from the list of markers.
     */
    clearMarkers: function() {
        OpenLayers.Layer.Markers.prototype.clearMarkers.apply(this, arguments);
        this.selectedMarkers = [];
    },

    /**
    * Method: drawMarker
    * Calculate the pixel location for the marker, create it, and
    *    add it to the layer's div
    *
    * Parameters:
    * marker - {<OpenLayers.Marker>}
    */
    drawMarker: function(marker) {
        var px = this.map.getLayerPxFromLonLat(marker.lonlat);
        if (px === null) {
            marker.display(false);
        } else {
            if (!marker.isDrawn()) {
                var markerImg = marker.draw(px);
                this.div.appendChild(markerImg);
            } else if (marker.icon) {
                // We want to move the marker, but we don't want to reset the lonlat
                // The reverse calculation of the lonlat that's done by moveTo() causes accuracy loss.
                var savedLonLat = marker.lonlat;
                marker.moveTo(px);
                marker.lonlat = savedLonLat;
            }
        }
    },
    getMarkerFromEvent: function(evt) {
        var node = (evt.target || evt.srcElement);
        var imageId = node.id;

        return this.getMarkerFromImageId(imageId);
    },

    getMarkerFromImageId: function(imageId) {
        for (var i = 0; i < this.markers.length; i++) {
            var marker = this.markers[i];
            if (marker.icon && marker.icon.imageDiv && marker.icon.imageDiv.firstChild) {
                var thisImageId = marker.icon.imageDiv.firstChild.id;
                if (thisImageId === imageId) {
                    return marker;
                }
            }
        }
        return null;
    },

    CLASS_NAME: "com.navis.OpenLayers.Layer.Markers"
});

zk.$package("com.navis.OpenLayers.Marker");
com.navis.OpenLayers.Marker.LabelMarker = OpenLayers.Class(OpenLayers.Marker, {

    /**
     * Property: label
     * {String} Marker label.
     */
    labelNode: null,

    markerDiv: null,

    /**
     * Constructor: OpenLayers.Marker
     * Parameters:
     * lonlat - {<OpenLayers.LonLat>} the position of this marker
     * icon - {<OpenLayers.Icon>}  the icon for this marker
     * label - label for the marker
     */
    initialize: function(lonlat, icon, label, displayClass) {
        OpenLayers.Marker.prototype.initialize.apply(this, [lonlat, icon]);

        this.markerDiv = OpenLayers.Util.createDiv();
        this.markerDiv.appendChild(this.icon.imageDiv);
        var txtDiv = OpenLayers.Util.createDiv();
        txtDiv.className = displayClass;
        OpenLayers.Util.modifyDOMElement(txtDiv, null, new OpenLayers.Pixel(0, this.icon.size.h));
        this.labelNode = document.createTextNode(label);
        txtDiv.appendChild(this.labelNode);
        this.markerDiv.appendChild(txtDiv);
    },

    /**
     * APIMethod: destroy
     * Destroy the marker. You must first remove the marker from any
     * layer which it has been added to, or you will get buggy behavior.
     * (This can not be done within the marker since the marker does not
     * know which layer it is attached to.)
     */
    destroy: function() {
        OpenLayers.Marker.prototype.destroy.apply(this, arguments);
        if (this.cluster) {
            for (var i=0;i<this.cluster.length; i++) {
                this.cluster[i].destroy();
            }
            this.cluster = null;
        }
        if (this.markerDiv) {
            this.markerDiv.innerHTML = null;
            this.markerDiv = null;
        }
        this.labelNode = null;
        this.lonlat = null;
   },

    /**
    * Method: draw
    * Calls draw on the icon, and returns that output.
    *
    * Parameters:
    * px - {<OpenLayers.Pixel>}
    *
    * Returns:
    * {DOMElement} A new DOM Image with this marker's icon set at the
    * location passed-in
    */
    draw: function(px) {
        var drawLocation = px;

        OpenLayers.Util.modifyAlphaImageDiv(this.icon.imageDiv,
                                            null,
                                            null,
                                            this.icon.size,
                                            this.icon.url);

        if (this.icon) {
            if (this.icon.calculateOffset) {
                this.icon.offset = this.icon.calculateOffset(this.icon.size);
            }
            drawLocation = drawLocation.offset(this.icon.offset);
        }
        OpenLayers.Util.modifyDOMElement(this.markerDiv, null, drawLocation);
        return this.markerDiv;
    },

    /**
    * Method: redraw
    * Redraw the marker in the new location.
    *
    * Parameters:
    * px - {<OpenLayers.Pixel>} the pixel position to move to
    */
    redraw: function(px) {
        if ((px !== null) && (this.markerDiv !== null)) {
            var drawLocation = px;
            if (this.icon) {
                if (this.icon.calculateOffset) {
                    this.icon.offset = this.icon.calculateOffset(this.icon.size);
                }
                drawLocation = drawLocation.offset(this.icon.offset);
            }
            OpenLayers.Util.modifyDOMElement(this.markerDiv, null, drawLocation);
        }
    },

    /**
    * Method: erase
    * Erases any drawn elements for this marker.
    */
    erase: function() {
        OpenLayers.Marker.prototype.erase.apply(this, arguments);
        if (this.markerDiv !== null && this.markerDiv.parentNode !== null) {
            OpenLayers.Element.remove(this.markerDiv);
        }
    },

    /**
    * Method: moveTo
    * Move the marker to the new location.
    *
    * Parameters:
    * px - {<OpenLayers.Pixel>} the pixel position to move to
    */
    moveTo: function (px) {
        this.redraw(px);
        this.lonlat = this.map.getLonLatFromLayerPx(px);
    },

    /**
     * APIMethod: isDrawn
     *
     * Returns:
     * {Boolean} Whether or not the marker is drawn.
     */
    isDrawn: function() {
        // nodeType 11 for ie, whose nodes *always* have a parentNode
        // (of type document fragment)
        return (this.markerDiv && this.markerDiv.parentNode &&
                       (this.markerDiv.parentNode.nodeType !== 11));
    },

    CLASS_NAME: "com.navis.OpenLayers.Marker.LabelMarker"
});


zk.$package('com.navis.OpenLayers.Strategy');
com.navis.OpenLayers.Strategy.MarkerCluster = OpenLayers.Class(OpenLayers.Strategy, {

    /**
     * APIProperty: distance
     * {Integer} Pixel distance between markers that should be considered a
     *     single cluster.  Default is 20 pixels.
     */
    distance: 20,

    /**
     * APIProperty: threshold
     * {Integer} Optional threshold below which original markers will be
     *     added to the layer instead of clusters.  For example, a threshold
     *     of 3 would mean that any time there are 2 or fewer markers in
     *     a cluster, those markers will be added directly to the layer instead
     *     of a cluster representing those markers.  Default is null (which is
     *     equivalent to 1 - meaning that clusters may contain just one marker).
     */
    threshold: null,

    /**
     * Property: markers
     * {Array(<OpenLayers.Marker>)} Cached markers.
     */
    markers: null,

    /**
     * Property: clusters
     * {Array(<OpenLayers.Marker>)} Calculated clusters.
     */
    clusters: null,

    /**
     * Property: clustering
     * {Boolean} The strategy is currently clustering markers.
     */
    clustering: false,

    /**
     * Property: resolution
     * {Float} The resolution (map units per pixel) of the current cluster set.
     */
    resolution: null,

    /**
     * Property: cluster icon template
     */
    clusterIcon: null,

    /**
     * Property: cluster icon width
     */
    clusterIconWidth: null,

    /**
     * Property: cluster icon height
     */
    clusterIconHeight: null,

    /**
     * Constructor: OpenLayers.Strategy.Cluster
     * Create a new clustering strategy.
     *
     * Parameters:
     * options - {Object} Optional object whose properties will be set on the
     *     instance.
     */
    initialize: function(options) {
        OpenLayers.Strategy.prototype.initialize.apply(this, [options]);
    },

    destroy: function() {
        OpenLayers.Strategy.prototype.destroy.apply(this, arguments);
        if (this.clusters) {
            for (var i=0;i<this.clusters.length;i++) {
                this.clusters[i] = null;    // de-reference
            }
            this.clusters = null;
        }
        this.clearCache();
        if (this.clusterIcon) {
            this.clusterIcon.destroy();
            this.clusterIcon = null;
        }
        this.clusterIconHeight = null;
        this.clusterIconWidth = null;
        this.clusterIconLabel = null;
    },

    /**
     * APIMethod: activate
     * Activate the strategy.  Register any listeners, do appropriate setup.
     *
     * Returns:
     * {Boolean} The strategy was successfully activated.
     */
    activate: function() {
        var activated = OpenLayers.Strategy.prototype.activate.call(this);
        if(activated) {
            this.layer.events.on({
                "beforemarkersadded": this.cacheMarkers,
                "moveend": this.cluster,
                scope: this
            });
        }
        return activated;
    },

    /**
     * APIMethod: deactivate
     * Deactivate the strategy.  Unregister any listeners, do appropriate
     *     tear-down.
     *
     * Returns:
     * {Boolean} The strategy was successfully deactivated.
     */
    deactivate: function() {
        var deactivated = OpenLayers.Strategy.prototype.deactivate.call(this);
        if(deactivated) {
            this.clearCache();
            this.layer.events.un({
                "beforemarkersadded": this.cacheMarkers,
                "moveend": this.cluster,
                scope: this
            });
        }
        return deactivated;
    },

    /**
     * Method: cacheMarkers
     * Cache markers before they are added to the layer.
     *
     * Parameters:
     * event - {Object} The event that this was listening for.  This will come
     *     with a batch of markers to be clustered.
     *
     * Returns:
     * {Boolean} False to stop markers from being added to the layer.
     */
    cacheMarkers: function(event) {
        var propagate = true;
        if(!this.clustering) {
            this.clearCache();
            this.markers = event.markers;
            this.cluster();
            propagate = false;
        }
        return propagate;
    },

    /**
     * Method: clearCache
     * Clear out the cached markers.
     */
    clearCache: function() {
        this.markers = null;
    },

    /**
     * Method: cluster
     * Cluster markers based on some threshold distance.
     *
     * Parameters:
     * event - {Object} The event received when cluster is called as a
     *     result of a moveend event.
     */
    cluster: function(event) {
        if((!event || event.zoomChanged) && this.markers) {
            var resolution = this.layer.map.getResolution();
            if(resolution !== this.resolution || !this.clustersExist()) {
                this.resolution = resolution;
                var clusters = [];
                var marker, clustered, cluster;

                for(var i=0; i<this.markers.length; ++i) {
                    marker = this.markers[i];
                    clustered = false;
                    for(var j=0; j<clusters.length; ++j) {
                        cluster = clusters[j];
                        if(this.shouldCluster(cluster, marker)) {
                            this.addToCluster(cluster, marker);
                            clustered = true;
                            break;
                        }
                    }
                    if(!clustered) {
                        clusters.push(this.createCluster(this.markers[i]));
                    }
                }

                this.layer.clearMarkers();

                if(clusters.length > 0) {
                    if(this.threshold > 1) {
                        var clone = clusters.slice();
                        clusters = [];
                        var candidate;
                        for(var k=0, len=clone.length; k<len; ++k) {
                            candidate = clone[k];
                            if(candidate.attributes.count < this.threshold) {
                                clusters = clusters.concat(candidate.cluster);
                            } else {
                                clusters.push(candidate);
                            }
                        }
                    }
                    this.clustering = true;
                    this.layer.addMarkers(clusters);
                    this.clustering = false;
                }
                this.clusters = clusters;
            }
        }
    },

    /**
     * Method: clustersExist
     * Determine whether calculated clusters are already on the layer.
     *
     * Returns:
     * {Boolean} The calculated clusters are already on the layer.
     */
    clustersExist: function() {
        var exist = false;
        if(this.clusters && this.clusters.length > 0 &&
           this.clusters.length === this.layer.markers.length) {
            exist = true;
            for(var i=0; i<this.clusters.length; ++i) {
                if(this.clusters[i] !== this.layer.markers[i]) {
                    exist = false;
                    break;
                }
            }
        }
        return exist;
    },

    /**
     * Method: shouldCluster
     * Determine whether to include a marker in a given cluster.
     *
     * Parameters:
     * cluster - {<OpenLayers.Marker>} A cluster.
     * marker - {<OpenLayers.Marker>} A marker.
     *
     * Returns:
     * {Boolean} The marker should be included in the cluster.
     */
    shouldCluster: function(cluster, marker) {
        var cc = cluster.lonlat;
        var fc = marker.lonlat;
        var distance = (
            Math.sqrt(
                Math.pow((cc.lon - fc.lon), 2) + Math.pow((cc.lat - fc.lat), 2)
            ) / this.resolution
        );
        return (distance <= this.distance);
    },

    /**
     * Method: addToCluster
     * Add a marker to a cluster.
     *
     * Parameters:
     * cluster - {<OpenLayers.Marker>} A cluster.
     * marker - {<OpenLayers.Marker>} A marker.
     */
    addToCluster: function(cluster, marker) {
        cluster.cluster.push(marker);
        cluster.attributes.count += 1;

        cluster.labelNode.nodeValue = this.clusterIconLabel(cluster) || "";

        var height = this.clusterIconHeight(cluster);
        var width =  this.clusterIconWidth(cluster);

        if (isNaN(height) || !height) {
            return;
        }
        if (isNaN(width) || !width) {
            return;
        }

        cluster.icon.size = new OpenLayers.Size(width, height);
    },

    /**
     * Method: createCluster
     * Given a marker, create a cluster.
     *
     * Parameters:
     * marker - {<OpenLayers.Marker>}
     *
     * Returns:
     * {<OpenLayers.Marker>} A cluster.
     */
    createCluster: function(marker) {
        var center = marker.lonlat;

        var cluster = new com.navis.OpenLayers.Marker.LabelMarker(
            center,
            this.clusterIcon.clone(),
            ""
        );
        cluster.attributes = {};
        cluster.attributes.count = 1;
        cluster.cluster = [marker];
        return cluster;
    },

    CLASS_NAME: "com.navis.OpenLayers.Strategy.MarkerCluster"
});

zk.$package('com.navis.OpenLayers.Renderer');
com.navis.OpenLayers.Renderer.Canvas = OpenLayers.Class(OpenLayers.Renderer.Canvas, {
    // keep a reference because we reassign the OpenLayers.Renderer.Canvas object reference to this class later
    superclass: OpenLayers.Renderer.Canvas,

    /**
     * Method: getFeatureIdFromEvent
     * Returns a feature id from an event on the renderer.
     *
     * Parameters:
     * evt - {<OpenLayers.Event>}
     *
     * Returns:
     * {String} A feature id or null.
     */
    getFeatureIdFromEvent: function(evt) {
        var loc = this.map.getLonLatFromPixel(evt.xy);
        var resolution = this.getResolution();
        var bounds = new OpenLayers.Bounds(loc.lon - resolution * 5,
                                           loc.lat - resolution * 5,
                                           loc.lon + resolution * 5,
                                           loc.lat + resolution * 5);
        var features = [];
        var geom = bounds.toGeometry();
        for (var feat in this.features) {
            if (!this.features.hasOwnProperty(feat)) { continue; }
            if (this.features[feat][0].geometry.intersects(geom)) {
                features.push({id: feat, selectionPrecedence: this.features[feat][0].attributes.selectionPrecedence});
            }
        }
        if (features.length === 1) {
             return features[0].id;
        }
        else if (features.length > 1) {
    /* precedence ranks to facilitate feature selection when more than one feature intersect; smallest vector gets the lowest precedence rank & wins
    selection; precedece is defined here and set before adding a vector to a layer. Default precedence is 99 and set in ZVector. */
            var eventFeature = null;
            var precedence = 100;
            for (var i = 0; i < features.length; i++) {
                var feature = features[i];
                if(feature && (!feature.selectionPrecedence || precedence > feature.selectionPrecedence)) {
                    eventFeature = feature; // use the last intersected feature
                    precedence = feature.selectionPrecedence;
                }
             }
            return eventFeature ? eventFeature.id : null;
        }
        else {
            return null;
        }
    },

    drawText: function(location, style) {
        var saveBaseline = this.canvas.textBaseline;
        this.canvas.textBaseline = style.labelBaseline;
        this.superclass.prototype.drawText.apply(this, arguments);
        this.canvas.textBaseline = saveBaseline;
    },

    /**
     * Method: drawPoint
     * This method is only called by the renderer itself.  Overriden to obey graphicName style attribute for Canvas renderer which is
     * supported by SVG by default.
     *
     * Parameters:
     * geometry - {<OpenLayers.Geometry>}
     * style    - {Object}
     */
    drawPoint: function(geometry, style) {
        if(style.graphicName !== undefined && style.graphicName === "arrow") {
            this.drawArrowSymbol(geometry, style);
        } else {
            this.superclass.prototype.drawPoint.apply(this, arguments);
        }
    },

    /**
     * Given point is considered as arrow head point and other points are derived based on it.
     *
     * @param geometry  Point
     * @param style     Style object; must have a value for 'rotation' attribute
     */
    drawArrowSymbol:function(geometry, style) {
        var angle = style.rotation;
        if(angle === undefined || angle === "NaN") {
            return;
        }
        var arrowWidth = style.arrowWidth ? style.arrowWidth : 20;
        var arrowLength = style.arrowLength ? style.arrowLength : 18;
        var renderPoint = this.getLocalXY(geometry);
        this.setCanvasStyle("stroke", style);
        var renderPointX = renderPoint[0];
        var renderPointY = renderPoint[1];

        this.canvas.beginPath();
        var arrowPoint = this.rotatePoint(renderPointX,renderPointY,renderPointX-(arrowWidth/2),renderPointY+arrowLength,angle);
        this.canvas.moveTo(arrowPoint.x, arrowPoint.y);

        this.canvas.lineTo(renderPointX, renderPointY);

        arrowPoint = this.rotatePoint(renderPointX,renderPointY,renderPointX+(arrowWidth/2),renderPointY+arrowLength,angle);
        this.canvas.lineTo(arrowPoint.x, arrowPoint.y);

        this.canvas.lineTo(renderPointX, renderPointY);

        arrowPoint = this.rotatePoint(renderPointX,renderPointY,renderPointX-(arrowWidth/2),renderPointY+arrowLength,angle);
        this.canvas.lineTo(arrowPoint.x, arrowPoint.y);

        this.canvas.stroke();
        this.setCanvasStyle("reset");
    },

    rotatePoint: function(referencePointX,referencePointY,toRotateX,toRotateY,angle) {
        angle *= Math.PI / 180;
        var radius = Math.sqrt(Math.pow(referencePointX - toRotateX, 2) + Math.pow(referencePointY - toRotateY, 2));
        var theta = angle + Math.atan2(toRotateY - referencePointY, toRotateX - referencePointX);
        toRotateX = referencePointX + (radius * Math.cos(theta));
        toRotateY = referencePointY + (radius * Math.sin(theta));
        return new OpenLayers.Geometry.Point(toRotateX,toRotateY);
    },

    CLASS_NAME: "com.navis.OpenLayers.Renderer.Canvas"
});
com.navis.OpenLayers.Renderer.Canvas.LABEL_ALIGN = OpenLayers.Renderer.Canvas.LABEL_ALIGN;
OpenLayers.Renderer.Canvas = com.navis.OpenLayers.Renderer.Canvas;

zk.$package('com.navis.OpenLayers.Control');
com.navis.OpenLayers.Control.Panel = OpenLayers.Class(OpenLayers.Control.Panel, {
    EVENT_TYPES: ["controlactivated","controldeactivated"],

    initialize: function(options) {
        // concatenate events specific to vector with those from the base
        this.EVENT_TYPES = com.navis.OpenLayers.Control.Panel.prototype.EVENT_TYPES.concat(
                OpenLayers.Control.Panel.prototype.EVENT_TYPES);

        OpenLayers.Control.Panel.prototype.initialize.apply(this, [options]);
     },

    /**
     * Method: addControlsToMap
     * Only for internal use in draw() and addControls() methods.
     *
     * Parameters:
     * controls - {Array(<OpenLayers.Control>)} Controls to add into map.
     */
    addControlsToMap: function (controls) {
        OpenLayers.Control.Panel.prototype.addControlsToMap.apply(this, arguments);

        var that = this;
        for (var i=0, len=controls.length; i<len; i++) {
            var control = controls[i];
            control.events.on({
                "activate": (function(control) {
                    return function() { that.events.triggerEvent("controlactivated", {control: control});};
                    })(control),
                "deactivate": (function(control) {
                    return function() { that.events.triggerEvent("controldeactivated", {control: control});};
                    })(control),
                "disabled": this.redraw,
                "enabled": this.redraw,
                scope: this
            });
        }
    },

    /**
     * APIMethod: activateControl
     * This method is called when the user click on the icon representing a
     *     control in the panel.
     *
     * Parameters:
     * control - {<OpenLayers.Control>}
     */
    activateControl: function (control) {
        if (!this.active) { return false; }
        if (control.type == OpenLayers.Control.TYPE_BUTTON) {
            control.trigger();
            this.redraw();
            return;
        }
        if (control.type == OpenLayers.Control.TYPE_TOGGLE) {
            if (control.active) {
                control.deactivate();
            } else {
                control.activate();
            }
            return;
        }
        var c;
        for (var i=0, len=this.controls.length; i<len; i++) {
            c = this.controls[i];
            if (c != control && !c.disabled && (c.type === OpenLayers.Control.TYPE_TOOL || c.type == null)) {
                c.deactivate();
            }
        }
        // If the user clicks on the same tool twice then toggle it. This is default behavior for N4.
        if(!control.disabled) {
            if (control.active) {
                control.deactivate();
            }
            else {
                control.activate();
            }
        }
    },

    getControls : function() {
        return this.controls;
    },

    /**
     * Method: redraw; overriden to render controls with new state 'disabled'
     */
    redraw: function() {
        for (var l=this.div.childNodes.length, i=l-1; i>=0; i--) {
            this.div.removeChild(this.div.childNodes[i]);
        }
        this.div.innerHTML = "";
        if (this.active) {
            for (var i=0, len=this.controls.length; i<len; i++) {
                var element = this.controls[i].panel_div;
                if(this.controls[i].disabled) {
                    element.className = this.controls[i].displayClass + "ItemDisabled";
                } else if (this.controls[i].active) {
                    element.className = this.controls[i].displayClass + "ItemActive";
                } else {
                    element.className = this.controls[i].displayClass + "ItemInactive";
                }
                this.div.appendChild(element);
            }
        }
    }
});

zk.$package('com.navis.OpenLayers');
com.navis.OpenLayers.PopupManager = OpenLayers.Class({

    /**
     * Property: ZMap
     * {<com.navis.framework.zk.view.client.ZMap>}
     */
    _zmap : null,

    /**
     * Property: _currentPopups
     * Each layer can have one and only one popup at a time;  key is the Layer Name, value is Popup (FramedCloud) object.
     * {<map<layerName, Popup>}
     */
    _currentPopups : {},

    initialize: function(inZmap) {
        this._zmap = inZmap;
    },

    // create HTML table in the FramedCloud popup
    _createPopupHtml: function(inLayerName, inContent, inOptionalClusterLonLat) {
        var html = "<div class=\"zebra_ol_popup\"><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" class=\"zebra_ol_popup\" >";
        if (inContent.cluster) {
            inContent.cluster.sort(function(a,b) { return a.id-b.id});
            // inContent is a marker representing a cluster of markers.
            // Create rows of hyperlinks to view individual markers.
            html += "<tr class=\"zebra_ol_popup\"><th class=\"zebra_ol_popup\">Member Id</th></tr>";
            for (var i = 0; i < inContent.cluster.length; i++) {
                var marker = inContent.cluster[i]; // marker is com.navis.OpenLayers.Marker.LabelMarker
                html += "<tr><td class=\"zebra_ol_popup\" ><a href=\"#\" onclick=\"zk.Widget.$('"
                        + this._zmap.uuid + "').getPopupManager().displaySelectedMarkerFromCluster('"
                        + inLayerName + "','" + marker.id + "','" + inContent.lonlat
                        + "'); event.returnValue=false; return false;\">"
                        + marker.id + "</a></td></tr>";
            }
        } else if (inContent.attributes) {
            // inContent has a attribute map of a non-cluster marker
            // Create rows of attribute names/values
            html += "<tr class=\"zebra_ol_popup\"><th class=\"zebra_ol_popup\">Name</th><th class=\"zebra_ol_popup\">Value</th></tr>";
            for (var attr in inContent.attributes) {
                html += "<tr><td class=\"zebra_ol_popup\">" + attr + "</td><td class=\"zebra_ol_popup\">" + inContent.attributes[attr] + "</td></tr>"
            }
        }
        html += "<tr><td class=\"zebra_ol_popup\">" + "Id" + "</td><td class=\"zebra_ol_popup\">" + inContent.id + "</td></tr>";
        html += "</table></div>";
        if (inOptionalClusterLonLat) {
            // Add the "Back" hyperlink if the current non-cluster marker view comes from a cluster view popup.
            html += "<a href=\"#\" onclick=\"zk.Widget.$('" + this._zmap.uuid + "').getPopupManager().displayClusterMarker('"
                    + inLayerName + "','" + inOptionalClusterLonLat + "'); event.returnValue=false; return false;\"><img src=\"images/openlayers/back_u.gif\"></a>";
        }
        return html;
    },

    /**
     * Display a popup in the given layer at the given lonlat position, with information about the marker (either cluster or non-cluster marker)
     * Example:
     * 1) Display attribute popup for a non-cluster marker, or a cluster-marker popup with hyperlinks to view individual member markers.
     *      com.navis.OpenLayers.Popup.FramedCloud.display(inLayerName, inLonLat, inMarker);
     * 2) Display attribute popup for the selected cluster-member marker
     *      com.navis.OpenLayers.Popup.FramedCloud.display(inLayerName, inLonLat, inMarker, inParentClusterLonLat);
     */
    display: function(inLayerName, inLonLat, inMarker, inOptionalClusterLonLat) {
        var popupHtml = this._createPopupHtml(inLayerName, inMarker, inOptionalClusterLonLat);
        // create a new cached popup object
        var currentPopups = this._currentPopups;
        this._currentPopups[inLayerName] =
                new OpenLayers.Popup.FramedCloud(inMarker.id, inLonLat, null, popupHtml, null, true, function (evt) {
                    // Here the context "this" is popup (FramedCloud) object.
                    this.hide();
                    // delete previous cached popup object
                    var oldPopup = currentPopups[inLayerName];
                    if (oldPopup) {
                        oldPopup.destroy();
                        delete currentPopups[inLayerName];
                    }
                    OpenLayers.Event.stop(evt);
                });
        this._zmap._olMap.addPopup(this._currentPopups[inLayerName]);
    },

    /**
     * Display a non-cluster marker popup given the string parameters: (layerName, marker id, parent cluster lonlat).  This function
     * is useful when handling hyperlink click where the string-only parameters are passed from the hyperlink handler.
     *
     * @param inLayerName - String, layer name the selected marker belongs to.
     * @param inMarkerId -  String, id of the selected marker.
     * @param inClusterLonLat - String, lonlat of the parent cluster popup. It's used to create the "Back" hyperlink.
     */
    displaySelectedMarkerFromCluster: function(inLayerName, inMarkerId, inClusterLonLat) {
        // Close any popup in the current layer.
        this.remove(inLayerName);
        // Retrieve the marker object give the marker Id
        var olLayers = this._zmap._olMap.getLayersByName(inLayerName);
        var found = false;
        if (olLayers && olLayers.length > 0) {
            var olLayer = olLayers[0];
            for(var i = 0; i < olLayer.markers.length; i++) {
                var marker = olLayer.markers[i];
                if (marker.cluster) {
                    for (var j=0; j<marker.cluster.length; j++) {
                        var member = marker.cluster[j];
                        if (member.id === inMarkerId) {
                            // Show the popup of the selected marker
                            this.display(inLayerName, member.lonlat, member, inClusterLonLat);
                            found = true;
                            break;
                        }
                    }
                    if (found) {
                        break;
                    }
                }
            }
        }
    },

    /**
     * Display a cluster marker popup given the string parameters: (layerName, clusterLonlat).  This function is useful when
     * handling the hyperlink click where the string-only parameters are passed from the hyperlink handler.
     *
     * @param inLayerName - String, layer name the selected marker belongs to.
     * @param inClusterLonLat - String, lonlat of the parent cluster popup. It's used to search and identify the parent cluster.
     */
    displayClusterMarker: function(inLayerName, inClusterLonLat) {
        // Close any popup in the current layer.
        this.remove(inLayerName);
        // Retrieve the cluster object given the lonlat
        var olLayers = this._zmap._olMap.getLayersByName(inLayerName);
        var found = false;
        if (olLayers && olLayers.length > 0) {
            var olLayer = olLayers[0];
            for(var i = 0; i < olLayer.markers.length; i++) {
                var marker = olLayer.markers[i];
                if (marker.cluster && marker.lonlat === inClusterLonLat) {
                    // Show the cluster popup
                    this.display(inLayerName, marker.lonlat, marker);
                    break;
                }
            }
        }
    },

    /**
     * Remove the popup from the given layer.
     * @param inLayerName
     */
    remove: function(inLayerName) {
        var oldPopup = this._currentPopups[inLayerName];
        if (oldPopup) {
            this._zmap._olMap.removePopup(oldPopup);
            oldPopup.destroy();
            delete this._currentPopups[inLayerName];
        }
    },

    /**
     * Return the marker ID of the current popup if exists, given the layer name.
     * @param inLayerName
     * @return markerId
     */
    getCurrentPopupMarkerId: function(inLayerName) {
        return this._currentPopups[inLayerName] && this._currentPopups[inLayerName].id;
    },

    CLASS_NAME: "com.navis.OpenLayers.PopupManager"
});

/*
    Singleton for serializing event data into a simple map
 */
zk.$package('com.navis.OpenLayers');
com.navis.OpenLayers.EventDataSerializer = (function() {
    var EXCLUDED = "excluded";

    function _getDataFromEvent(inEvent) {
        var data = {};
        data.type = inEvent.type;
        if (inEvent.xy) {
            data.xy = { x:inEvent.xy.x, y:inEvent.xy.y };
        }
        if (inEvent.pageX) {
            data.pageX = inEvent.pageX;
        }
        if (inEvent.pageY) {
            data.pageY = inEvent.pageY;
        }
        if (inEvent.lonlat) {
            data.lonlat = { lon:inEvent.lonlat.lon, lat:inEvent.lonlat.lat };
        }
        if (inEvent.object) {
            data.object = _getObjectData(inEvent.object)
        }
        if (inEvent.feature) {
            data.feature = _getFeatureData(inEvent.feature, inEvent.excludeGeometry);
        }
        if (inEvent.features) {
            data.features = _getFeaturesData(inEvent.features, inEvent.excludeGeometry);
        }
        if (inEvent.marker) {
            data.marker = _getMarkerData(inEvent.marker);
        }
        if (inEvent.markers) {
            data.markers = _getMarkerData(inEvent.markers);
        }
        if (inEvent.control) {
            data.control = _getObjectData(inEvent.control);
        }
        if (inEvent.bounds) {
            data.bounds = {left: inEvent.bounds.left, bottom: inEvent.bounds.bottom, right: inEvent.bounds.right, top: inEvent.bounds.top};
        }
        if (inEvent.resolution) {
            data.resolution = inEvent.resolution;
        }
        if (inEvent.zoom) {
            data.zoom = inEvent.zoom;
        }
        return data;
    }

    function _getObjectData(inObject) {
        var objectData = {};

        objectData.CLASS_NAME = inObject.CLASS_NAME;
        objectData.id = inObject.id;
        objectData.name = inObject.name || '';
        objectData.attributes = jq.extend({},inObject.attributes);
        if(inObject instanceof com.navis.OpenLayers.Layer.Vector ||
                inObject instanceof com.navis.GeometricNet.Network) {
            objectData.attributes["visibility"] = inObject.visibility;
        }

        return objectData;
    }

    function  _getComponentData(inComponents, inFilterProperty, inFilterValue) {
        var componentData = [];
        for (var i = 0; i < inComponents.length; i++) {
            var data = _getGeometryData(inComponents[i], inFilterProperty, inFilterValue);
            if (data) {
                componentData[i] = data;
            }
        }
        return componentData;
    }

    function _getGeometryData(inGeometry, inFilterProperty, inFilterValue) {
        var geometryData = _getObjectData(inGeometry);

        if (inFilterProperty && inFilterValue) {
            if (!inGeometry.attributes) {
                return null;
            }
            if (!inGeometry.attributes.hasOwnProperty(inFilterProperty)) {
                return null;
            }
            if (inGeometry.attributes[inFilterProperty] !== inFilterValue) {
                return null;
            }
        }
        // Only filter the first level components for MultiPolygon
        if (inGeometry instanceof OpenLayers.Geometry.MultiPolygon) {
            geometryData.components = _getComponentData(inGeometry.components, inFilterProperty, inFilterValue);
        }
        else if (inGeometry.components) {
            geometryData.components = _getComponentData(inGeometry.components);
        }
        if (inGeometry instanceof OpenLayers.Geometry.Point) {
            geometryData.x = inGeometry.x;
            geometryData.y = inGeometry.y;
        }
        return geometryData;
    }

    function _getLayerData(inLayer) {
        var layerData = _getObjectData(inLayer);
        layerData.visibility = inLayer.visibility;
        return layerData;
    }

    function _getFeatureData(inFeature, inExcludeGeometry) {
        var featureData = _getObjectData(inFeature);
        featureData.fid = inFeature.fid;
        if (inExcludeGeometry) {
            featureData.geometry = EXCLUDED;
        }
        // Only filter MultiPolygon
        else if (inFeature.geometry instanceof OpenLayers.Geometry.MultiPolygon) {
            featureData.geometry = _getGeometryData(inFeature.geometry, "gkey", inFeature.attributes.gkey);
        }
        else {
            featureData.geometry = _getGeometryData(inFeature.geometry);
        }
        if (featureData.layer) {
            featureData.layer = _getLayerData(inFeature.layer);
        }
        featureData.state = inFeature.state;

        _appendNetworkFeatureData(inFeature, featureData);
        return featureData;
    }

    function _appendNetworkFeatureData(inFeature, inFeatureData) {
        if (typeof window.GeometricNet === "undefined") {
            return;
        }
        if (inFeature.CLASS_NAME === "GeometricNet.Feature.Vector.Node") {
            inFeatureData.nodeType = inFeature.attributes.nodeType;
            inFeatureData.startEdges = jq.extend([], inFeature.attributes.startEdges);
            inFeatureData.endEdges = jq.extend([], inFeature.attributes.endEdges);
        }
        else if (inFeature.CLASS_NAME === "GeometricNet.Feature.Vector.Edge") {
            inFeatureData.edgeType = inFeature.attributes.edgeType;
            inFeatureData.startNode = inFeature.attributes.startNode;
            inFeatureData.endNode = inFeature.attributes.endNode;
            inFeatureData.isTwoWayPath = inFeature.attributes.isTwoWayPath;
            inFeatureData.otherPathGkey = inFeature.attributes.otherPathGkey;
            inFeatureData.sections = _getEdgeSectionsData(inFeature);
        }

    }

    function _getEdgeSectionsData(inFeature) {
        var sections = [];
        if(inFeature.sections && inFeature.sections.length > 0) {
            for(var index = 0; index < inFeature.sections.length; index++) {
                sections.push(_getGeometryData(inFeature.sections[index]));
            }
        }
        return sections;
    }

    function _getFeaturesData(inFeatures, inExcludeGeometry) {
        var features = [];
        for (var i = 0; i < inFeatures; i++) {
            var featureData = _getFeatureData(inFeatures[i], inExcludeGeometry);
            features.push(featureData);
        }
        return features;
    }

    function _getMarkerData(inMarker) {
        var markerData = _getObjectData(inMarker);
        markerData.longitude = inMarker.lonlat.lon;
        markerData.latitude = inMarker.lonlat.lat;
        return markerData;
    }

    function _getMarkersData(inMarkers) {
        var markers = [];
        for (var i = 0; i < inMarkers; i++) {
            var markerData = _getMarkerData(inMarkers[i]);
            markers.push(markerData);
        }
        return markers;
    }

    return {
        serialize: function(inEvent) {
            return _getDataFromEvent(inEvent);
        }
    };
})();

/*
    Singleton for utility methods.
 */
zk.$package('com.navis.OpenLayers');
com.navis.OpenLayers.Util = (function() {
    function _updateCss(inCssClass, inRuleName, inRuleValue) {
        var cssRules;

        var added = false;
        for (var i = 0; i < document.styleSheets.length; i++) {

            if (document.styleSheets[i].rules) {
                cssRules = 'rules';  // old IE8-
            } else if (document.styleSheets[i].cssRules) {
                cssRules = 'cssRules';  // W3C: IE9+, FF 3+, Safari 4+, Chrome 4+, Opera 10.10+
            } else {
                continue;
            }
            // first check if stylesheet has the rule by the name.  If found, update its value and break;
            for (var j = 0; j < document.styleSheets[i][cssRules].length; j++) {
                if (document.styleSheets[i][cssRules][j].selectorText === inCssClass) {
                    if (document.styleSheets[i][cssRules][j].style[inRuleName]) {
                        document.styleSheets[i][cssRules][j].style[inRuleName] = inRuleValue;
                        added = true;
                        break;
                    }
                }
            }
            // the css style sheet doesn't have the rule by the name, add it.
            if (!added) {
                if (document.styleSheets[i].addRule) {  // IE 8-
                    document.styleSheets[i].addRule(inCssClass, inRuleName + ': ' + inRuleValue + ';');
                } else if (document.styleSheets[i].insertRule) {  // W3C: IE9+, FF 3+, Saf 4+, Chrome4+, Opera 10.10+
                    document.styleSheets[i].insertRule(inCssClass + ' { ' + inRuleName + ': ' + inRuleValue + '; }', document.styleSheets[i][cssRules].length);
                }
            }
        }
    }
    return {
        /**
         * Dynamically update the CSS rule.
         * Example:  com.navis.OpenLayers.Util.updateCss("cssClassName", "visibility", "hidden");
         */
        updateCss: function(inCssClass, inRuleName, inRuleValue) {
            return _updateCss(inCssClass, inRuleName, inRuleValue);
        }
    };
})();

zk.$package('com.navis.GeometricNet.Control.DrawFeature');
com.navis.GeometricNet.Control.DrawFeature.DrawNode = OpenLayers.Class(GeometricNet.Control.DrawFeature.DrawNode, com.navis.OpenLayers.Control, {

    initialize: function(inLayer, inHandler, inOptions) {
        GeometricNet.Control.DrawFeature.DrawNode.prototype.initialize.apply(this, arguments);
    },

    CLASS_NAME: "com.navis.GeometricNet.Control.DrawFeature.DrawNode"
});

zk.$package('com.navis.GeometricNet.Control.DrawFeature');
com.navis.GeometricNet.Control.DrawFeature.DrawEdge = OpenLayers.Class(GeometricNet.Control.DrawFeature.DrawEdge, com.navis.OpenLayers.Control, {

    initialize: function(inLayer, inHandler, inOptions) {
        GeometricNet.Control.DrawFeature.DrawEdge.prototype.initialize.apply(this, arguments);
    },

    CLASS_NAME: "com.navis.GeometricNet.Control.DrawFeature.DrawEdge"
});

/**
 * Override default behavior of GeometricNet for - 1) to add one more layer called 'direction' to render arrow symbols.
 * 2) to add new events to Network itself.
 */
zk.$package('com.navis.GeometricNet');
com.navis.GeometricNet.Network = OpenLayers.Class(GeometricNet.Network, {

    EVENT_TYPES: ["visibilitychanged"],

    /**
	 * APIProperty: direction
	 * {com.navis.GeometricNet.Layer.Vector.Direction}
	 * Edge layer of this network
	 */
	direction : null,

    visibility : true,

    /**
     * APIProperty: events
     * {<OpenLayers.Events>}
     */
    events: null,

    /**
     * APIProperty: eventListeners
     * {Object} If set as an option at construction, the eventListeners
     *     object will be registered with <OpenLayers.Events.on>.  Object
     *     structure must be a listeners object as shown in the example for
     *     the events.on method.
     */
    eventListeners: null,

    initialize: function(name, map, config) {
        //TODO remove name as parameter
        if (name == undefined && map == undefined && config == undefined) {
            return null;
        }
        this.name = config.name;
        if (map instanceof OpenLayers.Map) {
            this.map = map;
        } else {
            return null;
        }
        this.config = jq.extend({}, config);

        //create direction layer
        this.direction = this.createDirectionLayer(this.config);
        this.direction.network = this;
        map.addLayer(this.direction);
        // create node layer
        this.node = this.createNodeLayer(this.config);
        this.node.network = this;
        map.addLayer(this.node);
        //create edge layer
        this.edge = this.createEdgeLayer(this.node, this.config);
        this.edge.network = this;
        map.addLayer(this.edge);

        OpenLayers.Util.extend(this, config);
        this.events = new OpenLayers.Events(this, null, this.EVENT_TYPES);
        if (this.eventListeners instanceof Object) {
            this.events.on(this.eventListeners);
        }
        // get uid prefix
        this.getUidPrefix();
        this.events.register("visibilitychanged",this,this.onVisibilityChanged);
    },

    /**
     * called whenever the network visibility is changed to disable/enable those controls applicable for the layers under the network.
     */
    onVisibilityChanged: function() {
        this.resetControls();
    },

    resetControls : function() {
        if (this.map) {
            var controls = this.map.controls;
            for (var i = 0; i < controls.length; i++) {
                var control = controls[i];
                if (control instanceof com.navis.OpenLayers.Control.Panel) {
                    var panelControls = control.getControls();
                    for (var p = 0; p < panelControls.length; p++) {
                        this.resetControl(panelControls[p]);
                    }
                }
            }
            return true;
        }
        return false;
    },


    resetControl : function(inControl) {
        if (inControl.layer && inControl.layer.network && inControl.layer.network.name === this.name) {
            if (this.visibility) {
                inControl.enable();
            } else {
                inControl.disable();
            }
        }
    },

    /**
     * Method: createNodeLayer
     * function to create network node layer
     * Parameters:
     * Returns:
     * {<com.navis.GeometricNet.Layer.Vector.Node>}
     */
    createNodeLayer: function(networkConfig) {
        var options={};
        var defaultLookup = {};
        var symbolCount = 0;
        for (node in networkConfig.nodeLayer.nodes){
            if (networkConfig.nodeLayer.nodes[node].symbols) {
                defaultLookup[node] = networkConfig.nodeLayer.nodes[node].symbols.defaultStyle;
                symbolCount++;
            }
        }
        var styleMap = new OpenLayers.StyleMap();
        if (symbolCount > 0){
            styleMap.addUniqueValueRules("default", networkConfig.nodeLayer.typeAttributeName,defaultLookup);
        }
        if(networkConfig.nodeLayer.customstyle.attributes !== undefined) {
            var styleOptions = {};
            if(networkConfig.nodeLayer.customstyle.context !== undefined) {
                for (var key in networkConfig.nodeLayer.customstyle.context) {
                    if (!styleOptions.context) {
                        styleOptions.context = {};
                    }
                    styleOptions.context[key] = new Function("feature", networkConfig.nodeLayer.customstyle.context[key]);
                }
            }
            styleMap.styles["default"] = new OpenLayers.Style(networkConfig.nodeLayer.customstyle.attributes, styleOptions);
        }
        options.styleMap = styleMap;
        options.projection = networkConfig.projection;
        if(networkConfig.nodeLayer.dataSource.strategies) {
            var strategies = [];
            for (var i=0;i<networkConfig.nodeLayer.dataSource.strategies.length;i++){
                strategies.push(GeometricNet.Util.createStrategy(
                    networkConfig.nodeLayer.dataSource.strategies[i]));
            }
             options.strategies =strategies;
             if (networkConfig.isEditable == true) {
                options.strategies.push( new OpenLayers.Strategy.Save());
             }
         }
         if(networkConfig.nodeLayer.dataSource.protocol) {
             var format = GeometricNet.Util.createFormat(
                             networkConfig.nodeLayer.dataSource.format);
             //var params = {component : "node",network=this.name};
             var params = {};
             var protocol = GeometricNet.Util.createProtocol(
                             networkConfig.nodeLayer.dataSource.protocol,
                             networkConfig.nodeLayer.dataSource.url,format,params);
             options.protocol = protocol;
         }
        options.network = this;
        options.renderers = jq.extend([], networkConfig.nodeLayer.renderers);
        var nodeLayer = new com.navis.GeometricNet.Layer.Vector.Node(this.name+"_node",options);
        return nodeLayer;
    },

	/**
	 * Method: createEdgeLayer
	 * function to create network edge layer
	 * Parameters:
	 * Returns:
	 * {<com.navis.GeometricNet.Layer.Vector.Edge>}
	 */
	createEdgeLayer: function(node,networkConfig) {
		var options={};
		var defaultLookup = {};
		var symbolCount = 0;
		for (edge in networkConfig.edgeLayer.edges){
			if(networkConfig.edgeLayer.edges[edge].symbols) {
				defaultLookup[edge] = networkConfig.edgeLayer.edges[edge].symbols.defaultStyle;
				symbolCount++;
			}
		}
        var styleMap = new OpenLayers.StyleMap();
		if (symbolCount> 0) {
			styleMap.addUniqueValueRules("default", networkConfig.edgeLayer.typeAttributeName,defaultLookup);
		}
        if(networkConfig.edgeLayer.customstyle.attributes !== undefined) {
            styleMap.styles["default"] = new OpenLayers.Style(networkConfig.edgeLayer.customstyle.attributes);
        }
        options.styleMap = styleMap;
		options.projection = networkConfig.projection;
		if (networkConfig.edgeLayer.dataSource.strategies) {
			var strategies = [];
			for (var i=0; i<networkConfig.edgeLayer.dataSource.strategies.length;i++){
				strategies.push(GeometricNet.Util.createStrategy(
					networkConfig.edgeLayer.dataSource.strategies[i]));
			}
	 		options.strategies =strategies;
	 		if (networkConfig.isEditable == true) {
		 		options.strategies.push( new OpenLayers.Strategy.Save());
	 		}

 		}
 		if (networkConfig.edgeLayer.dataSource.protocol) {
	 		var format = GeometricNet.Util.createFormat(
	 						networkConfig.edgeLayer.dataSource.format);
	 		//var params = {component : "edge",network : this.name};
	 		var params = {};
	 		var protocol = GeometricNet.Util.createProtocol(
	 						networkConfig.edgeLayer.dataSource.protocol,
	 						networkConfig.edgeLayer.dataSource.url,format,params);
	 		options.protocol = protocol;
 		}
		options.network = this;
        options.renderers = jq.extend([], networkConfig.edgeLayer.renderers);
        var edgeLayer = new com.navis.GeometricNet.Layer.Vector.Edge(this.name+"_edge",node,options);
		return edgeLayer;
	},

    /**
     * Method: createDirectionLayer
     * function to create network direction layer
     * Parameters:
	 * inNetworkConfig - network config
     * Returns:
     * {<com.navis.GeometricNet.Layer.Vector.Direction>}
     */
    createDirectionLayer: function(inNetworkConfig) {
        return new com.navis.GeometricNet.Layer.Vector.Direction(this.name+"_direction", inNetworkConfig);
    },
	/**
	 * APIMethod: createEditPanel
	 * Create control panel with editable feature control
	 * Parameters:
	 * isSnapping - {boolean}
	 * Returns:
	 * {OpenLayers.Control.Panel}
	 */
	createEditPanel: function(isSnapping){
		var panel = new OpenLayers.Control.Panel();
		panel.name = this.name+"_editPanel";
		var controls =[];
 		controls= controls.concat(this.createEdgeControls());
 		controls= controls.concat(this.createNodeControls());

		if (this.config.saveControlOptions){
			var saveControlOptions = this.config.saveControlOptions;
			saveControlOptions.trigger = this.save;
 			var saveControl = new OpenLayers.Control.Button(saveControlOptions);
 			saveControl.network = this;
 			controls.push(saveControl);
		}
		// add modify control
        if(this.config.modifyControlOptions) {
            controls.push(this.createModifyControl());
        }
 		panel.addControls(controls);
	  	//this.map.addControl(panel);
		if (isSnapping){
	 		var edgeToNodeSnap = new OpenLayers.Control.Snapping({ layer:this.edge ,targets:[{layer:this.node}] });
	 		this.map.addControl(edgeToNodeSnap);
	 		edgeToNodeSnap.activate();
	 		var nodeToEdgeSnap = new OpenLayers.Control.Snapping({ layer:this.node ,targets:[{layer:this.edge}] });
	 		this.map.addControl(nodeToEdgeSnap);
	 		nodeToEdgeSnap.activate();
	 		var edgeToEdgeSnap = new OpenLayers.Control.Snapping({layer:this.edge});
	 		this.map.addControl(edgeToEdgeSnap);
	 		edgeToEdgeSnap.activate();
	 		var nodeToNodeSnap = new OpenLayers.Control.Snapping({layer:this.node});
	 		this.map.addControl(nodeToNodeSnap);
	 		nodeToNodeSnap.activate();
 		}
 		return panel;
	},

    createModifyControl:function() {
        var options = this.config.modifyControlOptions;
        options.mode = OpenLayers.Control.ModifyFeature.DRAG;
        var control = new com.navis.OpenLayers.Control.ModifyFeature(this.node, options);
        return control;
    },

    /**
     * APIMethod: createNodeControls
     * create network features edge,node layers and control
     * Parameters:
     */
    createNodeControls: function(){
        var controls=[];
        for (node in this.config.nodeLayer.nodes){
            var isEditable = true;
            if (this.config.nodeLayer.nodes[node].isEditable != undefined){
                isEditable = this.config.nodeLayer.nodes[node].isEditable;
            }
            if(isEditable && this.config.nodeLayer.nodes[node].controlOptions) {
                this.config.nodeLayer.nodes[node].controlOptions.nodeType = node;
                controls.push(new com.navis.GeometricNet.Control.DrawFeature.DrawNode(
                    this.node,com.navis.OpenLayers.Handler.Point,this.config.nodeLayer.nodes[node].controlOptions));
            }
        }
        return controls;
    },

    /**
     * APIMethod: createEdgeControls
     * create network features edge,node layers and control
     * Parameters:
     */
    createEdgeControls: function(){
        var controls=[];
        for (edge in this.config.edgeLayer.edges){
            var isEditable = this.config.edgeLayer.edges[edge].isEditable ?
                this.config.edgeLayer.edges[edge].isEditable : true;
            if(isEditable && this.config.edgeLayer.edges[edge].controlOptions) {
                this.config.edgeLayer.edges[edge].controlOptions.edgeType = edge;
                controls.push(new com.navis.GeometricNet.Control.DrawFeature.DrawEdge(
                    this.edge,com.navis.OpenLayers.Handler.Path,this.config.edgeLayer.edges[edge].controlOptions));
            }
        }
        return controls;
    },

    setVisibility: function(visibility) {
        if (visibility != this.visibility) {
            this.visibility = visibility;
            this.events.triggerEvent("visibilitychanged");
        }
    },

    CLASS_NAME: "com.navis.GeometricNet.Network"
});

zk.$package('com.navis.GeometricNet.Layer.Vector');
com.navis.GeometricNet.Layer.Vector.Node = OpenLayers.Class(GeometricNet.Layer.Vector.Node, com.navis.OpenLayers.Layer.Vector, {

	/**
	 * Constructor: com.navis.OpenLayers.Control.GeometricNet.Layer.Node
	 *
	 * Parameters:
	 * name - {String}
	 * options - {Object} Hashtable of extra options onto layer
	 */
    initialize: function(name, options) {
        GeometricNet.Layer.Vector.Node.prototype.initialize.apply(this, arguments);
		this.events.register("afterfeaturemodified",this,this.onAfterFeatureModified);
    },


	/**
	 * Method: onAfterFeatureModified
	 * Function to be triggered on event "afterfeaturemodified"
	 */
	onAfterFeatureModified: function(event) {
		var node = event.feature;
		var edges = node.getStartEdges();
		edges  = edges.concat(node.getEndEdges());
		for (var i=0;i<edges.length;i++){
			this.network.edge.onNodeMove(edges[i]);
		}
	},

    CLASS_NAME: "com.navis.GeometricNet.Layer.Vector.Node"
});

zk.$package('com.navis.GeometricNet.Layer.Vector');
com.navis.GeometricNet.Layer.Vector.Edge = OpenLayers.Class(GeometricNet.Layer.Vector.Edge, com.navis.OpenLayers.Layer.Vector, {

	/**
	 * Constructor: com.navis.OpenLayers.Control.GeometricNet.Layer.Edge
	 *
	 * Parameters:
	 * name - {String}
	 * node - {<com.navis.GeometricNet.Layer.Vector.Node>} Node layer of the network
	 * options - {Object} Hashtable of extra options onto layer
	 */
	initialize: function(name,node, options) {
        GeometricNet.Layer.Vector.Edge.prototype.initialize.apply(this, arguments);
    },

	/**
	 * Method: onNodeMove
	 * trigger the event on featuremodified
	 * Parameters:
	 * node - {<GeometricNet.Feature.Vector.Node>}
	 */
	onNodeMove: function(edge) {
		//node can be utilised later
		this.events.triggerEvent("afterfeaturemodified",{feature:edge});
	},

	/**
	 * Method: createEndNodes
	 * create end nodes to the edge - overriden the original GeometricNet implementation to inject creation of edge sectin logic.
     * Original implementation has been renamed as addEndNodes().
	 * Input:
	 * edge - <GeometricNet.Feature.Vector.Edge>
	 * Returns:
	 * {boolean} - true if network condition satisfied
	 */
	createEndNodes: function(edge) {
        var result = !this.overlyingEdge(edge) && this.addEndNodes(edge);
        if(result) {
            this.createEdgeSections(edge);
        }
		return result;
    },

    overlyingEdge: function(edge) {
        var edgeGeo = edge.geometry;
        var allSegs = com.navis.OpenLayers.Util.getSegments(edgeGeo);
        for(var i = 0; i < this.features.length; i++) {
            if(this.hasOverlyingSegment(allSegs, com.navis.OpenLayers.Util.getSegments(this.features[i].geometry))) {
                return true;
            }
        }
        return false;
    },

    hasOverlyingSegment: function(segments1, segments2) {
        for(var outer = 0; outer < segments1.length; outer++) {
            var segOuter = segments1[outer];
            var segOuterStart = new OpenLayers.Geometry.Point(segOuter.x1,segOuter.y1);
            var segOuterEnd = new OpenLayers.Geometry.Point(segOuter.x2,segOuter.y2);
            segOuterStart = this.addBufferIfNecessary(segOuterStart);
            segOuterEnd = this.addBufferIfNecessary(segOuterEnd);
            for(var inner = 0; inner < segments2.length; inner++) {
                var segInnerString = com.navis.OpenLayers.Util.convertSegmentToLineString(segments2[inner]);
                if(segOuterStart.intersects(segInnerString) && segOuterEnd.intersects(segInnerString)){
                    return true;
                }
            }
        }
        return false;
    },

    addBufferIfNecessary: function(point) {
        if (this.network.config.isTopology) {
            return this.node.buffer(point,this.network.config.tolerance);
        }
        return point;
    },

    /**
     * Splits edge into sections ending on real network node if found on edge vertices
     * @param edge <GeometricNet.Feature.Vector.Edge>
     */
    createEdgeSections: function(edge) {
        var vertices = edge.geometry.getVertices(false);
        edge.attributes.nodesIntersected = [];
        edge.sections = [];
        var sectionCoords = [];
        sectionCoords.push(edge.geometry.getVertices(true)[0]);
        for(var index = 0; index < vertices.length; index++) {
            sectionCoords.push(vertices[index]);
            var nodes = this.node.getFeaturesIntersected(vertices[index]);
            if(nodes && nodes.length > 0) {
                edge.attributes.nodesIntersected.push(nodes[0].attributes.gkey);
                //create a new edge section
                edge.sections.push(new OpenLayers.Geometry.LineString(sectionCoords));
                //reset section coords and add currect vertex as start point for another possible section
                sectionCoords = [];
                sectionCoords.push(vertices[index]);
            }
        }
        sectionCoords.push(edge.geometry.getVertices(true)[1]);
        edge.sections.push(new OpenLayers.Geometry.LineString(sectionCoords));
    },

    /**
     * This is slightly modified from its original implementation from GeometricNet to bypass unnecessary validations.
     * Also, checks all edges intersected by the end nodes instead of checking only the first intersected edge.
     * @param edge
     */
    addEndNodes:function(edge) {
        var startPoint,endPoint;
        var startNode,endNode;
        if (edge.attributes.startNode == undefined) {
            startPoint = edge.geometry.getVertices(true)[0];
            nodeType = this.network.config.edgeLayer.edges[edge.attributes.edgeType].defaultStartNode;
            startNode = new GeometricNet.Feature.Vector.Node(startPoint, {nodeType:nodeType}, {fid:this.node.createUniqueFid()});
            startNode.state = OpenLayers.State.INSERT;
            startNode.layer = this.node;
            edge.attributes.startNode = startNode.fid;
        }
        if (edge.attributes.endNode == undefined) {
            endPoint = edge.geometry.getVertices(true)[1];
            nodeType = this.network.config.edgeLayer.edges[edge.attributes.edgeType].defaultEndNode;
            endNode = new GeometricNet.Feature.Vector.Node(endPoint, {nodeType:nodeType}, {fid:this.node.createUniqueFid()});
            endNode.state = OpenLayers.State.INSERT;
            endNode.layer = this.node;
            edge.attributes.endNode = endNode.fid;
        }
        if (this.network.config.isTopology) {
            var endNodes = [startNode,endNode];
            var nodesWithinTolerance = [];
            var isNodeSnapped;
            var nodesToAddNodeLayer = [];
            nodesWithinTolerance = this.node.getFeaturesIntersected(startNode.geometry);
            if (nodesWithinTolerance.length > 0) {
                if (edge.canSnapToNode(nodesWithinTolerance[0], 0)) {
                    edge.snapToNode(nodesWithinTolerance[0], 0);
                } else {
                    return false;
                }
            } else {
                startNode.attributes.startEdges.push(edge.fid);
                nodesToAddNodeLayer.push(startNode);
                this.considerSnap(startNode);
            }
            nodesWithinTolerance = this.node.getFeaturesIntersected(endNode.geometry);
            if (nodesWithinTolerance.length > 0) {
                if (edge.canSnapToNode(nodesWithinTolerance[0], 1)) {
                    edge.snapToNode(nodesWithinTolerance[0], 1);
                } else {
                    return false;
                }
            } else {
                endNode.attributes.endEdges.push(edge.fid);
                nodesToAddNodeLayer.push(endNode);
                this.considerSnap(endNode);
            }
            this.node.addFeatures(nodesToAddNodeLayer);
        } else {
            this.node.addFeatures([startNode,endNode]);
        }
        return true;
    },


	/**
	 * Method: considerSnap
	 * Checks if given node false within the tolerance of exsting edges; original GeometricNet implementation splits those intersecting edges;
     * here, the overriden implementation just appends details about the edges and rest need to be done at server side.
	 * Input:
	 *	node - <OpenLayers.Feature.Vector.Node>
	 * Returns:
	 *	boolean
	 */
	considerSnap: function(node) {
        node.attributes.edgesIntersected = [];
		var intersectedEdges = this.getFeaturesIntersected(node.geometry);
		if (intersectedEdges.length > 0) {
            this.snapToEdgeVertices(node, intersectedEdges);
			for (var i=0;i<intersectedEdges.length ; i++ ) {
                var edge = intersectedEdges[i];
                node.attributes.edgesIntersected.push({"gkey":edge.attributes.gkey,
                                                        "isTwoWayPath":edge.attributes.isTwoWayPath,
                                                        "otherPathGkey":edge.attributes.otherPathGkey});
			}
		}
        return true;
	},

    snapToEdgeVertices: function(node, intersectedEdges) {
        var nodeBuffered = this.addBufferIfNecessary(node.geometry);
        for (var i=0;i<intersectedEdges.length ; i++ ) {
            var edge = intersectedEdges[i];
            var virtualVertices = edge.geometry.getVertices(false);
            for(var vIndex=0;vIndex<virtualVertices.length;vIndex++) {
                var vvBuffered = this.addBufferIfNecessary(virtualVertices[vIndex]);
                if(nodeBuffered.intersects(vvBuffered)) {
                    node.geometry = virtualVertices[vIndex];
                    return;
                }
            }
        }
    },

    CLASS_NAME: "com.navis.GeometricNet.Layer.Vector.Edge"
});

zk.$package('com.navis.GeometricNet.Layer.Vector');
com.navis.GeometricNet.Layer.Vector.Direction = OpenLayers.Class(OpenLayers.Layer.Vector, com.navis.OpenLayers.Layer.Vector, {

    /**
     * Property: network
     * {<com.navis.GeometricNet.Network>} network of this edge layer
     */
    network: null,

    /**
     * Property: position
     * {String} Where the direction symbol to be displayed
     */
    position: null,

    /**
     * Property: forEachSegment
     * {boolean} should symbol be displayed for each segment
     */
    forEachSegment: false,

	/**
	 * Property: lastId
	 * {integer}
	 * last id, ie used to create unique fid with network.uidPrefix
	 */
	lastId: 0,

    initialize: function(name, inNetworkConfig) {
        OpenLayers.Renderer.symbol.arrow = [0,2, 1,0, 2,2, 1,0, 0,2];
        var styleMap = new OpenLayers.StyleMap();
        if(inNetworkConfig.directionLayer.customstyle.attributes !== undefined) {
            var style = jq.extend({graphicName:"arrow",rotation : "${angle}"},inNetworkConfig.directionLayer.customstyle.attributes);
            var styleOptions = {};
            if(inNetworkConfig.directionLayer.customstyle.context !== undefined) {
                for (var key in inNetworkConfig.directionLayer.customstyle.context) {
                    if (!styleOptions.context) {
                        styleOptions.context = {};
                    }
                    styleOptions.context[key] = new Function("feature", inNetworkConfig.directionLayer.customstyle.context[key]);
                }
            }
            styleMap = new OpenLayers.StyleMap(new OpenLayers.Style(style, styleOptions));
        } else {
            styleMap = new OpenLayers.StyleMap(OpenLayers.Util.applyDefaults(
                            {graphicName:"arrow",rotation : "${angle}"},
                            OpenLayers.Feature.Vector.style["default"]));
        }
        inNetworkConfig.directionLayer.styleMap = styleMap;

        OpenLayers.Layer.Vector.prototype.initialize.call(this, name, inNetworkConfig.directionLayer);
    },


	/**
	 * APIProperty: createUniqueFid
	 * Create a unique fid  for this layer
	 * Returns:
	 * {integer}
	 */
	createUniqueFid : function(){
		this.lastId = this.lastId + 1;
		var fid = "direction_"+this.network.uidPrefix+"_"+this.lastId;
		return fid;
	},

    /**
     * APIMethod: createDirection
     * Create dirction symbol point {<openLayers.Feature.Vector>} of the line
     * with attribute as angle (degree) for given position(s) on line
     * Parameter:
     * line - {<OpenLayers.Geometry.LineString>} or {<OpenLayers.Geometry.MultiLineString>}
     */
    createDirection : function(line) {
        var points =[];
        if (line instanceof OpenLayers.Geometry.LineString) {
            points = this.createLineStringDirection(line,this.position, this.forEachSegment);
        }
        return points;
    },

    /**
     * Creates one-way direction symbol.  A point is rendered as an arrow.
     *
     * @param line
     * @param position
     * @param forEachSegment
     */
    createLineStringDirection : function(line,position, forEachSegment){
        if (position == undefined ){ position =com.navis.GeometricNet.Layer.Vector.Direction.DIRECTION_SYMBOL_POSITION_END;}
        if (forEachSegment == undefined ) {forEachSegment = false;}
        var points =[];
        //var allSegs = line.getSortedSegments();
        var allSegs = com.navis.OpenLayers.Util.getSegments(line);
        var segs = [];

        if (forEachSegment)	{
            segs = allSegs;
        } else {
            if  (position == com.navis.GeometricNet.Layer.Vector.Direction.DIRECTION_SYMBOL_POSITION_START) {
                segs.push(allSegs[0]);
            } else if (position == com.navis.GeometricNet.Layer.Vector.Direction.DIRECTION_SYMBOL_POSITION_END) {
                segs.push(allSegs[allSegs.length-1]);
            } else if (position == com.navis.GeometricNet.Layer.Vector.Direction.DIRECTION_SYMBOL_POSITION_MIDDLE){
                return [this.getPointOnLine(line,.5)];
            } else {
                return [];
            }
        }
        for (var i=0;i<segs.length ;i++) {
            points = points.concat(this.createSegDirection(segs[i],position) );
        }
        return points;
    },


    /**
     * Creates two-way direction symbol by rendering arrow symbol indicating both ways.
     * @param line      LineString
     */
    createTwoWayDirection : function(line) {
        var points = [];
        var allSegs = com.navis.OpenLayers.Util.getSegments(line);
        for(var index=0;index<allSegs.length;index++ ) {
            var segment = allSegs[index];
            var segmentHalves = this.splitSegment(segment);
            if(segmentHalves && segmentHalves.length === 2) {
                var reversedHalf = this.reverseLineSegment(segmentHalves[0]);
                points = points.concat(this.createSegDirection(reversedHalf,
                        com.navis.GeometricNet.Layer.Vector.Direction.DIRECTION_SYMBOL_POSITION_MIDDLE));
                points = points.concat(this.createSegDirection(segmentHalves[1],
                        com.navis.GeometricNet.Layer.Vector.Direction.DIRECTION_SYMBOL_POSITION_MIDDLE));
            }
        }
        return points;
    },

    reverseLineSegment : function(lineSegment) {
        return {x1:lineSegment.x2,y1:lineSegment.y2,x2:lineSegment.x1,y2:lineSegment.y1};
    },

    splitSegment : function(lineSegment) {
        var segments;
        var segmentString = com.navis.OpenLayers.Util.convertSegmentToLineString(lineSegment);
        var midPoint = this.getPointOnLine(segmentString, .5);
        if(midPoint) {
            segments = new Array(2);
            var midPointXY = midPoint.geometry;
            segments[0] = {x1:lineSegment.x1,y1:lineSegment.y1,x2:midPointXY.x,y2:midPointXY.y};
            segments[1] = {x1:midPointXY.x,y1:midPointXY.y,x2:lineSegment.x2,y2:lineSegment.y2};
        }
        return segments;
    },

    createSegDirection : function(seg,position) {
        var segBearing = this.bearing(seg);
        var positions = [];
        var points = [];
        if  (position == com.navis.GeometricNet.Layer.Vector.Direction.DIRECTION_SYMBOL_POSITION_START) {
            positions.push([seg.x1,seg.y1]);
        } else if (position == com.navis.GeometricNet.Layer.Vector.Direction.DIRECTION_SYMBOL_POSITION_END) {
            positions.push([seg.x2,seg.y2]);
        } else if (position == com.navis.GeometricNet.Layer.Vector.Direction.DIRECTION_SYMBOL_POSITION_MIDDLE) {
            positions.push([(seg.x1+seg.x2)/2,(seg.y1+seg.y2)/2]);
        } else {
            return null;
        }
        for (var i=0;i<positions.length;i++ ){
            var pt = new OpenLayers.Geometry.Point(positions[i][0],positions[i][1]);
            var ptFeature = new OpenLayers.Feature.Vector(pt,{angle:segBearing});
            points.push(ptFeature);
        }
        return points;
    },

    bearing : function(seg) {
        var b_x = 0;
        var b_y = 1;
        var a_x = seg.x2 - seg.x1;
        var a_y = seg.y2 - seg.y1;
        var angle_rad = Math.acos((a_x*b_x+a_y*b_y)/Math.sqrt(a_x*a_x+a_y*a_y)) ;
        var angle = 360/(2*Math.PI)*angle_rad;
        if (a_x < 0) {
            return 360 - angle;
        } else {
            return angle;
        }
    },

    getPointOnLine : function (line,measure) {
        var segs = com.navis.OpenLayers.Util.getSegments(line);
        var lineLength = line.getLength();
        var measureLength = lineLength*measure;
        var length = 0;
        var partLength=0;
        for (var i=0;i<segs.length ;i++ ) {
            var segLength = this.getSegmentLength(segs[i]);
            if (measureLength < length + segLength) {
                partLength = measureLength - length;
                var x = segs[i].x1 + (segs[i].x2 - segs[i].x1) * partLength/segLength;
                var y = segs[i].y1 + (segs[i].y2 - segs[i].y1) * partLength/segLength;
                var segBearing = this.bearing(segs[i]);
                var pt = new OpenLayers.Geometry.Point(x,y);
                var ptFeature = new OpenLayers.Feature.Vector(pt,{angle:segBearing});
                return ptFeature;
            }
            length = length + segLength;
        }
        return false;
    },

    getSegmentLength : function(seg) {
        return Math.sqrt( Math.pow((seg.x2 -seg.x1),2) + Math.pow((seg.y2 -seg.y1),2) );
    },

    CLASS_NAME: "com.navis.GeometricNet.Layer.Vector.Direction"
});
com.navis.GeometricNet.Layer.Vector.Direction.DIRECTION_SYMBOL_POSITION_START="start";
com.navis.GeometricNet.Layer.Vector.Direction.DIRECTION_SYMBOL_POSITION_MIDDLE="middle";
com.navis.GeometricNet.Layer.Vector.Direction.DIRECTION_SYMBOL_POSITION_END="end";

zk.$package("com.navis.OpenLayers.Strategy");
com.navis.OpenLayers.Strategy.BBOX = OpenLayers.Class(OpenLayers.Strategy.BBOX, {
    initialize: function(options) {
        OpenLayers.Strategy.BBOX.prototype.initialize.apply(this, [options]);
    },
    update: function(options) {
        var mapBounds = this.getMapBounds();
        if ((options && options.force) || this.invalidBounds(mapBounds)) {
            this.calculateBounds(mapBounds);
            this.resolution = this.layer.map.getResolution();
            var zoom = this.layer.map.getZoom();
            this.layer.events.triggerEvent("refreshbbox", {bounds: mapBounds, resolution: this.resolution, zoom: zoom})
        }
    },

    CLASS_NAME: "com.navis.OpenLayers.Strategy.BBOX"
});

zk.$package("com.navis.OpenLayers.Geometry");
com.navis.OpenLayers.Geometry.MultiPolygon = OpenLayers.Class(OpenLayers.Geometry.MultiPolygon, {
    postInitialize: function() {
        var multiPolyGkey = null;
        if (this.attributes && this.attributes.hasOwnProperty("gkey")) {
            multiPolyGkey = this.attributes.gkey;
        }
        if (multiPolyGkey !== null) {
            for(var i=0,len=this.components.length;i<len;++i) {
                var component = this.components[i];
                var componentGkey = null;
                if (component.attributes && component.attributes.hasOwnProperty("gkey")) {
                    componentGkey = component.attributes.gkey;
                }
                if (componentGkey !== null) {
                    if (componentGkey === multiPolyGkey) {
                        this.boundary = component;
                        break;
                    }
                }
            }
        }
    },

    intersects: function(geometry) {
        if (this.boundary) {
            return (this.boundary.intersects(geometry));
        }

        var intersect=false;
        for(var i=0,len=this.components.length;i<len;++i) {
            var component = this.components[i];
            intersect = geometry.intersects(component);
            if(intersect){
                break;
            }
        }
        return intersect;
    },

    getLabel: function(eventGeometry) {
        var intersect = null;
        // get the last intersected geometry..components are ordered
        for(var i=0,len=this.components.length;i<len;++i) {
            var component = this.components[i];
            if(eventGeometry.intersects(component)){
                intersect = component;
            }
        }
        if (intersect !== null && intersect.attributes && intersect.attributes.label) {
            return intersect.attributes.label;
        }
        return null;
    }

});

zk.$package('com.navis.OpenLayers.Control');
com.navis.OpenLayers.Control.HoverFeature = OpenLayers.Class(com.navis.OpenLayers.Control, {
    EVENT_TYPES: ["hoverfeature", "outfeature"],

    layers: null,

    handlers: null,

    handlerOptions: null,

    initialize: function(layers, zmapWgt, options) {
        // concatenate events specific to this control with those from the base
        this.EVENT_TYPES =
            com.navis.OpenLayers.Control.HoverFeature.prototype.EVENT_TYPES.concat(
            OpenLayers.Control.prototype.EVENT_TYPES
        );

        options.handlerOptions = options.handlerOptions || {};

        OpenLayers.Control.prototype.initialize.apply(this, [options]);

        this.handlers = {};
        this.initPopup(zmapWgt);
        this.layers = layers;
        this.handlers.hover = new OpenLayers.Handler.Hover(
            this, {'move': this.stopHover, 'pause': this.startHover},
            OpenLayers.Util.extend(this.handlerOptions.hover, {
                'delay': 250
            })
        );

    },

    initPopup: function(zmapWgt) {
        this.popup = new zul.wgt.Popup();
        zmapWgt.appendChild(this.popup);
    },

    destroy: function() {
        if(this.active && this.layers) {
            this.map.removeLayer(this.layer);
        }
        if (this.popup) {
            if (this.popup.isOpen()) {
                this.popup.close();
            }
            this.popup.detach();
        }
        this.popup = null;
        for (var handler in this.handlers) {
            handler.destroy();
        }
        this.handlers = null;
        this.layers = null;
        OpenLayers.Control.prototype.destroy.apply(this, arguments);
    },

    activate: function () {
        if (!this.active) {
            this.handlers.hover.activate();
        }
        return OpenLayers.Control.prototype.activate.apply(
            this, arguments
        );
    },

    deactivate: function () {
        if (this.active) {
            this.handlers.hover.deactivate();
            if (this.popup && this.popup.isOpen()) {
                this.popup.close();
            }
        }
        return OpenLayers.Control.prototype.deactivate.apply(
            this, arguments
        );
    },

    setMap: function(map) {
        this.handlers.hover.setMap(map);

        OpenLayers.Control.prototype.setMap.apply(this, arguments);
    },

    setLayer: function(layers) {
        var isActive = this.active;
        this.deactivate();
        this.layers = layers;
        if (isActive) {
            this.activate();
        }
    },

    startHover: function(evt) {
        var hoverText = this.getHoverTextForEvent(evt);
        if (hoverText !== null) {
            var label = new zul.wgt.Label({value: hoverText});
            this.popup.appendChild(label);

            // Ugly hack to make sure the popup works with ULC Browser
            // Without the below work around, the popup walks down the page
            this.popup.open(null, [0,0], null);
            var dim = {
                left: evt.xy.x,
                top: evt.xy.y,
                width: 0,
                height: 0
            };
            zk(this.popup.$n()).position(dim, "after_pointer");

//          this.popup.open(null, [evt.xy.x,evt.xy.y], "after_pointer");
         }
    },

    stopHover: function(evt) {
        if (this.popup && this.popup.isOpen()) {
            this.popup.close();
            this.popup.clear();
        }
    },

    getHoverTextForEvent: function(evt) {
     /* precedence ranks to facilitate feature selection when more than one feature intersect; smallest vector gets the lowest precedence rank & wins
        selection; precedece is defined here and set before adding a vector to a layer. Default precedence is 99 and set in ZVector. Validation here
        is second level to check precedence across layers. */
        var eventFeature = null;
        var precedence = 100;
        for(var i = 0; i < this.layers.length; i++) {
            var layer = this.layers[i];
            if (layer.visibility && layer.getFeatureFromEvent) {
                var feature = layer.getFeatureFromEvent(evt);
                if (feature && feature.attributes && (!feature.attributes.selectionPrecedence || precedence > feature.attributes.selectionPrecedence)) {
                    eventFeature = feature;
                    precedence = feature.attributes.selectionPrecedence;
                }
            }
        }
        if (eventFeature !== null) {
            if (eventFeature.geometry && eventFeature.geometry.getLabel) {
                var loc = this.map.getLonLatFromPixel(evt.xy);
                var resolution = this.map.getResolution();
                var bounds = new OpenLayers.Bounds(loc.lon - resolution * 5,
                                                   loc.lat - resolution * 5,
                                                   loc.lon + resolution * 5,
                                                   loc.lat + resolution * 5);
                var eventGeometry = bounds.toGeometry();
                var label = eventFeature.geometry.getLabel(eventGeometry);
                if (label !== null) {
                    return label;
                }
            }
            else if (eventFeature.label) {
                return eventFeature.label;
            }
            return eventFeature.id;
        }
        return null;
    },

    CLASS_NAME: "com.navis.OpenLayers.Control.HoverFeature"
});

// Remove right click from all handlers since we handle context menu by default
zk.$package("com.navis.OpenLayers.Handler");
(function () {
    for (var className in OpenLayers.Handler) {
        if (typeof OpenLayers.Handler[className] !== "function") {
            continue;
        }
        if (typeof OpenLayers.Handler[className].prototype.CLASS_NAME === "undefined") {
            continue;
        }
        if (com.navis.OpenLayers.Handler[className] === "function") {
            continue;
        }

        com.navis.OpenLayers.Handler[className] = OpenLayers.Class(OpenLayers.Handler[className], {
            superClassName: className,
            mousedown: function(evt) {
                if (OpenLayers.Event.isRightClick(evt)) {
                    OpenLayers.Event.stop(evt, false);
                    return false;
                }
                if (OpenLayers.Handler[this.superClassName].prototype.mousedown) {
                    return OpenLayers.Handler[this.superClassName].prototype.mousedown.apply(this, arguments);
                }
                return true;
            }
        });
    }
})();

com.navis.OpenLayers.Util.getSegments = function(line) {
        var numSeg = line.components.length - 1;
        var segments = new Array(numSeg), point1, point2;
        for(var i=0; i<numSeg; ++i) {
            point1 = line.components[i];
            point2 = line.components[i + 1];
            segments[i] = {
                x1: point1.x,
                y1: point1.y,
                x2: point2.x,
                y2: point2.y
            };
        }
        return segments;
};

com.navis.OpenLayers.Util.convertSegmentToLineString = function(segment) {
    var segStart = new OpenLayers.Geometry.Point(segment.x1,segment.y1);
    var segEnd = new OpenLayers.Geometry.Point(segment.x2,segment.y2);
    return new OpenLayers.Geometry.LineString([segStart,segEnd]);
};
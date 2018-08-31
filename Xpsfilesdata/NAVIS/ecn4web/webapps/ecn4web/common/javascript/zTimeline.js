/*
 * Copyright (c) 2013 Navis LLC. All Rights Reserved.
 * Create a 2D view of the Sections in a Vessel for the crane team UI.
 * Graphic coordinate system is X right, Y down, with origin at the top left. Vessel outline and Section shapes are
 * maintained in separate graphic layers.  Section selection is indicated by the Section shape background color.
 */
var ESBMessagingMonitor = $.extend({}, ZkGraphicScript, {

    _maxEventsToBePlotted: 3000,  // max number of events to be plotted on the time line.  The oldest events will be dropped.

    _items: null,

    _selectedDetails: null,

    //_msgIdMap: {},
    _visIdMap: {},

    _groupId: [],

    _groups: null,  // vis.DataSet to keep track of groups on the left panel

    _id: 0, // used to assign to incoming messages, and is capped by _maxEventsToBePlotted

    _pause: false,

    _msTrafficOption: {
        height: '90%',
        margin: {
            axis: 2, // the minimal margin in pixels between items and the time axis.
            item: 2  // the minimal margin in pixels between items in both horizontal and vertical direction.
        },
        start: new Date(),
        zoomMin: 50,              // 500 milliseconds
        zoomMax: 1000             // about 1 second in milliseconds
    },

    _sTrafficOption: {
        height: '90%',
        margin: {
            axis: 2, // the minimal margin in pixels between items and the time axis.
            item: 2  // the minimal margin in pixels between items in both horizontal and vertical direction.
        },
        start: new Date(),
        zoomMin: 50,              // 500 milliseconds
        zoomMax: 1000 * 60 * 3    // about 3 minutes in milliseconds
    },

    _mTrafficOption: {
        height: '90%',
        margin: {
            axis: 2, // the minimal margin in pixels between items and the time axis.
            item: 2  // the minimal margin in pixels between items in both horizontal and vertical direction.
        },
        start: new Date(),
        zoomMin: 50,              // 500 milliseconds
        zoomMax: 1000 * 60 * 5    // about 5 minutes in milliseconds
    },

    _hourLimitTrafficOption: {
        height: '90%',
        margin: {
            axis: 2, // the minimal margin in pixels between items and the time axis.
            item: 2  // the minimal margin in pixels between items in both horizontal and vertical direction.
        },
        start: new Date(),
        zoomMin: 50,              // 500 milliseconds
        zoomMax: 1000 * 60 * 60    // about 1 hour in milliseconds
    },

    _dayLimitTrafficOption: {
        height: '90%',
        margin: {
            axis: 2, // the minimal margin in pixels between items and the time axis.
            item: 2  // the minimal margin in pixels between items in both horizontal and vertical direction.
        },
        start: new Date(),
        zoomMin: 50,              // 500 milliseconds
        zoomMax: 1000 * 60 * 60 * 24    // about 1 day in milliseconds
    },

    // ZkGraphicScript
    receiveMessage: function (inMessage) {
        if ('initGroupOptions' in inMessage) {
            var options = jq.evalJSON(inMessage.initGroupOptions);

            var selectWidget = document.createElement('select');
            var html = '';
            for(var option in options) {
                html += "<option class=\"timelineOption\" value=" + option + ">" +options[option] + "</option>"
            }
            selectWidget.className = 'timelineDropdown';
            selectWidget.innerHTML = html;
            var widget = this;
            selectWidget.onchange = function() {
                widget.sendMessage({'operation' : 'setGroupOption', 'option' : selectWidget.options[selectWidget.selectedIndex].value});
                widget.resetStatistics();
            }
            this.getDomWidget().insertBefore(selectWidget, this.getDomWidget().firstChild);
        } else if ('data' in inMessage) {
            if (this._pause) {
                return; // do nothing
            }
            var list = inMessage.data;
            for (var i = 0; i < list.length; i++) {
                if (list[i].operation == 'add') {
                    if (this._filterText != null && list[i].group.indexOf(this._filterText) < 0) {
                        continue;
                    }
                    this._id = ((this._id + 1) % this._maxEventsToBePlotted);
                    list[i].id = this._id;
                    list[i].start = new Date(list[i].start); // convert the date field from long to Date object
                    if (this._groupId.indexOf(list[i].group) > -1) {
                        // do nothing when we know about this group already
                    } else if (list[i].group) {
                        // add a new group
                        this._groupId[this._groupId.length++] = list[i].group;
                        this._groups.add({id: list[i].group, content: list[i].group});
                    } else {
                        // no group
                        list[i].group = '';
                    }
                    this._visIdMap[list[i].id] = list[i];
//                    this._msgIdMap[list[i].messageId] = list[i];
//                } else if (list[i].operation == 'ack') {
//                    var item = this._msgIdMap[list[i].messageId];
//                    if (item != null) {
//                        var endTime = new Date(list[i].end)
//                        this._items.remove(item);
//                        item.end = endTime;
//                        this._items.add(item);
//                    }
                } else {
                    zk.log('unknown operation: ' + list[i].operation);
                }
            }
            this._items.remove(0);     // to avoid id 0 being inserted twice.  Not sure why it was happening.
            this._items.remove(list);  // remove the old ids first
            this._items.add(list);
            if (list.length > 0) {
                this._timeline.focus(list[list.length-1].id);
            }
        } else if ('notCenterNode' in inMessage) {
            alert('You are not acessing the center node!  Please check your URL.');
        }
    },

    updateSize: function (inWidth, inHeight) {
    },

    // ZkSystemScript

    realize: function () {
        if ('timelineMaxEventsToBePlotted' in this.getAttributes()) {
            this._maxEventsToBePlotted = this.getAttributes().timelineMaxEventsToBePlotted;
        }
        //log.setLevel(log4javascript.Level.TRACE);
        var cssLink = $("<link rel='stylesheet' type='text/css' href='common/css/vis.css'>");
        $("head").append(cssLink);

        cssLink = $("<link rel='stylesheet' type='text/css' href='common/css/navis.vis.css'>");
        $("head").append(cssLink);

        // create a dataset with items
        this._items = new vis.DataSet();

        // I feel stupid to do the following.  Need to think of better way to select the default option in <select>
        var container = this.getDomWidget();
        var options;
        var optionD = '';
        var optionH = '';
        var optionM = '';
        var optionS = '';
        var optionMS = '';
        if ('timelineMaxTimeScale' in this.getAttributes()) {
            var maxScale = this.getAttributes().timelineMaxTimeScale;
            if ('day' == maxScale) {
                options = this._dayLimitTrafficOption;
                optionD = 'selected="selected"';
            } else if ('hour' == maxScale) {
                options = this._hourLimitTrafficOption;
                optionH = 'selected="selected"';
            } else if ('minute' == maxScale) {
                options = this._mTrafficOption;
                optionM = 'selected="selected"';
            } else if ('second' == maxScale) {
                options = this._sTrafficOption;
                optionS = 'selected="selected"';
            } else {
                options = this._msTrafficOption;
                optionMS = 'selected="selected"';
            }
        } else {
            options = this._msTrafficOption;
            optionMS = 'selected="selected"';
        }

        this._groups = new vis.DataSet();
        //this._groups.add({id: '', content: ''});

        this._timeline = new vis.Timeline(container);
        this._timeline.setOptions(options);
        this._timeline.setItems(this._items);
        this._timeline.setGroups(this._groups);

        var widget = this;
        // CREATE CONTORL BUTTONS
        // Zoom Button
        var zoomSelect = document.createElement('select'); //ocument.createElement('button');
        var zoomOptions = '<option class=\"timelineOption\" ' + optionMS + '>Time scale in ms (fastest)</option>';
        zoomOptions += '<option class=\"timelineOption\" ' + optionS + '>Time scale in second</option>';
        zoomOptions += '<option class=\"timelineOption\" ' + optionM + '>Time scale in minute</option>';
        zoomOptions += '<option class=\"timelineOption\" ' + optionH + '>Time scale in hour</option>';
        zoomOptions += '<option class=\"timelineOption\" ' + optionD + '>Time scale in day (slowest)</option>';
        zoomSelect.className = 'timelineDropdown';
        zoomSelect.innerHTML = zoomOptions;
        this.getDomWidget().insertBefore(zoomSelect, this.getDomWidget().firstChild);
        zoomSelect.onchange = function() {
            var visibleIds = widget._timeline.getVisibleItems();
            if (zoomSelect.selectedIndex==0) {
                widget._timeline.setOptions(widget._msTrafficOption);
            } else if (zoomSelect.selectedIndex==1) {
                widget._timeline.setOptions(widget._sTrafficOption);
            } else if (zoomSelect.selectedIndex==2) {
                widget._timeline.setOptions(widget._mTrafficOption);
            } else {
                widget._timeline.setOptions(widget._hourLimitTrafficOption);
            }
            if (visibleIds.length > 0) {
                widget._timeline.focus(visibleIds[0]);
            }
        };
        // Pause Button
        var pausebutton = document.createElement('button');
        pausebutton.className = 'timelineButton';
        pausebutton.innerHTML = 'Pause';
        this.getDomWidget().insertBefore(pausebutton, this.getDomWidget().firstChild);
        pausebutton.onclick = function() {
            if (pausebutton.innerHTML == 'Pause') {
                pausebutton.innerHTML = 'Start';
                widget._pause = true;
            } else {
                pausebutton.innerHTML = 'Pause';
                widget._pause = false;
            }
        };
        // Show Group Chart
        var chartButton = document.createElement('button');
        chartButton.className = 'timelineButton';
        chartButton.innerHTML = 'Show Groups Chart';
        this.getDomWidget().insertBefore(chartButton, this.getDomWidget().firstChild);
        chartButton.onclick = function() {
            widget.sendMessage({'operation': 'showPieChart'});
        };
        // Reset the timeline
        var resetButton = document.createElement('button');
        resetButton.className = 'timelineButton';
        resetButton.innerHTML = 'Reset Statistics';
        this.getDomWidget().insertBefore(resetButton, this.getDomWidget().firstChild);
        resetButton.onclick = function() {
            widget.resetStatistics();
        };
        // Filter combo widget
        var filterDiv = document.createElement('div');
        //filterDiv.setAttribute("style","width:250px");
        filterDiv.style.display = "inline-block";
        filterDiv.style.border = "thin solid #000000";
        var filterText = document.createElement('input');
        filterText.type = "text";
        filterDiv.appendChild(filterText);
        var filterButton = document.createElement('button');
        filterButton.className = 'timelineButton';
        filterButton.innerHTML = 'Filter';
        filterDiv.appendChild(filterButton)
        this.getDomWidget().insertBefore(filterDiv, this.getDomWidget().firstChild);
        filterButton.onclick = function() {
            widget.setFilter(filterText.value);
        };
        // message payload panel
        this._selectedDetails = document.createElement('div');
        // create a placeholder for details on the selected event
        this.getDomWidget().appendChild(this._selectedDetails);
        var selectedDetails = this._selectedDetails;
        this._timeline.on('select', function (properties) {
            if (widget._visIdMap[properties.items[0]] != null) {
                selectedDetails.innerHTML = widget._visIdMap[properties.items[0]].message;
            }
        });
    },

    resetStatistics: function() {
        this._visIdMap = {};
        this.sendMessage({'operation': 'resetStatistics'});
        this._groups.clear();
        this._items.clear();
        this._groupId = [];
    },

    setFilter: function(filterString) {
        this._filterText = filterString;
        this._visIdMap = {};
        this._groups.clear();
        this._items.clear();
        this._groupId = [];
    },

});

/** Required by ZkScriptWrapper framework. */
window['com.navis.registry'].push(ESBMessagingMonitor);


/*
 * Copyright (c) 2017 Navis LLC. All Rights Reserved.
 *
 */

/*Workaround for Bug ZK-3263 (Ticket #4316) Preserve scroll position when updating the scroll paddings*/
zk.afterLoad('zul.grid,zkmax', function() {
    var xGrid = {};
    zk.override(zul.grid.Grid.prototype, xGrid, {
        _setPadSize : function() {
            var scrollTopBefore = this.ebody.scrollTop;
            var result = xGrid._setPadSize.apply(this, arguments);
            this.ebody.scrollTop = scrollTopBefore;
            return result;
        }
    });//zk.override
});//zk.afterLoad
zk.afterLoad('zul.sel,zkmax', function() {
    var xListbox = {};
    zk.override(zul.sel.Listbox.prototype, xListbox, {
        _setPadSize : function() {
            var scrollTopBefore = this.ebody.scrollTop;
            var result = xListbox._setPadSize.apply(this, arguments);
            this.ebody.scrollTop = scrollTopBefore;
            return result;
        }
    });//zk.override
});//zk.afterLoad
/*
 * Copyright (c) 2012 Navis LLC. All Rights Reserved.
 *
 */

/**
 * This script allows a child window to be placed within the parent window boundaries after it has been moved.
 *
 * Author: <a href="mailto:gsaavedra@navis.com">Gisella Saavedra</a>, Oct 05, 2012
 */
zk.afterLoad('zul.wnd', function() {
    zul.wnd.Window._aftermove = function(dg, evt) {
        dg.node.style.visibility = "";
        var wgt = dg.control;

        if (wgt._position && wgt._position != "parent") {
            wgt._position = null;
        }
        wgt.zsync();
        wgt._fireOnMove(evt.data);
        var wn = $(wgt);
        var wnp = $(wgt.parent);
        if(wgt.custom) {
            if (parseInt(wn.offset().top) < parseInt(wnp.offset().top)) {
                // Keep this order
                wgt.setPosition("top");
                wgt.setPosition("parent");
            }
        } //  else do nothing
    };
});


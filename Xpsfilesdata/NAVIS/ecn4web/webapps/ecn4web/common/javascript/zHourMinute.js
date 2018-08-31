/*
 * Copyright (c) 2016 Navis LLC. All Rights Reserved.
 *
 */

// onFocusOut() called when the hour-minute text field loses the focus
// it's a place to parse the raw input to the hh:mm format
function onFocusOut(cmp) {
    var raw = cmp.getValue();
    cmp.rawInput = raw;

    //debugger;
    if (raw.length == 3) {
        var min = parseInt(raw.substring(1, 3));
        var hr = parseInt(raw.substring(0, 1));
        if (min < 10) {
            min = "0" + min;
        } else if (min > 60) {
            cmp.setValue(null);
            return;
        }
        cmp.setValue("0" + hr + ':' + min);
    } else if (raw.length == 4) {
        var min = parseInt(raw.substring(2, 4));
        if (min < 10) {
            min = "0" + min;
        } else if (min > 60) {
            cmp.setValue(null);
            return;
        }
        var hr = parseInt(raw.substring(0, 2));
        if (hr < 10) {
            cmp.setValue("0" + hr + ':' + min);
        } else if (hr < 24) {
            cmp.setValue(hr + ':' + min);
        } else {
            cmp.setValue(null);
        }
    } else {
        cmp.setValue(null);
    }
}

// onFocus called when the text field gain focus
// it's a place to revert the parsed formatted string to its original raw input
function onFocus(cmp) {
    if (cmp.rawInput != null) {
        cmp.setValue(cmp.rawInput);
        cmp.smartUpdate('value', cmp.rawInput);
    }
}

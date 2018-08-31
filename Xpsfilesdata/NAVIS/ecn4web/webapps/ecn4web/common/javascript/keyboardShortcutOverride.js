/*
 * Copyright (c) 2016 Navis LLC. All Rights Reserved.
 *
 */

/**
 * Created by fissede on 12/8/2016.
 *
 * This Js class overrides the default browser short cut keys such as Ctr+o, alt+u, etc
 * These overrides are only working on Chrome and Firefox. Not working on IE
 *  67=c
 * 68=d
 * 69=e
 * 70=f (ctrl +f find)
 * 74=j ( to eliminate Ctrl +J for downloads on chrome
 * 78 = n (e.g. ctr+n)
 * 79=o ( e.g. ctrl+o open file)
 * 80=p
 *
 * etc ..
 *
 * refer for js key codes https://css-tricks.com/snippets/javascript/javascript-keycodes/
 */
var firstSelectedItem, controlAndMouseClick;

document.onkeydown = function (event) {
    var code = event.keyCode || event.which;
    var target = event.target || event.srcElement

    //add keycodes to ovveride to this array
    var keyCodes=[68,69,70,73,74,78,79,80,83,84,85,87,89,115];

    if (event.altKey || event.ctrlKey) {
        if (keyCodes.indexOf(code) > -1) {
            event.preventDefault ? event.preventDefault() : (event.returnValue = false);
            return false;
        }

        //skip giving away focus if they are shortcut keys for copy and paste
        if (target.id == "clipboard" && event.ctrlKey && (code == 67 || code == 86)) {
            return;
        }
        // skip giving away focus if focused element is a text input
        var el = document.activeElement;
        if (el && (el.tagName.toLowerCase() == 'input' && el.type == 'text')) {
            return;
        }
        if (el && (el.tagName.toLowerCase() == 'textarea' && el.type == 'textarea')) {
            return;
        }
        // skip giving away focus when doing ctrl+click
        if (controlAndMouseClick && code == 17) {
            return;
        }
        //give focus back to homeview window
        focusSelectedElement(null);

    }
    if (controlAndMouseClick && code == 13) {
        //reset row selection variables
        controlAndMouseClick = false;
        firstSelectedItem = null;

    }

}

/**
 *  Gives focus back to the selected element if element is passed,
 *  otherwise give focus to homeview
 */
function focusSelectedElement(inElement) {
    if(inElement==null){
        //focus home view
        var widget = zk.Widget.$('$homeView');
        widget.focus();
        return;
    }
    firstSelectedItem= zk.Widget.$("#"+inElement.id);
    firstSelectedItem.focus();
    controlAndMouseClick=true;
}


/**
 * Highlights menuitem on short cut key stroke
 *
 * @param inUuid the uuid of the selected zk component
 */
function hoverMenuItem(inUuid) {
    var clientMenuPopup = zk.$("#" + inUuid.id);
    clientMenuPopup._curIndex = 0;
    target = clientMenuPopup.getChildAt(clientMenuPopup._curIndex);
    if (target != null) {
        target.$class._addActive(target);
    }

}


/*
 * Copyright (c) 2012 Navis LLC. All Rights Reserved.
 * - a 2nd line is required by Checkstyle -
 */

var formName = "xmlrdtForm";
var pushLock = false;
var releaseLockHandler;
var pushLockExpiry = 5000;
var delay = 0;
var SUBMISSION_LOCK_EXPIRY = 60000;
var updateCount = 0;
window.submission = false;
window.status = "OK";
var undef;
window.errorCount = 0;

function init() {
    $("#xmlrdtForm").submit(function (e) {
        if (!window.submission) {
            window.submission = true;
            var action = $("input#action").attr("value");
            var activeFieldset = $("a#" + action).parents('fieldset');
            $("a#" + action + ",span.arrow", activeFieldset).each(function () {
                $(this).toggleClass("submitted", true);
            });
            disableInputFields(action);
            try {
                if (window.xhr !== null) {
                    window.xhr.onreadystatechange = function () {
                    }
                    window.xhr.abort();
                }
                return true;
            } catch (e) {
                window.submission = false;
                $("#submit").removeAttr("disabled");
                if (e instanceof Error) {
                    window.status = "No connection, please try again: " + e.name + ", message: " + e.message;
                } else {
                    window.status = "Unknown error";
                }
            }
        }
    });

    if ($("input#async").attr("value") === "true") {
        startPoll();
    }
}

function focusInputValue(id, labelText) {
    var inputfield = document.getElementById(id);
    if (inputfield.value === labelText) {
        inputfield.value = '';
        inputfield.className = "field";
    }
}

function doNothing() {
    window.event.cancelBubble = true;
    return false;
}

function submitJob(eqId, inputId) {
    window.event.cancelBubble = true;
    var inputfield = document.getElementById(inputId);
    inputfield.value = eqId;
    inputfield.className = "field";
    $("#xmlrdtForm").submit();
}

function submitCommand(inputId) {
    window.event.cancelBubble = true;
    if (inputId) {
        var inputfield = document.getElementById('action');
        inputfield.value = inputId;
        $("#xmlrdtForm").submit();
    }
}

function submitInputField(actionId) {
    if (window.event.keyCode === 13 || window.event.which === 13) {
        window.event.cancelBubble = true;
        var inputfield = document.getElementById('action');
        inputfield.value = actionId;
        $("#xmlrdtForm").submit();
    }
}

function stopEventPropagation() {
    window.event.cancelBubble = true;
}

function blurInputValue(id, labelText) {
    var inputfield = document.getElementById(id);
    if (inputfield.value === '') {
        inputfield.value = labelText;
        inputfield.className = "field labeled";
    }
}

function disableInputFields(actionId) {
    //inputFieldIds is the variable which holds all the input fields of type text in the current page.
    for (var i = 0; i < inputFieldIds.length; i++) {
        var inputField = document.getElementById(inputFieldIds[i]);
        var title = inputField.title;
        if ((title === actionId && inputField.className === 'field labeled') || title !== actionId) {
            inputField.disabled = "disabled";
        }
    }
}

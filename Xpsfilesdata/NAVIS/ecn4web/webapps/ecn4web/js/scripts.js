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
    $("input[type='text']").keypress(function () {
        delay = 5;
    });
    $("#xmlrdtForm").submit(function (e) {
        if (!window.submission) {
            window.submission = true;
            var action = $("input#action").attr("value");
            var activeFieldset = $("fieldset").has("[id='" + action + "']");

            $("a[id='" + action + "'],span.arrow", activeFieldset).each(function () {
                $(this).toggleClass("submitted", true);
            });
            $("a[id='" + action + "']").each(function () {
                $(this).toggleClass("submitted", true);
                $(this).children("span.accesskey").toggleClass("submitted", true);
            });
            $("fieldset").not(activeFieldset).find("input[name^='inputValue']").each(function () {
                $(this).attr("disabled", "disabled");
            });
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
    bindMouse();
    adjustFocus();
    adjustBlur();
    $("fieldset.button.enabled, a.button.enabled, div.button.enabled.message-fragment").click(function (event) {
        event.stopPropagation();
        var idValue = $(this).attr("id");
        if (idValue === undefined || idValue === null || idValue === '') {
            idValue = $("[id]", this).attr("id");
        }
        $("input#action").attr("value", idValue);
        $("#xmlrdtForm").submit();
    });

    $("fieldset.button.enabled input").keypress(function (event) {
        if (event.which === 13) {
            event.stopPropagation();
            var idValue = $("[id]", $(this).parents("fieldset")).attr("id");
            $("input#action").attr("value", idValue);
            $("#xmlrdtForm").submit();
        }
    });

    //accesskey highlight on input field to corresponding anchor
    $("input").focus(function (event) {
        var fieldset = $(this).parents("fieldset");
        var anchor = $(fieldset).find("a");
        $(anchor).toggleClass("selected", true);
        var accesskey_span = $(fieldset).find("span.accesskey");
        $(accesskey_span).toggleClass("selected", true);
    });

    $("input").focusout(function (event) {
        var fieldset = $(this).parents("fieldset");
        var anchor = $(fieldset).find("a");
        $(anchor).toggleClass("selected", false);
        var accesskey_span = $(fieldset).find("span.accesskey");
        $(accesskey_span).toggleClass("selected", false);
    });

    $("a").focus(function (event) {
        $(this).toggleClass("selected", true);
        var accesskey_span = $(this).find("span.accesskey");
        $(accesskey_span).toggleClass("selected", true);
    });

    $("a").focusout(function (event) {
        $(this).toggleClass("selected", false);
        var accesskey_span = $(this).find("span.accesskey");
        $(accesskey_span).toggleClass("selected", false);
    });

    $("input").bind("click", {}, false);
    $("input").bind("mousedown", function (event) {
        event.stopPropagation();
    });

    $("tr.button, tr.button.promotedJob").click(function (event) {
        event.stopPropagation();
        var inputValue = $(this).attr("id");
        var defaultActionButton = $("#" + $("#action").attr("value"), $(".commands"));
        var inputValueField = defaultActionButton.parents("fieldset").find("[name=inputValue]");
        inputValueField.attr("value", inputValue);
        $("#xmlrdtForm").submit();
    });
    hoverMouseOver();
    hoverMouseOut();

    alignFields();
    applyLabels();
    centerFooter();
    displayClock();
    if (window.beep) {
        playBeep();
    }
    adjustPaginationFont();
    setFocus();
    if ($("input#async").attr("value") === "true") {
        startPoll();
    }
}

function adjustPaginationFont() {
    var pagination = $('fieldset.pagination').length ? $('fieldset.pagination') : $('fieldset.pagination-no-border');

    if (pagination.length) {
        //adjusting pagination content to fit within the parent fieldset width, which is 500px
        var headerOriginalWidth = $('span.header').width();
        while ($('span.header').width() > (pagination.width() - 20)) {
            $('em').css('font-size', (parseInt($('em').css('font-size')) - 1) + "px");
            var paginationAnchor = $('span.header span.segmented a.button');
            if (paginationAnchor.length) {
                $('span.header span.segmented a.button').css('font-size',
                        (parseInt($('span.header span.segmented a.button').css('font-size')) - 1) + "px");
            }
            if (headerOriginalWidth <= $('span.header').width()) {
                return;
            }

        }
    }
}

function hoverMouseOver() {
    $("table.data tr.button").mouseover(function (event) {
        $("*", this).toggleClass("hover-button", true);
    });
}

function hoverMouseOut() {
    $("table.data tr.button").mouseout(function (event) {
        $("*", this).toggleClass("hover-button", false);
    });
}

function bindMouse() {
    $("fieldset.button.enabled, .segmented > a.button.enabled").bind(
            {
                "mousedown": function () {
                    if (!$(this).hasClass("active")) {
                        $(this).addClass("active");
                    }
                }, "mouseup": function () {
                if ($(this).hasClass("active")) {
                    $(this).removeClass("active");
                }
            }, "mouseout": function () {
                if ($(this).hasClass("active")) {
                    $(this).removeClass("active");
                }
            }
            });
}

function adjustFocus() {
    $("fieldset.button.enabled, a.button.enabled").focus(function (event) {
        adjustFocusStyle($(this));
    });
}

function adjustBlur() {
    $("fieldset.button.enabled, a.button.enabled").blur(function (event) {
        adjustBlurStyle($(this));
    });
}

function applyLabels() {
    $("label").each(function () {
        var correspondingInputValueField = $(this).parents("fieldset").find("input[id='" + $(this).attr("for") + "']");
        var labelText = $(this).find(".label").text();
        // set input label text and faded appearance class
        if (correspondingInputValueField.attr("value") === '') {
            correspondingInputValueField.attr("value", labelText);
            correspondingInputValueField.addClass("labeled");
        }
        // bind focus handler to remove label when user about to type
        correspondingInputValueField.focus(function () {
            if (correspondingInputValueField.attr("value") === labelText) {
                correspondingInputValueField.attr("value", '');
                correspondingInputValueField.toggleClass("labeled", false);
            }
            adjustFocusStyle(correspondingInputValueField);
        });
        // bind blur handler to restore label if user did not input any text
        correspondingInputValueField.blur(function () {
            if (correspondingInputValueField.attr("value") === '') {
                correspondingInputValueField.attr("value", labelText);
                correspondingInputValueField.toggleClass("labeled", true);
            }
            adjustBlurStyle(correspondingInputValueField);
        });
        // disable this field if still containing label text on form submission
        $("#xmlrdtForm").submit(function () {
            if (correspondingInputValueField.attr("value") === labelText) {
                correspondingInputValueField.attr("disabled", "disabled");
            }
        })
    });
}

function adjustFocusStyle(element) {
    // do nothing for standard browsers
}

function adjustBlurStyle(element) {
    // do nothing for standard browsers
}

function setFocus() {
    var iE6 = navigator.userAgent.search("MSIE 6.*");
    var iE7 = navigator.userAgent.search("MSIE 7.*");
    var iE8 = navigator.userAgent.search("MSIE 8.*");
    var actionField = $("#action");
    var defaultActionId = actionField.attr("value");
    if (defaultActionId !== undefined && defaultActionId !== null && defaultActionId !== '') {
        var defaultActionAnchor = $("#" + defaultActionId);
        var parentdFieldset = defaultActionAnchor.parents("fieldset");
        var inputValueField = parentdFieldset.find("input.field:first");
        if (inputValueField.length !== 0) {
            var strLength = inputValueField.val().length;
            inputValueField.focus();
            if( iE6 == -1 && iE7 == -1 && iE8 == -1) {
                if (strLength !== undefined && strLength > 0) {
                    inputValueField[0].setSelectionRange(strLength, strLength);
                }
            }
        } else {
            defaultActionAnchor.focus();
        }
    }
}

function addParams(formId, timestamp) {
    return '&formId=' + formId + '&timestamp=' + timestamp;
}

function resetSubmissionStatus() {
    window.submission = false;
}

function alignFields() {
    var values = [];
    $("fieldset.button:has(input.field)").each(function () {
        $("span[class='inline']", this).each(function (index) {
            values.push($(this).offset().left + $(this).width());
        });
    });

    $("fieldset.command-legend:has(input.field)").each(function () {
        $("span[class='inline']", this).each(function (index) {
            values.push($(this).offset().left + $(this).width());
        });
    });

    $("ul").each(function () {
        var maxLeftOffset = Math.max.apply(Math, values) + 10;
        $(this).offset({top: $(this).offset().top, left: maxLeftOffset});
        // Yes, this has to be set twice for IE6
        $(this).offset({top: $(this).offset().top, left: maxLeftOffset});
    });

    // align labels for non ie

}

function centerFooter() {
    var footer = $("div.footer");
    var relativeWidth = 500;
    //intial offset for every page element is 20 pixels on the left, add initialOffset to footer to align it on center of page exactly
    var initialOffset = 20;
    var newOffset = (relativeWidth / 2 - footer.width() / 2) + initialOffset;
    footer.offset({top: footer.offset().top, left: newOffset});
}

function submitCommand(inputId) {
    //Do nothing for non Win CE or IE 6 devices.
}

function displayClock() {
    $("#clock").html("CLOCK");

    var chrome = navigator.userAgent.search("Chrome");
    var edge = navigator.userAgent.search("Edge");
    var chrome = navigator.userAgent.search("Chrome");
    var fireFox = navigator.userAgent.search("Firefox");
    var iE6 = navigator.userAgent.search("MSIE 6.*");
    var iE7 = navigator.userAgent.search("MSIE 7.*");
    var iE8 = navigator.userAgent.search("MSIE 8.*");
    var iE10 = navigator.userAgent.search("MSIE 10.*");
    var iE11 = navigator.userAgent.match(/Trident.*rv[ :]*11\./);

    var currentTime = new Date(Date.parse(window.timestamp));

    //hack for IE 8 and IE 7, Date.parse only works when time stamp is separated by '/' instead of '-'  and 'T' is removed
    //so convert  2012-06-24T17:00:00-07:00 to 2012/06/24T17:00:00/07:00
    if (iE8 != -1 || iE7 != -1 || iE6 != -1) {
        currentTime = new Date(window.timestamp.replace(/\-/ig, '/').replace(/T/, ' ').split('.')[0]);
    }

    //time zone offset
    var timezone = currentTime.getTimezoneOffset() * 60000;
    var time = currentTime.getTime() + timezone;

    //If the browser is different from IE10, IE11, Firefox and Chrome then we need to add the time zone difference.
    if (fireFox == -1 && iE10 == -1 && iE8 == -1 && iE7 == -1 && iE6 == -1 && iE11 == null && chrome == -1 && edge == -1) {
        currentTime = new Date(time);
    }

    var currentHours = currentTime.getHours();
    var currentMinutes = currentTime.getMinutes();

    // Pad the minutes and seconds with leading zeros, if required
    currentMinutes = ( currentMinutes < 10 ? "0" : "" ) + currentMinutes;
    currentHours = ( currentHours < 10 ? "0" : "" ) + currentHours;

    // Compose the string for display
    var currentTimeString = currentHours + ":" + currentMinutes;

    $("#clock").html(currentTimeString);
}

function playBeep() {

    var beepSourceFile = window.beepFilePath;
    var isHTML5 = true;
    /**
     * For lower versions of IE9, isHTML5 value will be false. The beep sound will be played with help of bgsound tag.
     * For IE9 & higher ver of IE, google chrome & firefox, isHTML5 is true. The beep will be played with help of audio tag.
     */
    try {
        if (isHTML5) {
            $("<audio id='beepAudio'><source src=" + beepSourceFile + " type='audio/mpeg'></audio>").appendTo('body');
            $('#beepAudio')[0].play();
        }
    } catch (ex) {
        isHTML5 = false;
    }
    //alert('isHTML5:' + isHTML5);

    if (!isHTML5) {
        $("body").append("<bgsound src=" + beepSourceFile + " loop='1'></bgsound>");
    }
}
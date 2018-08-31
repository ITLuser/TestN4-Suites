/*
 * Copyright (c) 2012 Navis LLC. All Rights Reserved.
 * - a 2nd line is required by Checkstyle -
 */

window.xhr = null;
window.counter = 0;
window.NO_CONNECTION = "No Connection";

function ajaxSuccess(response) {
    window.errorCount = 0;
    var currentAlert = $("#alert").text();
    if (currentAlert === NO_CONNECTION) {
        var alertFragment = $("#alert");
        alertFragment.text("");
        alertFragment.css("display", "none");
        window.status = "OK";
        if (!window.submission) {
            $("#submit").removeAttr("disabled");
        }
    }

    if (!window.submission) {
        if (typeof(response) !== "unknown") { // IE returns this too early for asynchronous calls
            if (response === "true") {
                if (window.xhr !== null && window.xhr !== undef) {
                    window.xhr.onreadystatechange = function () {
                    }
                    window.xhr.abort();
                }
                update();
            } else {
                window.poller = setTimeout(startPoll, window.pollInterval);
            }
        }
    }
}

function update() {
    if (delay-- <= 0) {
        window.location =
                window.contextPath + "/servlet/receive?cheId=" + window.cheId + "&formId=" + $("input[name='formId']").attr("value") +
                        "&action=async" + "&mode=" + $("input[name='mode']").attr("value") + "&updateCount=" + updateCount++ + "&status=" +
                        encodeURI(window.status);
    } else {
        var alertFragment = $("#alert");
        alertFragment.text("Pending update...");
        alertFragment.css("display", "block");
        setTimeout("update()", 1000);
    }
}

function ajaxError(xhr, textStatus, errorThrown) {
    if (!(window.submission || xhr === null || textStatus === null || textStatus === "abort")) {
        $("#submit").attr("disabled", "true");
        if (++window.errorCount >= window.pollRetries) {
            var alertFragment = $("#alert");
            alertFragment.text(NO_CONNECTION);
            alertFragment.css("display", "block");
            window.status =
                    "Error: No Connection" + ", ajax-" + window.counter + ',' + new Date().toTimeString() + ", status: " + textStatus;
        }
        setTimeout(startPoll, window.pollInterval);
    }
}

function startPoll() {
    window.xhr = $.ajax({
        url: window.POLL_URL,
        timeout: window.pollTimeout,
        cache: false,
        success: ajaxSuccess,
        error: ajaxError,
        dataType: "text",
        data: {"timestamp": window.timestamp, "formId": window.formId, "cheId": window.cheId, "poller": ('ajax-' +
                window.counter++), "status": encodeURI(window.status)}
    });
}

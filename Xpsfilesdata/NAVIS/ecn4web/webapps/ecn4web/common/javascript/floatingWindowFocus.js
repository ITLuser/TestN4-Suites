/*
 * Copyright (c) 2017 Navis LLC. All Rights Reserved.
 *
 */

// Wait for the document to load before attempting to manipulate it
$(function () {

    // Attribute for being a focused window
    const focusedWindowAttribute = 'focused-window';

    // Add a click handler that if clicked on the following items, perform a z-window update
    $(document).on('click', '.z-window-overlapped, .z-window-modal, #zb_pageHome_tabView_Tabbox_1, .zebra-welcome', function (e) {
        // Get the top level floating window
        var zWindow = $(e.target).closest('.z-window-overlapped, .z-window-modal');
        updateZWindowFocus(zWindow);
    });
    var lastUpdated = new Date();

    // Go through and remove focus from all windows, then add it to the selected element
    function updateZWindowFocus(zWindow) {
        // This will prevent if a click on a tab that opens a new window as click events fire after mutation observer
        if (new Date() - lastUpdated > 50) {
            $('.z-window-overlapped, .z-window-modal').removeAttr(focusedWindowAttribute);;
            if (zWindow) {
                zWindow.attr(focusedWindowAttribute, true);
            }
            lastUpdated = new Date();
        }
    }

    // Dragging and changing the size doesn't actually fire a click, so when the ghost elements disappear,
    // give focus to topmost window
    function setTopmostAsFocused() {
        var element;
        var zWindows = $('.z-window-overlapped, .z-window-modal');
        for (var i = 0; i < zWindows.length; i++) {
            $(zWindows[i]).removeAttr(focusedWindowAttribute);

            if (!element) {
                element = $(zWindows[i]);
            } else if (parseInt(element.css("zIndex")) < parseInt($(zWindows[i]).css("zIndex"))) {
                element = $(zWindows[i]);
            }
        }

        $(element).attr(focusedWindowAttribute, true);
    }

    var target = document.querySelector('body');
    // Should then allow for each browser
    var MutationObserver = window.MutationObserver || window.WebKitMutationObserver || window.MozMutationObserver;

    // A mutation observer notes when changes are made to the dom to provide quick feedback
    // It is used here to determine if a floating window or modal has been added to the body
    // If so, it updates focus with the last added window.
    var focusWindowObserver = new MutationObserver(function (mutations) {
        mutations.forEach(function (mutation) {
            if (mutation.addedNodes && mutation.addedNodes.length > 0) {
                // element added to DOM
                var element;
                var hasClass = [].some.call(mutation.addedNodes, function (el) {
                    if (el.classList.contains('z-window-overlapped') || el.classList.contains('z-window-modal')) {
                        element = el;
                        return el;
                    }
                });
                if (hasClass) {
                    updateZWindowFocus($(element));
                }
            }
            // If ghost element is removed, set the top most
            if (mutation.removedNodes && mutation.removedNodes.length > 0) {
                // element added to DOM
                var element;
                var hasClass = [].some.call(mutation.removedNodes, function (el) {
                    if (el.classList.contains('z-window-move-ghost') || el.classList.contains('z-window-resize-faker')) {
                        element = el;
                        return el;
                    }
                });
                if (hasClass) {
                    setTopmostAsFocused();
                }
            }
        });
    });

    var config = {attributes: true, childList: true, characterData: true}
    focusWindowObserver.observe(target, config);

    // To put a MutationObserver to check when a tab is added, we must wait until the tabbox is added to the DOM
    // One the element is found, disconnect the current observer as the tabbox doesn't go away
    // https://stackoverflow.com/questions/38881301/observe-mutations-on-a-target-node-that-doesnt-exist-yet
    function waitForAddedNode(params) {
        new MutationObserver(function (mutations) {
            var el = document.getElementById(params.id);
            if (el) {
                this.disconnect();
                params.done(el);
            }
        }).observe(document, {
            subtree: !!params.recursive,
            childList: true,
        });
    }

    // Waits for the tabbox and then creates and observes on the element
    waitForAddedNode({
        id: 'zb_pageHome_tabView_Tabs_1-cave',
        recursive: true,
        done: function (el) {
            // Creates
            new MutationObserver(function (mutations) {
                mutations.forEach(function (mutation) {
                    if (mutation.addedNodes && mutation.addedNodes.length > 0) {
                        // element added to DOM
                        var element;
                        var hasClass = [].some.call(mutation.addedNodes, function (el) {
                            if (el.classList.contains('z-tab')) {
                                element = el;
                                return el;
                            }
                        });
                        if (hasClass) {
                            updateZWindowFocus($(element));
                        }
                    }
                });
            }).observe(document.getElementById('zb_pageHome_tabView_Tabs_1-cave'), {
                childList: true
            });
        }
    });
});

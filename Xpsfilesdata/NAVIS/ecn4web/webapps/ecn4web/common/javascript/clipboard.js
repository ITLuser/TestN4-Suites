/*
 * Copyright (c) 2016 Navis LLC. All Rights Reserved.
 *
 */
(function () {
    Clipboard = function () {
        return {
            copy: function (txt) {
                // there should be a DOM element with id 'clipboard'
                var copyElement = document.getElementById('clipboard');
                // .. if not, create it and append it to the DOM
                if (copyElement == null) {
                    copyElement = document.createElement('textarea');
                    copyElement.setAttribute('id','clipboard');
                    copyElement.setAttribute('style', 'position: absolute; left: 80px; top: -100px; height: 0; width: 0');
                    document.body.appendChild(copyElement);
                }
                // if txt is passed in, then set the value of the hidden clipboard
                if (txt != null) {
                    // have to set this all three ways to support different browsers
                    copyElement.setAttribute('value', txt);
                    copyElement.innerText = txt;
                    copyElement.value = txt;
                }

            }
        }
    };
})();

// create a global Clipboard object
var Clipboard = new Clipboard();

// listen for ctrl-c keydown events
document.addEventListener('keydown', function (event) {
    var code = event.keyCode || event.which;
    // make sure the event source is from the hidden clipboard, which should have just been focused and selected (see above)
    var ctrl = event.ctrlKey ? event.ctrlKey : event.metaKey?event.metaKey: ((code === 17) ? true : false);

    if(code == 67 && ctrl) {
        smartCopy(event);
        return;
    }

});

function smartCopy(event){

    //if the active element is text area we don't want to give focus to our hidden text element
    var el = document.activeElement;
    if (el && (el.tagName.toLowerCase() == 'input' && el.type == 'text')) {
        return;
    }
    // focus & select the contents of the hidden clipboard
    var copyElement = document.getElementById('clipboard');
    if(copyElement!=null){
        copyElement.focus();
        copyElement.select();
        // copy the clipboard using execCommand "copy"
        // https://developer.mozilla.org/en-US/docs/Web/API/Document/execCommand
        //console.log('@ Clipboard.copy - execCommand');
        document.execCommand('copy');
   }

}
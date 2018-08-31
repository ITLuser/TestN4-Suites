/************************************************************************
***** This script contains modifications to Mozilla prototypes that
***** allow Mozilla-based browsers to emulate proprietary IE
***** functionality. It also contains modification to functions that
***** are standard to later DOM browsers to emulate or patch behaviors
***** in the earlier versions.
*****
**************************************************************************
*****
***** This file depends upon the following JavaScript files:
*****   -none
*****
*************************************************************************/

/************************************************************************/
/**** Mozilla doesn't have a click() method for anchor tags.  The    ****/
/**** following code creates one.                                    ****/
/************************************************************************/
if(typeof HTMLAnchorElement!="undefined" && !HTMLAnchorElement.prototype.click)
{
    HTMLAnchorElement.prototype.click = function() { 
    var evt = this.ownerDocument.createEvent('MouseEvents'); 
    evt.initMouseEvent('click', true, true, this.ownerDocument.defaultView, 1, 0, 0, 0, 0, false, false, false, false, 0, null); 
    this.dispatchEvent(evt); 
  }
}

/************************************************************************/
/**** Mozilla will return a text node (if one exists) for            ****/
/**** srcElement.  The following will force Moz to always return an  ****/
/**** element.                                                       ****/
/************************************************************************/
if(typeof Event!="undefined")
{
  Event.prototype.__defineGetter__("srcElement", function () {
     try
     {
       var node = this.target;
       while (node.nodeType != 1) node = node.parentNode;
       return node;
     }
     catch(e){
       return;
     }
  });
}

/************************************************************************/
/**** Mozilla uses layerY and layerX instead of offsetX and offsetY. ****/
/**** The following reconciles the two.                              ****/
/************************************************************************/
if(typeof Event!="undefined")
{
  Event.prototype.__defineGetter__("offsetX", function () {
     return this.layerX;
  });
  
  Event.prototype.__defineGetter__("offsetY", function () {
     return this.layerY;
  });
}

/************************************************************************/
/**** Forces Mozilla to exhibit same behavior as IE when getting     ****/
/**** and setting innerText (i.e, it will ignore surrounding HTML    ****/
/**** objects and get/set only display text).                        ****/
/************************************************************************/


if (typeof HTMLAnchorElement!="undefined") { 
  HTMLElement.prototype.__defineSetter__("innerText", function (txt) { 
    var rng = document.createRange() 
    rng.selectNodeContents(this) 
    rng.deleteContents() 
    var newText = document.createTextNode(txt) 
    this.appendChild(newText) 
    return txt 
  });
  
  HTMLElement.prototype.__defineGetter__("innerText", function () { 
    var rng = document.createRange() 
    rng.selectNode(this) 
    return rng.toString() 
  });
}


/************************************************************************/
/****  These functions emulate the insertAdjacentHTML function for   ****/
/****  NS6/Mozilla.                                                  ****/
/****                                                                ****/
/************************************************************************/
/****                                                                ****/
/****  Parameters:                                                   ****/
/****    sWhere       - String that specifies where to insert the    ****/
/****                   HTML text, using one of the following        ****/
/****                   values:                                      ****/
/****    [beforeBegin]- Inserts sText immediately before the object. ****/
/****    [afterBegin] - Inserts sText after the start of the object  ****/
/****                   but before all other content in the object.  ****/
/****    [beforeEnd]  - Inserts sText immediately before the end of  ****/
/****                   the object but after all other content in    ****/
/****                   the object.                                  ****/
/****    [afterEnd]   - Inserts sText immediately after the end of   ****/
/****                   the object.                                  ****/
/****    sText        - String that specifies the HTML text to       ****/
/****                   insert. The string can be a combination of   ****/
/****                   text and HTML tags. This must be well-formed,****/
/****                   valid HTML or this method will fail.         ****/
/****                                                                ****/
/************************************************************************/

// insertAdjacentHTML(), insertAdjacentText() and insertAdjacentElement()
// for Netscape 6/Mozilla by Thor Larholm thor@jscript.dk
if(typeof HTMLElement!="undefined" && !HTMLElement.prototype.insertAdjacentElement)
{
    HTMLElement.prototype.insertAdjacentElement = function
    (where,parsedNode)
    {
        switch (where){
        case 'beforeBegin':
            this.parentNode.insertBefore(parsedNode,this)
            break;
        case 'afterBegin':
            this.insertBefore(parsedNode,this.firstChild);
            break;
        case 'beforeEnd':
            this.appendChild(parsedNode);
            break;
        case 'afterEnd':
            if (this.nextSibling)
              this.parentNode.insertBefore(parsedNode,this.nextSibling);
            else
              this.parentNode.appendChild(parsedNode);
            break;
        }
    }

    HTMLElement.prototype.insertAdjacentHTML = function
    (where,htmlStr)
    {
        var r = this.ownerDocument.createRange();
        r.setStartBefore(this);
        var parsedHTML = r.createContextualFragment(htmlStr);
        this.insertAdjacentElement(where,parsedHTML)
    }


    HTMLElement.prototype.insertAdjacentText = function
    (where,txtStr)
    {
        var parsedText = document.createTextNode(txtStr)
        this.insertAdjacentElement(where,parsedText)
    }
  }

/************************************************************************/
/**** Allows Mozilla to use cancelBubble=true.                       ****/
/************************************************************************/
if (typeof Event!="undefined")
{
  Event.prototype.__defineSetter__("cancelBubble", function (b) 
  {
    if (b) this.stopPropagation();
  });
}

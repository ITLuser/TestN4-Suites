/************************************************************************/
/**** This script contains utility functions called by many other    ****/
/**** functions throughout the application.                          ****/
/****                                                                ****/
/************************************************************************/
/****                                                                ****/
/**** This file depends upon the following JavaScript files:         ****/
/****   -browserSniff.js                                             ****/
/****   -ieEmulation.js                                              ****/
/****                                                                ****/
/************************************************************************/

/*************************************************************************
***** This (mostly) fixes the repaint issue in Netscape              *****
***** ... use when dynamically changing page content!                *****
***** TODO: improve this functionality.                              *****
*************************************************************************/

function mozResizeFix()
{
  if(is.moz)
  {
      // -4,-4 is magic number for mozilla as no function to tell window is maximized. 
      if(window.screenX==-4 && window.screenY==-4){  //Maximized window
          window.moveTo(-4,-4);
          window.resizeTo(screen.availWidth + (2 * 4), screen.availHeight + (2 * 4));
      }
      else{
          window.resizeBy(0,1);
          window.resizeBy(0,-1);
      }
  }
}


/************************************************************************/
/**** Locate objects in the DOM.                                     ****/
/************************************************************************/

function findObj(myId)
{
//look through the DOM to find a target object by ID
  var d,el;

  for (var i=0; i<parent.frames.length; i++)
  {
    d = parent.frames[i].document;
    if (document.getElementById(myId) != "undefined")
    {
        el = d.getElementById(myId);
        return el;
    }
  }
}

function getParentEl(srcObj, targetEl, excludeEl)
{
//crawl up the DOM to find and return the targetEl
  excludeEl = (excludeEl) ? excludeEl : 'BODY';

  while (srcObj.tagName != targetEl.toUpperCase() && srcObj.tagName != excludeEl.toUpperCase() && srcObj.tagName != 'BODY')
  {
    srcObj = srcObj.parentNode;
  }
  return srcObj;
}

function getParentElByAttribute(srcObj, att, excludeEl)
{
  //crawl up the DOM to find and return the first targetEl with an attribute [att]
  excludeEl = (excludeEl) ? excludeEl : 'BODY';

  while(!srcObj.getAttribute(att) && srcObj.tagName != excludeEl.toUpperCase() && srcObj.tagName != 'BODY')
  {
    srcObj = srcObj.parentNode
  }
  return srcObj;
}

function getEvent(e)
{
  if (is.ie)
  {
    e = window.event;
  }
  return e;
}

function getSrcEl(e)
{
//Returns the source element of event e. Since srcElement is proprietary IE, this function is made possible by ieEmulation.js
  var e = getEvent(e);
  var srcEl = null;
  srcEl = e.srcElement;
  return srcEl;
}


/************************************************************************/
/**** IE 5.x browsers do not support the getElementsByTagName        ****/
/**** functionality as expeced. This function initializes an override****/
/**** of the getElementsByTagName method.                            ****/
/****       THERE ARE PERFORMANCE ISSUES WITH THIS OVERRIDE!         ****/
/**** These will effect only IE5.x browsers.                         ****/
/************************************************************************/
function initGetElsByTagName()
{
  if((is.ie && !is.ie6up) && (document.all && !document.getElementsByTagName))
  {
  // If we got here, the HTML DOM is not supported.
  var collection = null;

  if(typeof document.all == "object")
    {
    collection = document.all;
    }

  if(collection == null)
    {
    return;
    }
  for(var i = 0; i < collection.length; i++)
    {
// document.all does not include the document object,
// you need to attach the method to the document seperately

    if( Boolean(collection[i].tagName) )
      {
// attach the method to the object
      try
        {
        collection[i].getElementsByTagName = ie_getElementsByTagName;
        }
        catch(e)
        {
        // do nothing
        }
      }
    }
  }
}

/************************************************************************/
/**** IE 5.x browsers do not support the getElementsByTagName        ****/
/**** functionality as expeced. This script emulates it as expected. ****/
/************************************************************************/
ie_getElementsByTagName = function(childNodeName)
{
// returns an array of objects with the childNodeName passed
// In the case of IE5.x, it will return all objects in the document with the childNodeName
if (childNodeName=='*')
  {
  return this.all
  }
  else
  {
  return this.all.tags(childNodeName)
  }
}


/************************************************************************/
/**** Determine X-Y coordinates of an event on a page.               ****/
/************************************************************************/

function getEventX(e)
{
//find X coordinate of event
  var e = getEvent(e);

  if (is.ie)
  {
    eX = e.clientX + document.body.scrollLeft;;
  }
  else
  {
    eX = e.pageX;
  }
   return eX;
}

function getEventY(e)
{
//find X coordinate of event
  var e = getEvent(e);

  if (is.ie)
  {
    eY = e.clientY + document.body.scrollTop;;
  }
  else
  {
    eY = e.pageY;
  }
   return eY;
}

/************************************************************************/
/**** Determine X-Y coordinates of an element on a page.             ****/
/************************************************************************/

function getElX(el)
{
//find absolute X offset relative to BODY
   oNode = el;
   var oCurrentNode = oNode;
   var elX = 0;
   while(oCurrentNode.tagName != "BODY")
   {
      elX += oCurrentNode.offsetLeft;
      oCurrentNode = oCurrentNode.offsetParent;
   }
   return elX;
}

function getElY(el)
{
//find absolute Y offset relative to BODY
   oNode = el;
   var oCurrentNode = oNode;
   var elY = 0;
   while(oCurrentNode.tagName != "BODY")
   {
      elY += oCurrentNode.offsetTop;
      oCurrentNode = oCurrentNode.offsetParent;
   }
   return elY;
}


/************************************************************************/
/**** Determine X-Y coordinates of the cursor on a page.             ****/
/************************************************************************/

function getCursorPos(p, event)
{
  if (is.ie) {
    p.x = window.event.clientX + document.body.scrollLeft; //+ document.documentElement.scrollLeft;
    p.y = window.event.clientY + document.body.scrollTop //+ document.documentElement.scrollTop;
  }
  else {
    p.x = event.clientX + window.scrollX;
    p.y = event.clientY + window.scrollY;
  }
}

/************************************************************************/
/**** Determine an element''s dimensions.                             ****/
/************************************************************************/
function Point()  //constructor
{
  this.x = 0;
  this.y = 0;
}

function Dimensions()  //constructor
{
  this.topleft     = new Point();
  this.bottomright = new Point();
  this.width       = new Point();
  this.height      = new Point();
}

function getElMetrics(el)
{
  var dim = new Dimensions();

  //top-left corner
  dim.topleft.x     = getElX(el);
  dim.topleft.y     = getElY(el);
  //width and height
  dim.width         = el.offsetWidth;
  dim.height        = el.offsetHeight;
  //bottom-right corner
  dim.bottomright.x = dim.topleft.x + dim.width;
  dim.bottomright.y = dim.topleft.y + dim.height;

  return dim;
}

/************************************************************************/
/**** ClassName manipulation.                                        ****/
/************************************************************************/
function classNameExists(obj,cName)
{
  var exists = false;
  var classNameArray = obj.className.split(' ');

  for(var i=0; i<classNameArray.length; i++)
  {
    if (classNameArray[i] == cName)
    {
      exists = true;
      break;
    }
  }
  return exists;
}

function addClassName(obj,cName)
{
  //if object already has a given classname, don''t add it again.
  var exists = classNameExists(obj, cName);

  if(!exists)
  {
    obj.className += (obj.className=='') ? cName : ' ' + cName;
  }
}

function removeClassName(obj,cName)
{
  //if object doesn't have a given classname, don't attempt to remove it.
  var exists = classNameExists(obj, cName);
  if (!exists) return;

  if(obj.className.indexOf(' ' + cName) > -1)//if there is a space before classname
  {
    obj.className = obj.className.replace(eval('/ ' + cName + '/g'),'');
  }
  else
  {
    obj.className = obj.className.replace(eval('/' + cName + '/g'),'');
  }
}

function replaceClassName(obj,oCname,nCname)
{
  removeClassName(obj,oCname);
  addClassName(obj,nCname);
}


/************************************************************************/
/**** Miscellaneous                                                  ****/
/************************************************************************/

function cancelEventPropagation(e)
{
  if(is.ie) //IE
  {
    e.cancelBubble = true;
    e.cancel;
    e.returnValue = false;
  }
  else //DOM2-compliant
  {
    e.stopPropagation();
    e.preventDefault();
  }
}

function makeShadow(id)
{
  if (document.getElementById(id))
  {
    return document.getElementById(id);  //if the shadow already exists, don't create another
  }
  var oNewNode = document.createElement('DIV');

  //TODO: can the appendChild method be moved to the end?
  document.body.appendChild(oNewNode);
  oNewNode.setAttribute('id',id);
  oNewNode.style.position = "absolute";
  oNewNode.style.left = "0px";
  oNewNode.style.top = "0px";
  oNewNode.style.width = "0px";
  oNewNode.style.height = "0px";
  oNewNode.className = "shadow";

  return oNewNode;
}

function makeDiv(id,className)
{
//TODO replace makeShadow() method with this one
  if (document.getElementById(id))
  {
    return document.getElementById(id); //if the div already exists, don't create another
  }

  var oNewNode = document.createElement('DIV');

  //TODO: can the appendChild method be moved to the end?  This might prevent some of the NS screwyness with document.height
  document.body.appendChild(oNewNode);
  oNewNode.setAttribute('id',id);
  oNewNode.className = className;
  oNewNode.style.position = "absolute";
  oNewNode.style.left = 0;
  oNewNode.style.top = 0;
  oNewNode.style.width = 0;
  oNewNode.style.height = 0;

  return oNewNode;
}


////////////////////////////////////////////
// Function: show
//
// Purpose:
// sets visibility of a given object to visible
//
// Arguments:
//    id      = id of the object to show.
//
////////////////////////////////////////////
function show(id) {
  document.getElementById(id).style.visibility = "visible";
}

function selectText(obj,startRange,endRange)
{
  //used to select text ranges
  if (typeof obj.selectionStart != 'undefined') //Mozilla
  {
    obj.setSelectionRange(startRange, endRange);
  }
  else if(obj.createTextRange) //IE on PC
  {
    var oRange = obj.createTextRange();
    oRange.moveStart('character', startRange);
    oRange.moveEnd('character', endRange);
    oRange.select();
  }
}

////////////////////////////////////////////
// Function: hide
//
// Purpose:
// sets visibility of a given object to hidden
//
// Arguments:
//    id      = id of the object to hide.
//
////////////////////////////////////////////
function hide(id) {
  document.getElementById(id).style.visibility = "hidden";
}

////////////////////////////////////////////
// Function: getBTime
//
// Purpose:
// Returns a timestamp.
//
// Arguments: None
//
////////////////////////////////////////////
function getBTime()
{
  var d = new Date();
  return d.getTime();
}

////////////////////////////////////////////
// Function: go
//
// Purpose:
//  replaces the location of the window w/ a
//  specified url
//
//  NOTE:
//    If you are attempting to pass in url
//    encoded hrefs to this function, the way
//    you deal w/ it depends largely on the
//    type of element you are adding it to. if
//    you are using it in an href w/ a
//    'javascript:' call, it will unescape the
//    url encoding. otherwise you need to use
//    the unescape() function.
//
//
// Arguments: url
//
////////////////////////////////////////////
function go(url,trgt)
{
  if(trgt && trgt != 'null')
  {
  document.getElementById(trgt).src = url;
  }
  else if(is.ie){
    window.location.href(url);
  }
  else
    {
    window.location = url;
    }
}

/************************************************************************/
/**** Query string and URL manipulation.                             ****/
/************************************************************************/

function createRequestObject()
{
  //This function parses the entire query string and generates an object for each name/value pair
  QueryData = new Object();

    // The Object ("Array") where our data will be stored.

  var separator = ',';
    // The token used to separate data from multi-select inputs

  var query = '' + this.location;
  var qu = query
    // Get the current URL so we can parse out the data.
    // Adding a null-string '' forces an implicit type cast
    // from property to string, for NS2 compatibility.

  query = query.substring((query.indexOf('?')) + 1);
    // Keep everything after the question mark '?'.

  if (query.length < 1)
  {
    // Perhaps we got some bad data?
    return false;
  }

  var keypairs = new Object();
  var numKP = 1;
    // Local vars used to store and keep track of name/value pairs
    // as we parse them back into a usable form.

  while (query.indexOf('&') > -1)
  {
    keypairs[numKP] = query.substring(0,query.indexOf('&'));
    query = query.substring((query.indexOf('&')) + 1);
    numKP++;
      // Split the query string at each '&', storing the left-hand side
      // of the split in a new keypairs[] holder, and chopping the query
      // so that it gets the value of the right-hand string.
  }

  keypairs[numKP] = query;
    // Store what's left in the query string as the final keypairs[] data.

  for (i in keypairs)
  {
    keyName = keypairs[i].substring(0,keypairs[i].indexOf('='));
      // Left of '=' is name.
    keyValue = keypairs[i].substring((keypairs[i].indexOf('=')) + 1);
      // Right of '=' is value.
    while (keyValue.indexOf('+') > -1)
    {
      keyValue = keyValue.substring(0,keyValue.indexOf('+')) + ' ' + keyValue.substring(keyValue.indexOf('+') + 1);
        // Replace each '+' in data string with a space.
    }

    keyValue = unescape(keyValue);
      // Unescape non-alphanumerics

    if (QueryData[keyName])
    {
      QueryData[keyName] = QueryData[keyName] + separator + keyValue;
        // Object already exists, it is probably a multi-select input,
        // and we need to generate a separator-delimited string
        // by appending to what we already have stored.
    }
    else
    {
      QueryData[keyName] = keyValue;
        // Normal case: name gets value.
    }
    QueryDataArray[QueryDataArray.length] = QueryData[keyName];
  }
  return QueryData;
}

// This is the array/object containing the GET data.
// Retrieve information with 'QueryData [ key ] = value'
var QueryDataArray = new Array();
var QueryData = createRequestObject();

function getConj()
{
  if (document.location.search.length>0)
  {
    return '&';
  }
  else
  {
    return '?';
  }
}

/*
Add the given parameter and value to a Url.
Added Nov 16, 2003 NDP
This function must deal with looking for existing parameter and
replacing it if necessary. Otherwise, it needs to add the parameter
on the end of the Url, either with an & or a ?.

Test cases, assuming parameter name is "param":
document.write('Param should be 8 in all of the following examples.');
document.write('<br />');
document.write(addParamToUrl('/test.jsp', 'param', '8'));
document.write('<br />');
document.write(addParamToUrl('/test.jsp?param=4', 'param', '8'));
document.write('<br />');
document.write(addParamToUrl('/test.jsp?nonsense=4&param=4', 'param', '8'));
document.write('<br />');
document.write(addParamToUrl('/test.jsp?param=4&nonsense=4', 'param', '8'));
document.write('<br />');
document.write(addParamToUrl('/test.jsp?nonsense=4&param=4&nonsense=4', 'param', '8'));
document.write('<br />');
document.write(addParamToUrl('/test.jsp?nonsense=4', 'param', '8'));
document.write('<br />');
*/
function addParamToUrl(url, param, value)
{
  var paramPos = url.indexOf(param+'=');
  if (paramPos < 0) {
  //param doesn't exist
      if (url.indexOf('?')>0){
          conj = '&';
        }
        else{
          conj = '?';
        }
        url = url + conj + param + '=' + value;
  } else {
    xistingValPos = paramPos + param.length + 1;
    startStr = url.substring(0, xistingValPos);
    endStr = url.substring(xistingValPos);
    nextParamPos = endStr.indexOf('&');
    if (nextParamPos >= 0) {
        endStr = endStr.substring(nextParamPos);
    } else {
        endStr = "";
    }
    url = startStr + value + endStr;
  }
  return url;
}

function goWithParam(url, param, value)
{
  url = addParamToUrl(url, param, value);
  go(url);
}

function getFileName(pth)
{
  //Use string methods to find the filename within the given path
   var fileName = pth.substring(pth.lastIndexOf('/') + 1,pth.length);
   return fileName;
}


/************************************************************************
***** moveFocus
***** args:
***** e == the event
***** leftEl == the element to move to on left arrow (can be the string null)
***** rightEl == the element to move to on right arrow (can be the string null)
************************************************************************/
function moveFocus(e,leftEl,rightEl)
{
  evt = getEvent(e)
  var charCode = (navigator.appName == "Netscape") ? evt.which : evt.keyCode;
  if(charCode == '37' && leftEl != 'null')
  {
    document.getElementById(leftEl).focus();
  }
  else if(charCode == '39' && rightEl != 'null')
  {
    document.getElementById(rightEl).focus();
  }
}

/************************************************************************/
/**** The following add cross-browser event binding.                 ****/
/************************************************************************/

function addEvent(el,strEvent,eventHandler)
{
  if (is.ie)
  {
    el.attachEvent('on' + strEvent,eventHandler);
  }
  else
  {
    el.addEventListener(strEvent,eventHandler,true);
  }
}

function removeEvent(el,strEvent,eventHandler)
{
  if (is.ie)
  {
    el.detachEvent('on' + strEvent,eventHandler);
  }
  else
  {
    el.removeEventListener(strEvent,eventHandler,true);
  }
}

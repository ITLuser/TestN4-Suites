/*
*
* Copyright Navis Corporation 2003
* All Rights Reserved
*
* Confidential Information of Navis Corporation
* Unauthorized use is strictly prohibited
*
* This work contains valuable confidential proprietary trade secret
* information of Navis Corporation and is protected by specific
* agreements and federal copyright. This work or any part thereof
* may not be disclosed, transmitted, copied, or reproduced in any
* form or medium without prior written authorization from Navis
* Corporation.
*/

/************************************************************************/
/**** Used by form inputs to autocomplete data entry by loading      ****/
/**** strings from an associated list.  This object replaces the     ****/
/**** standard <select> object.                                      ****/
/****                                                                ****/
/************************************************************************/
/****                                                                ****/
/**** This file depends upon the following JavaScript files:         ****/
/****   -common.js                                                   ****/
/****   -browserSniff.js                                             ****/
/****   -ieEmulation.js                                              ****/
/****   -imageSwap.js                                                ****/
/****   -getOptions.js                                               ****/
/****                                                                ****/
/************************************************************************/

/**** Example with <select> object:
<input name="text" type="text" class="txtInput lovInput" id="exampleLov" value="- Select One -" autocomplete="off"/>
<input type="hidden" name="value(exampleLov)" id="exampleLov_hidden" value="1">
<select name="lovSelect" id="exampleLov_select">
<option value="">- Select One -</option>
<option value="1">item 1</option>
<option value="2">item 2</option>
</select>
*/

/* EXAMPLE OF VERIFY ME
var tested = false
verifyState = 'Y';
declineState = 'N';

var verifyObj = null;

function verifyChange(obj)
{
verifyObj = obj
if(obj.value == verifyState && !tested)
{

confirmDialog('<bean:message key="message.confirmTitle" />','<bean:message key="message.requiresAttention" />', '<bean:message key="message.unloadDurationConfirmation" />', '#', "okFunction()", 1, "cancelFunction()")

tested = true;
}
else
{
tested = false;
}
}

function cancelFunction()
{
verifyObj.value = declineState
}

function okFunction()
{
// do nothing
}
*/

/**** Example with array object:
<script type="text/javascript">
var optArrayExampleLov = [
['','- Select One -'],['1','item 1'],['2','item 2'],['3','item 3']];
LinkedOptions['optArrayExampleLov'] = new LinkedSet('optArrayExampleLov');
LinkedOptions['optArrayExampleLov'].pOpts = optArrayExampleLov;
</script>
<input name="text" type="text" class="txtInput lovInput" id="exampleLov" value="- Select One -" autocomplete="off" lovOptionObject="optArrayExampleLov"/>
<input type="hidden" name="value(exampleLov)" id="exampleLov_hidden" value="">
*/

/************************************************************************/
/**** GLOBAL VARIABLES                                               ****/
/************************************************************************/

//parameters
var defaultLovMaxSize       = 10;
var defaultLovValidate      = false;
var restrictLovWidth        = false;   //restrict the width of the LOV to the width of the srcInput, no matter how wide its content
var defaultLovValidate      = true;    //false allows users to enter values not in the list.  true forces users to enter only items from the list.
var defaultLovFilterList    = true;    //true will filter out items in the LOV when they don't match typed value.
var defaultLovShadowNudgeX  = 3;
var defaultLovShadowNudgeY  = 3;
var defaultLovShowHiddenVal = false    //true will display the submit value in the text input in lieu of the text value
var useLovShadow = ((is.win && is.ie6up) || is.moz5up) ? true : false;  //these browsers can use alpha

//objects
var Lovs           = new Object();
var LovTxtInputs   = new Object();
var LovsArray      = new Array();
var LovTxtInputsArray = new Array();

//images
var defaultLovButtonSrc = commonImgRoot + 'buttons/inputWidgets/lovDrop.gif';
var defaultLovButtonActiveSrc = commonImgRoot + 'buttons/inputWidgets/lovDrop_down.gif';
var defaultLovButtonDisabledSrc = commonImgRoot + 'buttons/inputWidgets/lovDrop_disabled.gif';

//Array to hold registered onChange methods
var onChangeMethods = new Array();
var onClickMethods = new Array();

var LovTimer = "";


/************************************************************************/
/**** CONSTRUCTORS                                                   ****/
/************************************************************************/
function Lov(id) //constructor
{
  //TODO: add support for filterlist;
  //TODO: when showHiddenVal==true, replace the typed value with the hidden value
  //properties
  this.id = id;
  this.selectObj        = 'undefined';
  this.inputObj         = 'undefined';
  this.hiddenObj        = 'undefined';
  this.shadow           = new LovShadow(this.id);
  this.txt              = new LovText(this.id);
  this.isVisible        = false;
  this.hasDependent     = false;
  this.maxSize          = null;
  this.ValArray         = new Array();
  this.TxtArray         = new Array();
  this.validateMe       = false;
  this.showHiddenVal    = false;
  this.multiValue	    = false;

  //methods
  this.open               = lovOpen;
  this.close              = lovClose;
  this.unselectOptions    = lovUnselectOptions;
  this.validate           = lovValidate;
  this.updateInput        = lovUpdateInput;
  this.toggle             = lovToggle;
  this.cancelAutoComplete = lovCancelAutoComplete;
  this.upArrow            = lovUpArrow;
  this.downArrow          = lovDownArrow;
  this.autoComplete       = lovAutoComplete;
  this.findMatchingIndex  = lovFindMatchingIndex;
  this.updateHidden       = lovUpdateHidden;
  this.setLovOptionsParent= lovSetOptionsParent;
  this.callOnChangeMethod = lovCallOnChangeMethod;
  this.callOnClickMethod  = lovCallOnClickMethod;

}

function LovShadow(id) //constructor
{
  this.obj    = makeShadow(id + "Shadow");
  this.nudgeX = 0;
  this.nudgeY = 0;

  //methods
  this.setPosition = lovSetShadowPosition;
  this.show     = lovShowShadow;
  this.hide     = lovHideShadow;
}

function LovText(id) //constructor
{
  //this.defaultClassName = '';
  this.prevTxt = '';
  this.typedTxt = '';
}

/************************************************************************/
/**** DOM EVENTS                                                     ****/
/************************************************************************/
/*function lovFocus(e)
{
  //alert('got focus')
  var obj = getSrcEl(e);
  var oLov = getLov(obj.id);
}*/

function lovSelectOnChange(e)
{
  var evt = getEvent(e);

  var obj = getSrcEl(evt);

  var oLov = getLov(obj.getAttribute('lov'));

  if(oLov.inputObj.disabled || oLov.inputObj.readOnly) return;

  if(oLov.hasDependent && window.reSetOptions)
  {
    reSetOptions(obj);
  }

  oLov.callOnChangeMethod();
  oLov.updateInput();

    if(is.ie7up)
    {
      var LovTimerOther = setTimeout('getLov(\'' + oLov.inputObj.id + '\').close(); invalidMethod();', 200); //brief pause that lets user click on LOV before closing in ie7
    }
    else{
     oLov.close();
    }
}

function lovSelectOnScroll(e)
{
    var evt = getEvent(e);
    if (LovTimer) {
        clearTimeout(LovTimer);
    }

    LovTimer = "";

    var obj = getSrcEl(evt);
    var oLov = getLov(obj.getAttribute('lov'));
    oLov.inputObj.focus();
}

function lovSelectOnFocus(e)
{
    var evt = getEvent(e);

    if (LovTimer) {
        clearTimeout(LovTimer);
    }

    LovTimer = "";

    var obj = getSrcEl(evt);
    var oLov = getLov(obj.getAttribute('lov'));

    oLov.inputObj.focus();

    cancelEventPropagation(evt);

    return false;
}


/*function lovSelectOnClick(e)
{
alert('lovSelectOnClick');
  var obj = getSrcEl(e);
  var oLov = getLov(obj.getAttribute('lov'));

  oLov.close();
  oLov.validate();
}*/

function lovInputOnClick(e)
{
  var evt = getEvent(e);
  var obj = getSrcEl(evt);

  //trigger autocomplete if the label object was clicked in lieu of the actual input
  var oLov = (obj.tagName == "LABEL") ? getLov(obj.getAttribute('for')) : getLov(obj.id);

  if (oLov.inputObj.disabled || oLov.inputObj.readOnly) { return; }

  if (!oLov.callOnClickMethod()) { return; }

  oLov.toggle();
}

/*function lovButtonOnClick(e)
{
  var imgObj = getSrcEl(e);
  var obj = getParentEl(imgObj,'A','BODY');
  var oLov = getLov(obj.getAttribute('lov'));

  oLov.toggle();
}*/

function lovInputOnBlur(e)
{
  var evt = getEvent(e);
  var obj = getSrcEl(evt);
  var oLov = getLov(obj.id);

  if (oLov.inputObj.disabled || oLov.inputObj.readOnly) { return; }

  oLov.validate();
  oLov.updateHidden();

  if(!is.ie || is.ie7up)
    {
      //clear specific selection, if any
      // selectText(oLov.inputObj,oLov.inputObj.value.length,oLov.inputObj.value.length)
      //Do not close the lov when for scrollable lists because Mozilla throws the onBlur event when
      //the scrollbar is clicked.
//      if (oLov.selectObj.options.length > oLov.maxSize){ // a scrollable list
        LovTimer = setTimeout('getLov(\'' + obj.id + '\').close();', 200); //brief pause that lets user click on LOV before closing in Moz
//      }
//      else {
//        LovTimer = setTimeout('getLov(\'' + obj.id + '\').close();', 200); //brief pause that lets user click on LOV before closing in Moz
//      }
    }
    else{
      oLov.close();
    }
}

function lovInputOnKeyPress(e)
//this function is used to intercept enter key, esc, and arrow keys
{
  var evt = getEvent(e);
  var obj = getSrcEl(evt);
  var oLov = getLov(obj.id);

  if(oLov.inputObj.disabled || oLov.inputObj.readOnly) { return; }

  //intercept and block the return/enter key
  if(evt.keyCode == 13 && oLov.isVisible)
  {
    oLov.cancelAutoComplete();
    cancelEventPropagation(evt);
    //this.inputObj.select();
  }
  else if(evt.keyCode == 27 && oLov.isVisible)
  {
    //intercept and block the esc key
    if (!oLov.validateMe) {
      oLov.inputObj.value = oLov.txt.typedTxt;
    }
    oLov.cancelAutoComplete();
    cancelEventPropagation(evt);
  }
  //Arrow keys are handled in onKeyDown, so cancel them here.
  if (evt.keyCode == 38 || evt.keyCode ==40) //arrow up/down
  {
    cancelEventPropagation(evt);
  }
}

function lovInputOnKeyDown(e)
{
  var evt = getEvent(e);
  var obj = getSrcEl(evt);
  var oLov = getLov(obj.id);

  if(oLov.inputObj.disabled || oLov.inputObj.readOnly) return;

  if (evt.keyCode == 38) //arrow up
  {
    oLov.upArrow();
    cancelEventPropagation(evt);
    return;
  }
  else if (evt.keyCode == 40) //arrow down
  {
    oLov.downArrow();
    cancelEventPropagation(evt);
    return;
  }
}

function lovInputOnKeyUp(e)
{
  var evt = getEvent(e);
  var obj = getSrcEl(evt);
  var oLov = getLov(obj.id);

  if(oLov.inputObj.disabled || oLov.inputObj.readOnly) return;

  oLov.autoComplete(evt);
}

function lovDocumentClick(e)
{
  //Hide all LOVs on a page click unless the lovToggle button was the object that generated the event.
  var evt = getEvent(e);
  var srcObj,isLov;

  srcObj = getSrcEl(evt);
  //TODO: deprecate the following line:
  srcObj = (srcObj.tagName == "IMG") ? getParentEl(srcObj, "A", "BODY") : srcObj;
  //isLov = (srcObj.className.indexOf('lovInput')>-1) ? true : false;
  isLov = (classNameExists(srcObj,'lovInput') || classNameExists(srcObj,'lovInput_active')) ? true : false;

  for (var i=0; i<LovsArray.length; i++)
  {
    //close all LOVs except the one that generated the event.
    if ((isLov && srcObj.id != LovsArray[i].id) || !isLov)
    //TODO: if the lov were a popup object, and only one popup object can be active at a time, then this doesn't need to loop; just close the active popup
    {
      LovsArray[i].close();
      LovsArray[i].validate();
    }
  }
}

/************************************************************************/
/**** FUNCTIONS                                                      ****/
/************************************************************************/
function initLov(id)
{
  if (!document.getElementById(id))
  {
    alert('Cannot initialize Autocomplete Widget.');
    return;
  }

  Lovs[id] = new Lov(id);
  LovsArray[LovsArray.length] = Lovs[id];
  var oLov = Lovs[id];

  oLov.inputObj  = document.getElementById(id);

  //create new objects
  //create select object
  if (!document.getElementById(id + "_select"))
  {
    var oSelect = document.createElement('SELECT');
    oSelect.id = id + "_select";
    getParentEl(oLov.inputObj,'FORM').appendChild(oSelect);
    oSelect.setAttribute('lov',id);
    oSelect.className = "lov";
  }
  oLov.selectObj = document.getElementById(id + "_select");

  //create hidden input
  if(!document.getElementById(id+"_hidden"))
  {
    var oHidden = document.createElement('INPUT');
    oHidden.id = id + "_hidden";
    oHidden.type = "hidden";
    getParentEl(oLov.inputObj,'FORM').appendChild(oHidden);
  }

  oLov.hiddenObj = document.getElementById(id+"_hidden");

  if(classNameExists(oLov.inputObj,'multiValue'))
  {
  oLov.multiValue = true;
  }
  //determine if the LOV is dependent, and initialize as necessary
  if(oLov.inputObj.getAttribute('dependent'))
  {
    oLov.setLovOptionsParent();
    oLov.hasDependent = true;
    dependentLovId = oLov.inputObj.getAttribute('dependent');
    //set dependent LOV properties
    document.getElementById(dependentLovId).disabled = true;
    document.getElementById(dependentLovId + '_input').disabled = true;

    // set dependent LOV button src
    //document.getElementById(dependentLovId + '_dropButton').firstChild.src = defaultLovButtonDisabledSrc;
  }
  else if(oLov.inputObj.getAttribute('lovOptionObject'))
  {
  oLov.setLovOptionsParent();
  }
  //end check dependencies

  for(i=0; i<oLov.selectObj.options.length; i++)
  {
    oLov.ValArray[i] = oLov.selectObj.options[i].value;
    oLov.TxtArray[i] = oLov.selectObj.options[i].text;
  }
  //oLov.buttonObj        = document.getElementById(oButtonId);
  //oLov.buttonObjImg     = oLov.buttonObj.firstChild; //should be the <a> link's child image.
  //oLov.buttonObjImgSrc  = oLov.buttonObjImg.src;
  //oLov.buttonObjImgSrcA = defaultLovButtonActiveSrc;

  if (!oLov.selectObj || !oLov.inputObj || ! oLov.hiddenObj)
  //if (!oLov.selectObj || !oLov.inputObj || !oLov.buttonObj || ! oLov.hiddenObj)
  {
    alert('Cannot initialize Autocomplete Widget.');
    return;
  }

  if(oLov.inputObj.disabled)
  {
    replaceClassName(oLov.inputObj,'lovInput','lovInput_active');
  //oLov.buttonObjImgSrc = oImg_d.src;
  }
  else
  {
     replaceClassName(oLov.inputObj,'lovInput_active','lovInput');
  //oLov.buttonObjImgSrc = oImg_i.src;
  }
  //  initialize the classname as well so that it will lose the error class.
  removeClassName(oLov.inputObj,'inputError');

  //TODO: when the LOV is initialize at onload, then set the input height to match the button height.
  //oLov.inputObj.style.height = oLov.buttonObjImg.offsetHeight + "px";
  oLov.validateMe = (oLov.inputObj.getAttribute('lovValidate')) ? oLov.inputObj.getAttribute('lovValidate') : defaultLovValidate;

  oLov.maxSize = (oLov.inputObj.getAttribute('lovMaxSize')) ? oLov.inputObj.getAttribute('lovMaxSize') : defaultLovMaxSize;
  oLov.shadow.nudgeX = (oLov.inputObj.getAttribute('lovShadowNudgeX')) ? oLov.inputObj.getAttribute('lovShadowNudgeX') : defaultLovShadowNudgeX;
  oLov.shadow.nudgeY = (oLov.inputObj.getAttribute('lovShadowNudgeY')) ? oLov.inputObj.getAttribute('lovShadowNudgeY') : defaultLovShadowNudgeY;
  //oLov.txt.defaultClassName = oLov.inputObj.className;
  oLov.selectObj.size = (oLov.selectObj.options.length > oLov.maxSize) ? oLov.maxSize : oLov.selectObj.options.length;
  oLov.showHiddenVal = (oLov.inputObj.getAttribute('lovShowHiddenVal')) ? oLov.inputObj.getAttribute('lovShowHiddenVal') : defaultLovShowHiddenVal;

  //turn off browser's default autocomplate feature
  oLov.autocomplete = "off";

  //event bindings
  oLov.selectObj.onchange = lovSelectOnChange;
//  oLov.selectObj.onscroll = lovSelectOnScroll;
//  oLov.selectObj.onblur  = lovInputOnBlur;
  oLov.selectObj.onfocus = lovSelectOnFocus;
  oLov.selectObj.setAttribute('lov',id)
}

//Implement call to registered onChangeMethod, if any.
function lovCallOnChangeMethod()
{
    //Check to see first if the value has actually changed since this event fires no matter what.
    if((this.hiddenObj.value) != (this.selectObj.options[this.selectObj.selectedIndex].value)){
        //Sends the id of the generating field and the key field (not name) of the lov.
        var methodToCall = onChangeMethods[this.id];
        if(methodToCall){
            eval(methodToCall+"('"+this.id+"','"+this.selectObj.options[this.selectObj.selectedIndex].value+"')");
        }

    }

}

//  To set the change event depending on browser
//  hidden: element whose value is cleared
function setClearHiddenValueEvent ( elem, hiddenId )
{
    var f = new Function ( "hiddenId", eval("document.getElementById(hiddenId).value = '';") );
    var prop;

    if (is.ie5up) {
        prop = "onpropertychange";
    } else {
        prop = "onchange";
    }
    if (elem.attacEvent) {
            elem.attachEvent(prop, f);
    } else {
        elem[prop] =f;
    }
}

//Implement call to registered onClickMethod, if any.  The registered onClick method must return true
//for the LOV to continue running or false to cancel the LOV click.
function lovCallOnClickMethod()
{
       var methodToCall = onClickMethods[this.id];
       if(methodToCall){
            return eval(methodToCall+"()");
        }

    return true;
}


function getLov(id)
{
  if (!Lovs[id])
  {
    initLov(id);
  }

  return Lovs[id];
}

function lovUpdateInput()
{
  myTextValue = this.selectObj.options[this.selectObj.selectedIndex].text;

  if(this.multiValue == true)
  {
  	  if(this.inputObj.value.length >= 1)
	  {
          if ( this.inputObj.value == '*')
          {
          	this.inputObj.value = '';
          }
		  else if (this.inputObj.value.charAt(this.inputObj.value.length - 1) == ' ')
		  {
			if (this.inputObj.value.charAt(this.inputObj.value.length - 2) != ',')
			{
			var newValue = this.inputObj.value.substring(0,(this.inputObj.value.length - 1))
			this.inputObj.value = newValue += ', '
			}
		  }
		  else if (this.inputObj.value.charAt(this.inputObj.value.length - 2) == ',')
		  {
			this.inputObj.value += ' '
		  }
		  else
		  {
			this.inputObj.value += ', '
		  }
	  }

  myTextValue = this.inputObj.value + myTextValue;

  myTextValue = myTextValue + ', ';
  }

  this.inputObj.value = myTextValue;
  this.inputObj.select();
//  this.inputObj.focus();
}

function lovUnselectOptions()
{
  //make sure no Lov options are selected.
  this.selectObj.selectedIndex = -1;
}

function lovUpdateHidden()
{
  var matchingIndex = this.findMatchingIndex();

  if(this.multiValue == true)
  {
    this.hiddenObj.value = this.inputObj.value;
  }
  else if (matchingIndex > -1)
  {
    this.hiddenObj.value = this.selectObj.options[matchingIndex].value;
  }
  else
  {
    this.hiddenObj.value = this.inputObj.value;
  }

  if(classNameExists(this.inputObj,'verifyMe') && window.verifyChange) verifyChange(this.inputObj);
}

function lovFindMatchingIndex()
{
  var inputObjCompStr = (this.validateMe) ? this.inputObj.value.toUpperCase() : this.inputObj.value;
  for (var i=0; i<this.TxtArray.length; i++)
  {
    //find a starting string that matches the typed string.  If validate is on, ignore case, otherwise comparison is case-sensitive.
    var lovCompString1 = (this.validateMe) ? this.TxtArray[i].toUpperCase() : this.TxtArray[i];
    if (lovCompString1.indexOf(inputObjCompStr,0) == 0)
    {
      return i;
    }
  }
  return -1;
}

function lovAutoComplete(e)
{
  var evt = getEvent(e);
  //store current value of the input for comparison
  this.txt.typedTxt = this.inputObj.value;
  var changesFound = (this.txt.prevTxt != this.txt.typedTxt);
  this.txt.prevTxt = this.txt.typedTxt;

  //TODO: if changes are made as a result of pasting or other mechanism, start autocomplete and don't return.  Not sure how to do this.
  //if no change to the input (i.e., some key other than a character key was hit)
  if (!changesFound)  {
    this.txt.prevTxt = '';
    return;
  }

  if (this.validateMe == 'false' || !this.validateMe && evt.keyCode == 27) {
    return;
  }

  var KeyCodeArray = new Array(13,16,9,37,38,39,40,17,18);
  //if modifyer keys are being used
  //Enter, Shift, Tab, Esc, Ctrl, Alt, arrow keys are being handled elsewhere, so return
  for (k=0; k<KeyCodeArray.length; k++)
  {
    if (evt.altKey || evt.ctrlKey || evt.keyCode == KeyCodeArray[k]) return;
  }

  var isDeleteBackspace = ((is.safari && evt.keyCode == 127) ||
        (!is.safari && (evt.keyCode == 46 || evt.keyCode == 8)));
  //abort if delete/backspace
  if (isDeleteBackspace)
  {
    if (!this.validateMe) {
      this.close();
    }
    return;
  }

  var match = false;
  var typedTxtCompStr = (this.validateMe) ? this.txt.typedTxt.toUpperCase() : this.txt.typedTxt;
  for (var i=0; i<this.TxtArray.length; i++)
  {
    //find a starting string that matches the typed string.  If validate is on, ignore case, otherwise comparison is case-sensitive.
    var cs = (this.validateMe) ? this.TxtArray[i].toUpperCase() : this.TxtArray[i];
    if (cs.indexOf(typedTxtCompStr,0) == 0) {
      match = true;
      break;
    }
  }

  if (match)
  {
  //alert(classNameExists(this.inputObj,'multiValue'))
    if((is.ie5up && is.win) || is.mozilla)
    {
      //send autocomplete text to the field
      this.inputObj.value = this.TxtArray[i];
      selectText(this.inputObj,this.txt.typedTxt.length,this.inputObj.value.length);
    }
    this.open();
    this.selectObj.options[i].selected = true;
  }
  else if (this.validateMe)
  {
    //if input requires validation, always open the LOV immediately, regardless of whether or not there is a match.
    this.open();

  // Find the closest and return that.
    while (!match) {
      // Shorten it until we find a match.
      typedTxtCompStr = typedTxtCompStr.substring(0, typedTxtCompStr.length - 1);
    for (var i=0; i<this.TxtArray.length; i++)
    {
    var cs = this.TxtArray[i].toUpperCase();
    if (cs.indexOf(typedTxtCompStr,0) == 0) {
      match = true;
      break;
    }
    }
    }
    if((is.ie5up && is.win) || is.mozilla)
    {
      //send autocomplete text to the field
      this.inputObj.value = this.TxtArray[i];
      selectText(this.inputObj,typedTxtCompStr.length,this.inputObj.value.length);
    }
    //this.open();
    this.selectObj.options[i].selected = true;
  }
  else
  {
    this.close();
  }
}

function lovOpen()
{
  if (this.isVisible) return;

  var x,y,w;

  //reset LOV's width
  this.selectObj.style.width = "";

  //if(restrictLovWidth || this.selectObj.offsetWidth < this.inputObj.offsetWidth + this.buttonObjImg.offsetWidth)
  if(restrictLovWidth || this.selectObj.offsetWidth < this.inputObj.offsetWidth)
  {
    //If LOV width is restricted or the LOV is shorter than the associated text input, make the LOV same size as text input
    w = this.inputObj.offsetWidth;
  }
  else
  {
    w = this.selectObj.offsetWidth;
  }
  //account for the width of the associated buttonObjImg
  //w += this.buttonObjImg.offsetWidth;

  this.selectObj.style.width = w + "px";
  this.selectObj.style.top = getElY(this.inputObj) + this.inputObj.offsetHeight + "px";
  this.selectObj.style.left = getElX(this.inputObj) + "px";
  this.selectObj.style.display = "inline";
  //fixes a problem where selects with only one option appear as a drop instead of a list.
  if(this.selectObj.size <= 1)
  {
    this.selectObj.size = 1;
    this.selectObj.multiple = true;
  }
  else
  {
    this.selectObj.multiple = false;
  }
  this.isVisible = true;

  replaceClassName(this.inputObj,"lovInput","lovInput_active");

  x = getElX(this.selectObj);
  y = getElY(this.selectObj);

  this.shadow.setPosition(x,y,w,this.selectObj.offsetHeight);
  this.shadow.show();
  this.unselectOptions();
  //this.buttonObjImg.src = this.buttonObjImgSrcA;
}

function lovClose()
{
  if (!this.isVisible) return;
  this.isVisible = false;
  this.unselectOptions();
  replaceClassName(this.inputObj,'lovInput_active','lovInput');
  this.selectObj.style.display = "none";
  this.shadow.hide();
  //this.buttonObjImg.src = this.buttonObjImgSrc;
}

function lovValidate()
{
  //determine if the typed value matches a value from the select list
  if (!this.validateMe || this.validateMe == 'false') return;

  var isValid = false;

  for (var i=0; i<this.TxtArray.length; i++)
  {
    //find a valid string that matches the typed string exactly

    if (this.TxtArray[i] == this.inputObj.value)
    {
      isValid = true;
      break;
    }
  }
  if (!isValid)
  {
    addClassName(this.inputObj,'inputError');
  //this.inputObj.className = this.txt.defaultClassName + " inputError";
  }
  else removeClassName(this.inputObj,'inputError'); //this.inputObj.className = this.txt.defaultClassName;
}

function lovSetShadowPosition(x,y,w,h)
{
  if (!useLovShadow)
  {
    return;
  }
  var myLovShadow = this.obj;
  myLovShadow.style.left   = parseInt(x) + parseInt(this.nudgeX) + "px";
  myLovShadow.style.top    = y + "px";
  myLovShadow.style.width  = w + "px";
  myLovShadow.style.height = parseInt(h) + parseInt(this.nudgeY) + "px";
}

function lovShowShadow()
{
  if (useLovShadow)
  {
    this.obj.style.visibility = "visible";
  }
}

function lovHideShadow()
{
  if (useLovShadow)
  {
    this.obj.style.visibility = "hidden";
  }
}

function getTxtInput(srcInput,oLov)
{
  if (!LovTxtInputs[this.inputObj.id])
  {
    LovTxtInputs[this.inputObj.id] = new TxtInput(srcInput,oLov);
    LovTxtInputsArray[LovTxtInputsArray.length] = LovTxtInputs[this.inputObj.id];
  }
  return LovTxtInputs[this.inputObj.id];
}

function lovToggle()
{
  if (!this.isVisible)
  {
    this.open();
  }
  else
  {
    this.close();
  }
}

function lovCancelAutoComplete()
{
  if (this.isVisible)
  {
    this.close();
    this.validate();
    //clear selection, if any
    selectText(this.inputObj,this.inputObj.value.length,this.inputObj.value.length);
  }
}

function lovUpArrow()
{
  if(!this.isVisible)
  {
    return;
  }
  var selIndex = this.selectObj.selectedIndex;
  var nextIndex = selIndex-1;

  if (selIndex != 0)
  {
    this.selectObj.options[nextIndex].selected = true;
    this.inputObj.value = this.TxtArray[nextIndex]
  }
  this.inputObj.select();
}

function lovDownArrow()
{
  //if the LOV is closed, open it
  var selIndex = this.selectObj.selectedIndex;
  var nextIndex = selIndex+1;

  if(!this.isVisible)
  {
    this.open();
  }
  if (this.selectObj.selectedIndex < this.selectObj.options.length -1)
  {
    this.selectObj.options[nextIndex].selected = true;
    this.inputObj.value = this.TxtArray[nextIndex];
  }
  this.inputObj.select();
}

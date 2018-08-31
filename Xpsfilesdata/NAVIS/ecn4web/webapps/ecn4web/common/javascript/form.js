/************************************************************************/
/**** JavaScript for manipulating form inputs.                       ****/
/****                                                                ****/
/************************************************************************/
/****                                                                ****/
/**** This file depends upon the following JavaScript files:         ****/
/****   -common.js                                                   ****/
/****   -cookie.js                                                   ****/
/****                                                                ****/
/************************************************************************/

var errorIconPath       = commonImgRoot + 'icons/inline/error.gif';
var errorIconActivePath = commonImgRoot + 'icons/inline/error_active.gif';
var useInputHighlight   = true;
var RadioObjs           = new Object();

function setInputFocusById(focusFieldId)
{
  if(is.unsupported) return;
  var oInput = getFormInput(focusFieldId);

  if(oInput == null) return;
  setInputFocus(oInput);
}

function setInputFocus(obj)
{
  //obj = any non-hidden input object
  if(!obj) return;
  obj.focus();
  obj.select();
}

function getFormInput(inputId,formName)
{
  //TODO: doesn't work with radio buttons in IE

  //find a form input by its id or its name
  var oInput = null;

  //first look for an input by its id
  if (document.getElementById(inputId) && (document.getElementById(inputId).tagName == "INPUT" || document.getElementById(inputId).tagName == "TEXTAREA" || document.getElementById(inputId).tagName == "SELECT"))
  {
    oInput = document.getElementById(inputId);
  }
  //then look for input by name, by form name
  else if(formName && document.forms[formName])
  {
    oInput = document.forms[formName].inputId;
  }
  //if neither an input ID nor a formName was passed, search for input by recursion using input name
  else
  {
    for (var i=0; i<document.forms.length; i++)
    {
      if(document.forms[i].elements[inputId])
      {
        //In moz this will return a reference to the button collection for radio buttons
        oInput = document.forms[i].elements[inputId];
      }
    }
  }
  return oInput;
}

function getInputLabel(oInput)
{
  //TODO: add support for all of the following
  // there is no built-in method for finding a label associated with any input.
  // This function will attempt to find one by:
  // 1. Look for a "label" expando attribute in the input
  // 2. Look for a sibling label object
  // 3. Climb the DOM and find the first uncle label object.
  // 4. Crawl the entire DOM to find label objects with a "for" attribute that matches the ID of the current object.

  var oLabel = null;

  if(oInput.getAttribute('label'))
  {
    oLabel = document.getElementById(oInput.getAttribute('label'));
  }

  return oLabel;
}

function markAndSubmit(e,val)
{
  var e = getEvent(e);
  var oSrcEl = getSrcEl(e);
  var oForm = getParentEl(oSrcEl,'FORM');
  //if passing in a value, use that value.  Otherwise, try to figure it out by looking for a value attribute
  var oVal = (val) ? val : oSrcEl.value ? oSrcEl.value : "";

  return;
  if(oSrcEl.nodeName == 'button')
  {

  }
}

function enableChildrenInputs(obj)
{
  var inputArray = obj.getElementsByTagName('input');

  for(var i=0; i<inputArray.length; i++)
  {
    var curInput = inputArray[i];
    enableInput(curInput);
  }
}

function disableChildrenInputs(obj)
{
  var inputArray = obj.getElementsByTagName('input');

  for(var i=0; i<inputArray.length; i++)
  {
    var curInput = inputArray[i];
    disableInput(curInput);
  }
}

function enableInput(obj)
{
  removeClassName(obj,'disabled');
  obj.readOnly = false;
  if(obj.type == 'radio' || obj.type == 'checkbox')
  {
    obj.disabled = false;
  }
}

function disableInput(obj)
{
  addClassName(obj,'disabled');
  obj.readOnly = true;
  if(obj.type == 'radio' || obj.type == 'checkbox')
  {//radio and inputs don't support styles in some browsers, so make them disabled
    obj.disabled = true;
  }
}

function setFirstChildFocus(obj)
{
  //obj = any object that contains an input upon which focus should be set
  var elArray = obj.getElementsByTagName('INPUT');

  for(i=0; i<elArray.length; i++)
  {
    var curEl = elArray[i];
    if(curEl.type != 'hidden')
    {
      setInputFocus(curEl);
      return;
    }
  }
}


/************************************************************************/
/**** The following makes working with radio buttons easier.         ****/
/************************************************************************/
function RadioObj(id)  //constructor
{
  this.id            = id;
  this.objArray      = null;
  this.value         = null;
  this.selectedIndex = null;
  
  //methods
  this.getIndex = getSelectedRadioIndex;
  this.getValue = getSelectedRadioValue;
  this.update   = updateRadioObj;
}

function getSelectedRadioIndex()
{
  for(var i=0; i<this.objArray.length; i++)
  {
    if (this.objArray[i].checked)
    {
      this.selectedIndex = i;
      return;
    }
  }
}

function getSelectedRadioValue()
{
  this.value = this.objArray[this.selectedIndex].value;
}

function getRadioObj(id)
{
  if (!RadioObjs[id])
  {
    initRadioObj(id);
  }
  else
  {
    RadioObjs[id].update();  
  }
  return RadioObjs[id];
}

function updateRadioObj()
{
  this.getIndex();
  this.getValue();
}

function initRadioObj(id)
{
  RadioObjs[id] = new RadioObj(id);
  RadioObjs[id].objArray = document.getElementsByName(id);
  RadioObjs[id].update();
}

function getRadioValue(id)
{
  var oRadio = getRadioObj(id);
  return oRadio.value;
}


/************************************************************************/
/**** The following is used by the password widget.                  ****/
/************************************************************************/
function checkMatch(obj1,obj2)
{
  //check if the value of two inputs matches
  var input1 = getFormInput(obj1);
  var input2 = getFormInput(obj2);
  var match = (input1.value!='' && input2.value!='' && input1.value == input2.value) ? true : false;
  var tipText = 'Password and Confirmation must match';

  if(!match)
  {
    setInputError(input1,tipText);
    setInputError(input2,tipText);
    //TODO: very hacky way of preventing parent form from submitting.  Fix this.
    formValid =  false;
  }
  else
  {
    clearInputError(input1);
    clearInputError(input2);
    //TODO: very hacky way of preventing parent form from submitting.  Fix this.
    formValid = true;
  }
}

function setInputError(oInput,tipText)
{
  //change the appearance of the input and associated labels to reflect an error state
  var oLabel = getInputLabel(oInput);

  addClassName(oLabel,'error');
  addClassName(oInput,'inputError');
  appendErrorIcon(oLabel);

  if(tipText)
  {
    setTip(oLabel,tipText,true);
  }
}

function clearInputError(oInput)
{
  //clear the appearance of the input and associated labels
  var oLabel = getInputLabel(oInput);

  removeClassName(oLabel,'error');
  removeClassName(oInput,'inputError');
  removeErrorIcon(oLabel);
  //TODO: preserve the original tip, if any
  clearTip(oLabel);
}

function appendErrorIcon(obj)
{
  var hasErrorIcon = false;
  var imgArray = obj.getElementsByTagName('IMG');

  for(var i=0; i<imgArray.length; i++)
  {
    var curImg = imgArray[i];
    hasErrorIcon = (curImg.src.indexOf(getFileName(errorIconActivePath)) > -1) ? true : false;
  }
  if(!hasErrorIcon)
  {
    obj.insertAdjacentHTML('beforeEnd',' <img src="' + errorIconActivePath + '" style="vertical-align:middle;">');
  }
}

function removeErrorIcon(obj)
{
  var imgArray = obj.getElementsByTagName('IMG');

  for(var i=0; i<imgArray.length; i++)
  {
    var curImg = imgArray[i];
    var errorImgName = getFileName(errorIconActivePath);

    if(curImg.src.indexOf(errorImgName) > -1 || curImg.src.indexOf(errorImgName) > -1)
    {
      obj.removeChild(curImg);
    }
  }
}


/************************************************************************/
/**** Form input highlighting.                                       ****/
/************************************************************************/
function initFormHighlight()
{
  //create cookie
  var inputHighlightCookieExpireDate = new Date("December 31, 3001");
  if (getCookie('useInputHighlight') == null)
  {
    setCookie('useInputHighlight','true',inputHighlightCookieExpireDate)
  }
  else
  {
    useInputHighlight = (getCookie('useInputHighlight') == 'true') ? true : false;
  }
}

function toggleInputHighlight()
{
  if (getCookie('useInputHighlight') == 'true')
  {
    setCookie('useInputHighlight','false');
    useInputHighlight = false;
  }
  else if (getCookie('useInputHighlight') == 'false')
  {
    setCookie('useInputHighlight','true');
    useInputHighlight = true;
  }
  updateMenuCheck('highlightMenuCheck',useInputHighlight);
}

function paintInputHighlight(e)
//add an accent color to the active input
{
  if(!useInputHighlight) return;

  try
  {
    var obj = getSrcEl(e);
    //don't hightlight if the field is disabled.
    if(obj.readOnly || obj.disabled) return;

    addClassName(obj,'activeInput');
  }
  catch(err)
  {
    return;
  }
}

function wipeInputHighlight(e)
//remove the accent color for the inactive input
{
  if(!useInputHighlight) return;
  var obj = getSrcEl(e);
  //don't bother if the field is disabled.
  if(obj.readOnly || obj.disabled) return;
  removeClassName(obj,'activeInput');
}

/************************************************************************/
/**** JavaScript for displaying a tooltip when user mouses-over an   ****/
/**** object.                                                        ****/
/****                                                                ****/
/************************************************************************/
/****                                                                ****/
/**** This file depends upon the following JavaScript files:         ****/
/****   -common.js                                                   ****/
/****   -browserSniff.js                                             ****/
/****   -imageSwap.js                                                ****/
/****   -cookie.js                                                   ****/
/****                                                                ****/
/************************************************************************/
/****                                                                ****/
/**** The following is example syntax for displaying a tooltip on    ****/
/**** an image.  This syntax can be applied to any HTML object.      ****/
/****                                                                ****/
/**** <img src="[image source]"                                      ****/
/****   width="[image width]"                                        ****/
/****   height="[image height]"                                      ****/
/****   tip="[string]"                                               ****/
/****   name="[unique object name]"                                  ****/
/**** >                                                              ****/
/****                                                                ****/
/************************************************************************/
/****                                                                ****/
/**** The following are possible values for optional arguments       ****/
/**** passed as a comma-delimited list:                              ****/
/****                                                                ****/
/****  isError                                                       ****/
/****    [type=boolean]                                              ****/
/****    1 = use the error CSS class and tip images                  ****/
/****    0 or null = use default                                     ****/
/****                                                                ****/
/****  forceLeft                                                     ****/
/****    [type=boolean]                                              ****/
/****    1 = force tip to appear to the left of the pointer          ****/
/****    0 or null = use default behavior                            ****/
/****                                                                ****/
/****  forceBelow                                                    ****/
/****    [type=boolean]                                              ****/
/****    1 = force tip to appear below the pointer                   ****/
/****    0 or null = use default behavior                            ****/
/****                                                                ****/
/****  maxWidth                                                      ****/
/****    [type=string]                                               ****/
/****    Maximum allowable width for the tooltip.                    ****/
/****    null = use default maxWidth                                 ****/
/****    "*" = use auto to fill available space                      ****/
/****                                                                ****/
/****  isFixed                                                       ****/
/****    [type=boolean]                                              ****/
/****    The tooltip will float around with the mouse unless this    ****/
/****    argument is set to 1.  Because of display bugs with IE on   ****/
/****    the PC, this value will default to 1 for this browser       ****/
/****    unless explicitly set to 0.                                 ****/
/****                                                                ****/
/****  useTipPopup                                                   ****/
/****    [type=boolean]                                              ****/
/****    By default, tooltips will use a popup object on IE on PC.   ****/
/****    This setting will be ignored for all other browsers.        ****/
/****                                                                ****/
/****  nudgeX                                                        ****/
/****    [type=int]                                                  ****/
/****    X nudge from pointer tip                                    ****/
/****    null = use default nudgeX                                   ****/
/****                                                                ****/
/****  nudgeY                                                        ****/
/****    [type=int]                                                  ****/
/****    Y nudge from pointer tip                                    ****/
/****    null = use default nudgeY                                   ****/
/****                                                                ****/
/****  shadowNudgeX                                                  ****/
/****    [type=int]                                                  ****/
/****    X shadow nudge from tip                                     ****/
/****    null = use default shadowNudgeX                             ****/
/****                                                                ****/
/****  shadowNudgeY                                                  ****/
/****    [type=int]                                                  ****/
/****    Y shadow nudge from tip                                     ****/
/****    0 or null = use default shadowNudgeY                        ****/
/****                                                                ****/
/****  timeoutTime                                                   ****/
/****    [type=int]                                                  ****/
/****    Maximum lifespan of an inactive tootip                      ****/
/****                                                                ****/
/****   delayTime                                                    ****/
/****    [type=int]                                                  ****/
/****    Duration before tootip appears                              ****/
/****                                                                ****/
/****                                                                ****/
/************************************************************************/
/************************************************************************/
/**** Variables                                                      ****/
/************************************************************************/
//images
var tipDownPointerSrc       = commonImgRoot + 'toolTip/pointerDown.gif';
var tipUpPointerSrc         = commonImgRoot + 'toolTip/pointerUp.gif';
var errorTipDownPointerSrc  = commonImgRoot + 'toolTip/errorPointerDown.gif';
var errorTipUpPointerSrc    = commonImgRoot + 'toolTip/errorPointerUp.gif';
var tipDownPointerShadowSrc = commonImgRoot + 'toolTip/pointerShadowDown.gif';
var tipUpPointerShadowSrc   = commonImgRoot + 'toolTip/pointerShadowUp.gif';

//stylsheet
var tipStyleSheet = cssModuleRoot + 'tooltip.css';

//parameters
var defaultTipIsFixed = false;
var defaultTipNudgeX = 1;
var defaultTipNudgeY = 7;
var defaultTipMaxWidth = 150;
var defaultTipShadowNudgeX = 3;
var defaultTipShadowNudgeY = 3;
var defaultTipForceLeft = 0;
var defaultTipForceBelow = 0;
var defaultTipUsePopup = false;
var useTip = true;
var useTipShadow = ((is.win && is.ie6up) || is.moz5up) ? true : false;  //these browsers can use alpha
var defaultTimeout = 3000;
var defaultDelay = 1000;

//objects
var tipPopup = null;
var ToolTips = new Object();
var TipsArray = new Array();

/************************************************************************/
/**** Constructors                                                   ****/
/************************************************************************/
function ToolTip(id,txt,isError,forceLeft,forceBelow,maxWidth,isFixed,useTipPopup,nudgeX,nudgeY,shadowNudgeX,shadowNudgeY,delayTime,timeoutTime)
{
  //TODO: the only arguments presently used are id, txt, and isError

  //properties
  this.id = id;
  this.srcObj = 'undefined';
  this.txt = txt;
  this.isError = (isError) ? isError : 0;
  this.forceLeft = (forceLeft) ? forceLeft : defaultTipForceLeft;
  this.forceBelow = (forceBelow) ? forceBelow : defaultTipForceBelow;
  this.maxWidth = (maxWidth) ? maxWidth : defaultTipMaxWidth;
  this.isFixed = (isFixed) ? isFixed : defaultTipIsFixed; 
  this.useTipPopup = (useTipPopup) ? useTipPopup : (is.ie5_5up && is.win && defaultTipUsePopup) ? true: false; 
  this.nudgeX = (nudgeX) ? nudgeX : defaultTipNudgeX;
  this.nudgeY = (nudgeY) ? nudgeY : defaultTipNudgeY;
  this.obj = makeDiv(this.id + 'tipDiv', 'tip');
  this.pointer = new TipPointer();
  this.shadow = new TipShadow(shadowNudgeX,shadowNudgeY);
  this.pointerShadow = new TipPointerShadow();
  this.isVisible = false;
  this.x = 0;
  this.y = 0;
  this.delayTime = delayTime ? delayTime : defaultDelay;
  this.timeoutTime = timeoutTime ? timeoutTime : defaultTimeout;
  this.delayTimer = null;
  this.timeoutTimer = null;
  
  //methods
  this.setContent = setTipContent;
  this.setDimensions = setTipDimensions;
  this.setPosition = setTipPosition;
  this.setShadowPosition = setTipShadowPosition;
  this.paint = paintTip; 
  this.wipe = wipeTip;
  this.resetContent = resetTipContent;
  this.resetPosition = resetTipPosition;
  this.resetShadowPosition = resetTipShadowPosition;
  this.init = initTip;
  this.makeDiv = makeDiv;
}

function TipPointer()
{
  this.obj = document.getElementById('tipPointer');
  this.height = 0;
  this.width = 0;
  this.x = 0;
  this.y = 0;
}

function TipShadow(nudgeX,nudgeY)
{
  this.obj = makeShadow('tipShadow');
  this.nudgeX = (nudgeX) ? nudgeX : defaultTipShadowNudgeX;
  this.nudgeY = (nudgeY) ? nudgeY : defaultTipShadowNudgeY;
}

function TipPointerShadow()
{
  this.obj = document.getElementById('tipPointerShadow');
}

/************************************************************************/
/**** Functions                                                      ****/
/************************************************************************/
function initToolTip()
{
  //create cookie
  var tipCookieExpireDate = new Date("December 31, 3001");
  if (getCookie('useToolTip') == null)
  {
    setCookie('useToolTip','true',tipCookieExpireDate)
  }
  else
  {
    useTip = ((getCookie('useToolTip') == 'true') && !(is.ie && is.mac)) ? true : false;
  }
  
 //preload the tip images
  preload(tipUpPointerSrc,tipUpPointerShadowSrc,errorTipDownPointerSrc,errorTipUpPointerSrc);
  
  //build pointer image
  var oNewImg = document.createElement('IMG');
  document.body.appendChild(oNewImg);
  oNewImg.setAttribute('id','tipPointer');
  oNewImg.className = 'tipPointer';
  oNewImg.style.zIndex = 4;
  oNewImg.src = tipDownPointerSrc;
  
  //build pointer shadow image
  var oNewShadow = document.createElement('IMG');
  document.body.appendChild(oNewShadow);
  oNewShadow.setAttribute('id','tipPointerShadow');
  oNewShadow.className = 'tipPointerShadow';
  oNewShadow.style.zIndex = 2;
  oNewShadow.src = tipDownPointerShadowSrc;
  
  //TODO: where does this belong?
  /*if(window.createPopup) //aware of popup object
  {
    tipPopup = window.createPopup();
    tipPopup.document.createStyleSheet(tipStyleSheet);
    tipPopup.document.body.innerHTML = "<div id='tipPopupBody' style='position:absolute;top:0px;left:0px;visibility:visible;width:100%'></div>";
  }*/
}

function initTip(tipId)
{
  this.srcObj = document.getElementById(this.id); // reference the source object
  this.txt = this.srcObj.getAttribute('tip'); // get the tip text
  this.isError = this.srcObj.getAttribute('iserrortip') ? true : false; // test to see if this is an error tip
  this.setContent(); //add content to the tip object
  this.setDimensions();
}

function getTip(tipId)
{
  //initialize tip if it doesn't exist
  if (!ToolTips[tipId])
  {
    ToolTips[tipId] = new ToolTip(tipId);
    ToolTips[tipId].init();
    TipsArray[TipsArray.length] = ToolTips[tipId];
  }
  return ToolTips[tipId];
}

function showTip(e)
{
  if (!useTip || !window.TipsArray)
  {
    return;
  }
  
  // in case this object is nested, traverse the bubble heirarchy
  var actualEl = getParentElByAttribute(getSrcEl(e),'tip');
  
  //it is possible to remove a tip dynamically.  If no longer present, return.
  if(!actualEl.getAttribute('tip')) return;
  
  //test to see if the element has an id.  If not, assign one.
  //TODO: this might cause some trouble if the id is dynamically changed by another js method
  actualEl.id = (!actualEl.id || actualEl.id=='') ? "tip" + TipsArray.length : actualEl.id;
 
  var tip = getTip(actualEl.id);
  tip.setPosition(e);
  tip.setShadowPosition();
  
  if(!tip.isVisible)
  {
    if(!tip.delayTimer)
	{
	  tip.delayTimer = setTimeout("ToolTips['" + tip.id + "'].paint();",tip.delayTime); //wait for delayTime before painting the tip
    }
  }
  
  if(tip.timeoutTimer) clearTimeout(tip.timeoutTimer);
  tip.timeoutTimer = setTimeout("ToolTips['" + tip.id + "'].wipe();",tip.timeoutTime + tip.delayTime); //kill tip after timeoutTime
}

function hideTip(e)
{
  if (!useTip || !window.TipsArray)
  {
    return;
  }
  
  var tip = 'undefined';
  var e = getEvent(e);
  var oSrcEl = getSrcEl(e);

  // in case this object is nested, traverse the bubble heirarchy
  var tipId = getParentElByAttribute(oSrcEl,'tip').id;
  
  tip = getTip(tipId);
  tip.wipe();
}

function hideAllTips()
{
  if (!useTip)
  {
    return;
  }
  for(i=0; i<TipsArray.length; i++)
  {
    hideTip(TipsArray[i].id);
  }
}

function setTipDimensions()
{
  //set its height and width
  this.obj.style.height = "auto";
  this.obj.style.width = "auto";
  this.obj.style.width = (this.maxWidth == "*") ? "auto" : (this.obj.offsetWidth > parseInt(this.maxWidth)) ? this.maxWidth + "px" : "auto";
  this.pointer.height = this.pointer.obj.offsetHeight;
  this.pointer.width = this.pointer.obj.offsetWidth;
}

function setTipContent()
{ 
  this.obj.innerHTML = this.txt;
  this.obj.className = (this.isError) ? "errorTip" : "tip";
  this.pointer.obj.className = (this.isError) ? "errorTipPointer" : "tipPointer";
}

function setTipPosition(e)
{
  if (this.isFixed && this.isVisible)
  {
    return;
  }
  var eX;
  var eY;
  var lefter;
  var topper;
  var roomRight;
  var roomLeft;
  var roomAbove;
  var roomBelow;
  var availableWidth;
  var availableHeight;
  var floatPointer = false;
  
  if (this.isVisible && this.isFixed)
  {
    return;
  }
      
  eX = getEventX(e);
  eY = getEventY(e);

  //determine available space
  availableWidth = (document.body.scrollLeft + document.body.clientWidth) - this.shadow.nudgeX;  //determine maximum range for width
  availableHeight = (document.body.scrollTop  + document.body.clientHeight) - (this.obj.offsetHeight + this.shadow.nudgeY); //determine maximum range for height
  
  //determine if there is space to the right
  roomRight = (eX + (this.obj.offsetWidth) < availableWidth) ? true : false;
  
  //determine if there is space to the left
  roomLeft = (eX - this.obj.offsetWidth > 0) ? true : false;
   
  //determine if there is space above
  roomAbove = (eY - this.obj.offsetHeight - this.pointer.obj.offsetHeight > 0) ? true : false;
 
  //SET VERTICAL POSITION:
 
  //if there is no room above but there is room below, position below
  if (this.forceBelow || !roomAbove)
  {
   this.pointer.obj.src = (this.isError) ? errorTipUpPointerSrc : tipUpPointerSrc;
   this.pointer.obj.style.top = eY + (this.nudgeY * 2) + "px";
   this.obj.style.top = eY + this.pointer.height + (this.nudgeY * 2) + "px";
  }  
  //otherwise, position above
  else
  {
   this.pointer.obj.src = (this.isError) ? errorTipDownPointerSrc : tipDownPointerSrc;
   this.pointer.obj.style.top = eY - this.pointer.obj.offsetHeight - this.nudgeY + "px";  
   this.obj.style.top = eY - this.pointer.obj.offsetHeight -  this.obj.offsetHeight - this.nudgeY + "px";
  }
  
  //SET HORIZONTAL POSITION:
  
  //if there is no room right, float the pointer
  floatPointer = (!roomRight) ? true : false;
  
  //if there is no room right but there is room left, position left
  if (this.forceLeft || (!roomRight && roomLeft))
  {
    lefter = eX - this.obj.offsetWidth;
    this.pointer.obj.style.left = eX - parseInt(this.pointer.obj.offsetWidth / 2) + this.nudgeX + "px";
    this.obj.style.left = lefter + (this.pointer.obj.offsetWidth / 2 )  + "px";
  }
  //otherwise, position right
  else {
    lefter = (floatPointer) ? Math.min(eX + this.obj.offsetWidth, availableWidth) : eX + this.obj.offsetWidth;
    this.pointer.obj.style.left = eX - parseInt(this.pointer.obj.offsetWidth / 2) - this.nudgeX + "px";
    this.obj.style.left = (floatPointer) ? lefter - this.obj.offsetWidth + "px" : lefter - this.obj.offsetWidth - (this.pointer.obj.offsetWidth /2 ) + "px";
  }
}

function setTipShadowPosition()
{
  if (!useTipShadow)
  {
    return;
  }

  //shadow
  this.shadow.obj.style.left = getElX(this.obj) + this.shadow.nudgeX + "px";
  this.shadow.obj.style.top = getElY(this.obj) + this.shadow.nudgeY + "px";
  this.shadow.obj.style.width = this.obj.offsetWidth + "px";
  this.shadow.obj.style.height = this.obj.offsetHeight + "px";
  //pointerShadow
  this.pointerShadow.obj.style.left = getElX(this.pointer.obj) + this.shadow.nudgeX + "px";
  this.pointerShadow.obj.style.top = getElY(this.pointer.obj) + this.shadow.nudgeY + "px";
}

function paintTip() 
{
  if(this.useTipPopup)
  {
    var tarBody = tipPopup.document.getElementById('tipPopupBody');
    tarBody.innerHTML = this.obj.innerHTML;
    tarBody.className = (this.isError) ? "errorTip" : "tip";
    tipPopup.show(this.obj.offsetLeft+2,this.obj.offsetTop+2,this.obj.offsetWidth,this.obj.offsetHeight,document.body);
  }
  else
  {
    this.obj.style.visibility = "visible";
  }
  this.pointer.obj.style.visibility = "visible";
  if (useTipShadow)
  {
    this.shadow.obj.style.visibility = "visible";
    this.pointerShadow.obj.style.visibility = "visible";
  }
  this.isVisible = true;
  //if(this.delayTimer) clearTimeout(this.delayTimer);
}

function wipeTip() 
{
  this.obj.style.visibility = "hidden";
  this.pointer.obj.style.visibility = "hidden";
  if (useTipShadow)
  {
    this.shadow.obj.style.visibility = "hidden";
    this.pointerShadow.obj.style.visibility = "hidden";
  }
  this.isVisible = false;
  if(this.useTipPopup)
  {
    tipPopup.hide();
  }
  if(this.delayTimer) clearTimeout(this.delayTimer);
  this.delayTimer = null;
  if(this.timeoutTimer) clearTimeout(this.timeoutTimer);
  this.timeoutTimer = null;
}

function resetTipContent()
{
  this.obj.innerHTML = "";
}

function resetTipPosition()
{
  //tip
  this.obj.style.top = "0px";
  this.obj.style.left = "0px";
  //tip pointer
  this.pointer.obj.style.top = "0px";
  this.pointer.obj.style.left = "0px";
}

function resetTipShadowPosition()
{
  if (useTipShadow)
  {
    //tip shadow
    this.shadow.obj.style.width = "auto";
    this.shadow.obj.style.top = "0px";
    this.shadow.obj.style.left = "0px";
    //tip shadow pointer
    this.pointerShadow.obj.style.width = "auto";
    this.pointerShadow.obj.style.top = "0px";
    this.pointerShadow.obj.style.left = "0px";
  }
}

function toggleTooltips()
{
  if (getCookie('useToolTip') == 'true')
  {
    setCookie('useToolTip','false');
    useTip = false;
  }
  else if (getCookie('useToolTip') == 'false')
  {
    setCookie('useToolTip','true');
    useTip = true;
  }
  updateMenuCheck('tipMenuCheck',useTip);
}

function setTip(obj,tipText,isError)
{
  //Dynamically set the toolTip attribute on an object.
  //if there already is a tip on this object, and it is different than
  //the new tipText, append the new tip to the end of the current tip text.

  if(obj.getAttribute('tip') && obj.getAttribute('tip') != '' && obj.getAttribute('tip') != tipText)
  {
    obj.setAttribute('tip',obj.getAttribute('tip') + ' ' + tipText);
  }
  else
  {
    obj.setAttribute('tip',tipText);
  }
  if(isError)
  {
    obj.setAttribute('isErrorTip','1');
  }
  initHandlers(obj);
}

function clearTip(obj)
{
  //Dynamically remove the toolTip attribute on an object
  //TODO: also remove the event binding.
  obj.removeAttribute('tip',0);
  obj.removeAttribute('isErrorTip',0);
  initHandlers(obj);
}

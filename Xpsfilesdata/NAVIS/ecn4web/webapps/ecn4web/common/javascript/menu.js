/************************************************************************/
/**** This script is used to arrange and display operations in the   ****/
/**** menubar.                                                       ****/
/****                                                                ****/
/************************************************************************/
/****                                                                ****/
/**** This file depends upon the following JavaScript files:         ****/
/****   -common.js                                                   ****/
/****   -toolTip.js                                                  ****/
/****                                                                ****/
/************************************************************************/
//TODO: refactor this to use dynalist


/************************************************************************/
/**** GLOBAL VARIABLES                                               ****/
/************************************************************************/
//parameters
var menuShadowNudgeX = 5;
var menuShadowNudgeY = 5;

//objects
var activeButton = null;

//images
var menuCheckSrc = commonImgRoot + 'menuCheck.gif';
var menuCheckOverSrc = commonImgRoot + 'menuCheck_over.gif';
var blankMenuCheckSrc = commonImgRoot + 's.gif';
var blankMenuCheckOverSrc = commonImgRoot + 's.gif';

/************************************************************************/
/**** CONSTRUCTORS                                                   ****/
/************************************************************************/



/************************************************************************/
/**** FUNCTIONS                                                      ****/
/************************************************************************/
function initMenu()
{
  preload(menuCheckSrc,menuCheckOverSrc,blankMenuCheckOverSrc);
  var myShadow = makeShadow('menuShadow');
  updateMenuCheck('tipMenuCheck',useTip);
  updateMenuCheck('highlightMenuCheck',useInputHighlight);
}

function showMenu(el)
{
//show the menu associated with the button clicked
  var buttonId,menuId,itemsArray,menuObj;
  var maxwidth = 0;

  
  buttonId = el.getAttribute('id');
  menuId = el.getAttribute('menuId');
  menuObj = document.getElementById(menuId);

  menuObj.style.left = getElX(el) + "px";
  menuObj.style.top = getElY(el) + el.offsetHeight + "px";

  //if (document.filters) menuObj.filters[0].apply();
  menuObj.style.visibility = "visible";
  //if (document.filters) menuObj.filters[0].play();

  //position and size shadow
  var myShadow = makeShadow('menuShadow');

  myShadow.style.width = menuObj.offsetWidth;
  myShadow.style.height = menuObj.offsetHeight;
  myShadow.style.left = getElX(el) + menuShadowNudgeX + "px";
  myShadow.style.top = getElY(el) + el.offsetHeight + menuShadowNudgeY + "px";
  //myShadow.filters[1].apply();  //causes child window to reset scroll position
  myShadow.style.visibility = "visible";
  //myShadow.filters[1].play();
}

function hideMenu(el)
{
//hide the menu associated with the button clicked
  var menuId,menuObj;

  menuId = el.getAttribute('menuId');
  menuObj = document.getElementById(menuId);
  menuObj.style.visibility = "hidden";
  document.getElementById('menuShadow').style.visibility = "hidden";
}

/****** BUTTON EVENTS ******/
function buttonClick(e)
{
  e = getEvent(e);
//event fired when clicking a menu button
  var el = getParentElByAttribute(getSrcEl(e),'menuId');
  var targetMenuId = el.getAttribute('menuId');
  
  if(!el.getAttribute('origClass')) el.setAttribute('origClass', el.className);
  if(!el.getAttribute('activeClass')) el.setAttribute('activeClass', el.className +'Active');
  
  if (!document.getElementById(targetMenuId))
  {
	return;
  }
  try
  {
      el.blur();
  }
  catch(err)
  {
    //do nothing
  }
  if (activeButton == el)
  {
    resetButton();
  }
  else
  {
	depressButton(e,el);
  }
  return false;
}

function buttonMouseover(e)
{
//event fired when mousing over a button
  var el = getParentElByAttribute(getSrcEl(e),'menuId');

  if (activeButton == el)
  {
    el.className = el.getAttribute('activeClass');
  }
  if (activeButton != null && activeButton != el)
  {
    resetButton()
    try
      {
      el.click();
      }
    catch(err)
      {
      //do nothing
      }
  }
}

function buttonMouseout(e)
{
//event fired when mousing off a button
  var el = getParentElByAttribute(getSrcEl(e),'menuId');
  if (activeButton != null && activeButton == el) el.className = el.getAttribute('activeClass');
  else el.className=el.getAttribute('origClass');
}

function depressButton(e,el)
{
//activate a menu after clicking an inactive menu button
  activeButton = el;
  el.className = el.getAttribute('activeClass');
  showMenu(el);
  cancelEventPropagation(e);
}

function resetButton()
{
//reset a menu button
  if (activeButton == null) return;
  activeButton.className = activeButton.getAttribute('origClass');
  hideMenu(activeButton);
  activeButton = null;
}

/************************************************************************/
/**** Tooltip Menu                                                   ****/
/************************************************************************/
function updateMenuCheck(checkId,val)
{
  if(!document.getElementById(checkId)) return;
  
  var tipCheck = getSwapableImg(checkId,menuCheckOverSrc);
  tipCheck.obj.src = (val) ? menuCheckSrc : blankMenuCheckSrc;
  tipCheck.origSrc = (val) ? menuCheckSrc : blankMenuCheckSrc;
  tipCheck.overSrc = (val) ? menuCheckOverSrc : blankMenuCheckOverSrc;
}

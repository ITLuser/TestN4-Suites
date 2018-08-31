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
/**** The following script is used to contain page-level event       ****/
/**** bindings.                                                      ****/
/****                                                                ****/
/************************************************************************/
/****                                                                ****/
/**** This file depends upon the following JavaScript files:         ****/
/****   -none                                                        ****/
/****                                                                ****/
/************************************************************************/

var doc = document;

doc.onmouseover = docOver;
doc.onmouseout = docOut;
doc.onfocus = docFocus;
doc.onblur = docBlur;
doc.onclick = docClick;
doc.onmousedown = docDown;
doc.onmouseup = docUp;
doc.oncontextmenu = docContextMenu;
doc.onkeydown = docKeyDown;
window.onload = winOnload;
window.onunload = winUnload;

function docOver(e)
{
  if(window.setToolbar) setToolbar();
}

function docKeyDown(evt)
{
var e = getEvent(evt);
var charCode = (is.ns) ? e.which : e.keyCode
if(window.modalLive == true && charCode == '27' && window.keyedEsc)
  {
  keyedEsc()
  }
}

function docOut(e)
{
}

function docFocus(e)
{
}

function docBlur(e)
{
}

function docClick(e)
{
  var e = getEvent(e);
  if (top.window.resetButton) top.window.resetButton(); //close all menus in menubar
// REMOVED THE LINE BELOW FOR TRIPS MERGE
// 7/22/2004 cdn
//if (window.LovsArray && window.LovsArray.length > 0 && LovPageClick) LovPageClick(e);  //hide LOVS using autocomplete
  if (window.calendarDocumentClick) calendarDocumentClick(e);
}

function docDown(e)
{
  //var el = window.event.srcElement;
  //if (el && el.tagName == "IMG") swapImgDown();
}

function docUp(e)
{
  //var el = window.event.srcElement;
  //if (el && el.tagName == "IMG") swapImgUp();
}

function docContextMenu(e)
{
  //if (top.window.frames && top.window.frames.length > 0 && top.window.frames('contentFrame').hideContextMenu) top.window.frames('contentFrame').hideContextMenu()
}

function winOnload(e)
{
  //initialize objects
  if(window.verifyCompliance) verifyCompliance();    //test for browser compliance
  if(window.initGetElsByTagName) initGetElsByTagName();    //need to 'turn on' getElementsByTagName for IE5.X
  if(window.initModal) initModal();                  // modal dialog
  if(window.initToolTip) initToolTip();              //tooltip
  if(window.initFormHighlight) initFormHighlight();  //form input highlighting
  if(window.initMenu) initMenu();                    //menu
  if(window.initCalendar) initCalendar();            //calendar widget
  if(window.initHandlers) initHandlers();            //status message watcher
  if(window.focusFieldId && window.setInputFocusById) setInputFocusById(window.focusFieldId);
  if(window.initSubTabs) initSubTabs();
  if(window.setToolbar) setToolbar();
  if(window.initSubTabs) initSubTabs();
  if(window.initPage) initPage();                    //any page can include a proprietary initPage() function
}

function winUnload(e)
{
  //initialize objects
  if(window.resetSelectedRow) resetSelectedRow();    //clear selected rows.
}

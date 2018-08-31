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

/*
* calendarHandlers.js contains functions to show and hide the popup calendar
*
*/

/*
*	TO DO:
*		None.
*/

/*
* IMPLEMENTATION NOTES:
* Parameters:
*		None.
*
*
*		Optionally you can set an override for the date format by means of the 
*		following:
*			dateformat="mmddyyyy"
*
*	Requires:
*   common.js
*		globalHandler.js
*		statusHandler.js
*/

function clearCalTimeout(evt)
{
  // grab the status mouseover event handler
  setStatus(evt)
  if (timeoutId) clearTimeout(timeoutId);
  return true;
}

function setCalTimeout(e)
{
  var e = getEvent(e);
  
  if (timeoutDelay) navisCalendarTimeout(e);
  window.status = ''; //TODO:  why is this here?
}

function showCal(evt)
{
  var srcEl;
  var actualEl;
  if(is.ie) 
	{
	  evt = (evt) ? evt : ((window.event) ? window.event : "")
	  srcEl = evt.srcElement
	}
  else
  {
  	srcEl = evt.target
  }
  
  // in case this object is nested, traverse the bubble heirarchy
  actualEl = getParentElByAttribute(srcEl,'calendar');
  
  // if there is a shouldAllowPost param, set it to true
  if(window.shouldAllowPost == false) shouldAllowPost = true;
  
  NavisCalendar.show(evt,actualEl.getAttribute('calendar'),null,null,actualEl.getAttribute('dateformat'));
}
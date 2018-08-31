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
* statusHandlers contains functions to set and clear the window 
*	status message.
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
*		To add a status message listener to an object, simply add the 
*		following expando attribute to that object in the HTML:
*			statusmssg="Some message goes here."
*
*	Requires:
*		globalHandler.js
*/

function setStatus(evt)
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
  actualEl = getParentElByAttribute(srcEl,'statusmssg');
  // clear status
  window.status = '';
  // new status
  window.status = actualEl.getAttribute('statusmssg');
}

function clearStatus()
{
  window.status = '';
}

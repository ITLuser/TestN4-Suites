/*
* @(#)confirmHandlers.js
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
* confHandlers contains functions to set and clear ToolTips
*
* @author: Clay Newton
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
*		To add a confirm message listener to an object, simply add the 
*		following expando attribute to that object in the HTML:
*			cmssg="The main confirm message goes here."
*			chead="The confirm header goes here."
*			curl="http://www.some.url"
*			cstyle="[0|1]"
*
*		NOTE:
*			A cstyle of '0' will return a generic confirm w/ an OK 
*			an CANCEL button;
*			A cstyle of '1' will return a delete confirm message with a 
*			DELETE and CANCEL button.
*
*	Requires:
*		globalHandler.js
*/

var defaultHeader = new String('The following alert requires your attention:')
var defaultMessage = new String('NO MESSAGE.')

function showStandardConfirm(e)
{
  var srcEl;
  var actualEl;
  var header = defaultHeader;
  var message = defaultMessage;
  var title = false;
  
  srcEl = getSrcEl(e);
  
  // in case this object is nested, traverse the bubble heirarchy
  actualEl = getParentElByAttribute(srcEl,'cmssg');
  
  if(actualEl.getAttribute('chead'))
  	{
  	header = actualEl.getAttribute('chead');
  	}
  	
  if(actualEl.getAttribute('cmssg'))
  	{
  	message = actualEl.getAttribute('cmssg');
  	}
  if(actualEl.getAttribute('ctitle'))
  	{
  	title = actualEl.getAttribute('ctitle');
  	}
  // Fire the confirm dialog function
  confirmDialog(title,header,message,actualEl.getAttribute('curl'),actualEl.getAttribute('cfunc'),actualEl.getAttribute('cstyle'),actualEl.getAttribute('cxfunc'))
  return false;
}
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
* tipHandlers contains functions to set and clear ToolTips
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
*		To add a Tool Tip message listener to an object, simply add the 
*		following expando attribute to that object in the HTML:
*			tip="Some message goes here."
*
*		Optionally you can set a tooltip to be an error tip by means of the 
*		following:
*			iserrortip="1"
*
*	Requires:
*		globalHandler.js
*/

function setTip(evt)
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
actualEl = getTopBubbleTip(srcEl);

if(actualEl.getAttribute('iserrortip') == '1')
// test if  there is an error attribute set to 1, is so, set error to 1.
	{
	showTip(evt,actualEl.id,actualEl.getAttribute('tip'),1)
	}
else
	{
	showTip(evt,actualEl.id,actualEl.getAttribute('tip'),0)
	}

}

function clearTip()
{
	hideTip(this.id)
}

function getTopBubbleTip(obj)
{
var thisNode = obj
while(!thisNode.getAttribute('tip') && thisNode.nodeName != "BODY")
	{
	thisNode = thisNode.parentNode
	}
return thisNode;
}

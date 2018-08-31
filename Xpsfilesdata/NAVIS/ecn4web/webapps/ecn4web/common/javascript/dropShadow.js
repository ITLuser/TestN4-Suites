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

/**
* DropShadow is a generalized object that can be
*	used to cast shadows behind a given object.
*
**/

/*
* IMPLEMENTATION NOTES:
*		within the constructor for the object you wish to give a shadow, add the following:
*				// BEGIN
*				this.shadow = new DropShadow();
*				this.setShadowPosition = setDropShadowPosition;
*				this.resetShadowPosition = resetDropShadowPosition;
*				// END
*
*		within the 'show' prototype, add the following:
*				// BEGIN
*				this.setShadowPosition();
*				//END
*/

 /**
 **
 ** TO DO:
 **		The DropShadow does not use the popup functionality in IE.
 **		This means that the shadow will act a little strange over
 **		select boxes, etc.
 **/

var shadowNudgeX; // leave blank for now... overrides defaultDropShadowNudgeX
var shadowNudgeY; // leave blank for now... overrides defaultDropShadowNudgeY
var defaultDropShadowNudgeX = 5;
var defaultDropShadowNudgeY = 5;
var theShadow;

function initShadow()
{
  theShadow = document.createElement("DIV");
  theShadow.id = 'dropShadow';
  theShadow.className = 'dropShadow';
  if(!window.printShadow)
	{
		//output the div that will act as the shadow
		// if there has been an override, do not output this line.
		document.body.appendChild(theShadow);
	}
}

function DropShadow(nudgeX,nudgeY)
{
	this.obj = document.getElementById('dropShadow');
	this.nudgeX = (nudgeX) ? nudgeX : defaultDropShadowNudgeX;
	this.nudgeY = (nudgeY) ? nudgeY : defaultDropShadowNudgeY;
	this.follow = false;
}

function setDropShadowPosition()
{
var xOffset = 0;
var yOffset = 0;
if(is.ie  && this.shadow.follow == false)
	{
	xOffset = document.body.scrollLeft;
	yOffset = document.body.scrollTop;
	}
  //shadow
  this.shadow.obj.style.left = ((this.obj.offsetLeft + this.shadow.nudgeX) + xOffset) + "px";
  this.shadow.obj.style.top = ((this.obj.offsetTop + this.shadow.nudgeY) + yOffset) + "px";
  
  this.shadow.obj.style.width = this.obj.offsetWidth + "px";
  this.shadow.obj.style.height = this.obj.offsetHeight + "px";
  this.shadow.obj.style.visibility = "visible";
}

function resetDropShadowPosition()
{
	//tip shadow
	this.shadow.obj.style.width = "auto";
	this.shadow.obj.style.top = 1 + "px";
	this.shadow.obj.style.left = 1 + "px";
	this.shadow.obj.style.visibility = "hidden";
}

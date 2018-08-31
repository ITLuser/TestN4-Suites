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
* The n4Modal is an extensible modal dialog interface.
*
*/

/*
* KNOWN ISSUES:
*		1) The document.body.appendChild() function causes some layout inconsistencies in NS.
*				These are quite mild, but notable nonetheless. Generally, after an element has been 
*				dynamically appended to the document, the browser acts as if there is content that 
*				needs to be scrolled to. Upon scrolling, only white is seen.
*/

/*
* IMPLEMENTATION NOTES:
* Parameters:
*  mName		Required.		String. 		The name of the window. Will be output in the Control Bar. Can be empty string.
*  w 				Required.		Number.	 		The width of the modal dialog to be output
*  h 				Required. 	Number.			The height of the modal dialog to be output
*  htmlNode	Optional.		Object.			The DOM Object which contains the html to output within the modal dialog.
*  url			Optional.		String.			The Url to open in the iframe within the modal dialog.
*
*		Modal with div content and modal name:
*			<!-- BEGIN -->	
*			<a href="javascript:ModalWin.updModal('This is a custom Modal name',500,300,'mContent2')">Some String</a>
*			<!-- END -->
*
*		Modal with url content and no modal name:
*			<!-- BEGIN -->	
*			<a href="javascript:ModalWin.updModal('',250,200,'','http://www.navis.com/home.jsp')">Some String</a>
*			<!-- END -->
*
*	Requires:
*		browserSniff.js
*		math.js
*		dropShadow.js
*		NOTE: 
*			n4Modal.js MUST be included in the html document BEFORE dropShadow.js (overrides shadow html...)
*/
var sels; // holder for the selects on the page (prevents div z-index issue)
if(document.getElementsByTagName) sels = document.getElementsByTagName('SELECT'); 
var ModalWin; // holder for the ModalWindow
var modalParent; // holder for the parent of the modal and the shield
var mShield;  // holder for the Shield
var fNum = 0; // used to keep track of rotations through "fade"
var maxIterations = 2; // number of times to rotate through the fade
var errString = 'No content has been provided.'; // simple error message for convenience.
var imgCloseUp = commonImgRoot+'windowControls/close.gif'
var imgCloseDown = commonImgRoot+'windowControls/close_down.gif'

if(!document.images['mCloseUp'])
{
	var oImg_u = new Image();
	oImg_u.id = 'mCloseUp';
	oImg_u.src = imgCloseUp;
}

if(!document.images['mCloseDown'])
{
	var oImg_d = new Image();
	oImg_d.id = 'mCloseDown';
	oImg_d.src = imgCloseDown;
}

function buildModal()
{
  oMNbsp = document.createElement("NBSP");
  
  oModalParent = document.createElement("DIV");
  oModalParent.id = 'modalParent';
  
  oMShadow = document.createElement("DIV");
  oMShadow.id = 'dropShadow';
  oMShadow.className = 'dropShadow';
  oModalParent.appendChild(oMShadow); // add to parent
  
  oMShield = document.createElement("DIV");
  oMShield.id = 'shield';
  oMShield.appendChild(oMNbsp);
  oModalParent.appendChild(oMShield); // add to parent
  
  oModal = document.createElement("DIV");
  oModal.id = 'theModal';
  
  oModalControls = document.createElement("DIV");
  oModalControls.id = 'modalControls';
  
  oMCSpan = document.createElement("SPAN");
  oMCSpan.id = 'modalName';
  oMCSpan.className = 'h3';
  oModalControls.appendChild(oMCSpan); // add to oModalControls
  
  oMXButton = document.createElement("IMG");
  oMXButton.id = 'xButton';
  oMXButton.src = oImg_u.src;
  oMXButton.width = '16';
  oMXButton.height = '16';
  oMXButton.border = '0';
  oMXButton.alt = 'Close';  //l10n
  oModalControls.appendChild(oMXButton); // add to oModalControls
  oModal.appendChild(oModalControls); // add to oModalControls oModal
  
  oModalContent = document.createElement("DIV");
  oModalContent.id = 'modalContent';
  oModal.appendChild(oModalContent); // add to oModalContent oModal
  
  /*
  **** REMOVED FOR THIS VERSION OF SCHEDULER AS THE 
  **** FUNCTIONALITY IS NOT BEING USED
  ****
  
  ** TODO: add an iframe to every page, create a new Object 
  ** 			 and then point it at that iframe then add that Object 
  **			 as a DOM child of the modal parent.  Be sure to check
  **       this on Moz on Mac.
  
  ****
  try {
  oMIframe = document.createElement("IFRAME");
  oMIframe.id = 'modalIframe';
  oMIframe.style.display = 'none';
  oMIframe.src = 'about:blank';
  oMIframe.frameborder = '0';
  oModal.appendChild(oMIframe); // add to oMIframe oModal
  } catch(exception) {
  	// This is for IE5 PC, which does not allow dynamic creation
  	// and manipulation of an iframe object. Instead, we'll fake
  	// it up by creating our own objects.
  	iframeHTML='\<iframe id="modalIframe" style="';
  	iframeHTML+='display:none;"';
  	iframeHTML+=' src="about:blank"';
  	iframeHTML+=' frameborder="0"';
  	iframeHTML+='><\/iframe>';
  	document.body.innerHTML+=iframeHTML;
  	
  	oMIframe = new Object();
  	oMIframe.document = new Object();
  	oMIframe.document.location = new Object();
  	oMIframe.document.location.iframe = document.getElementById('RSIFrame');
  	oMIframe.document.location.replace = function(location){
  		this.iframe.src = location;
  	}
  }
  */  
  oModalParent.appendChild(oModal); // add to oModal parent
  document.body.appendChild(oModalParent);
}

function ModalWindow()
{
	ModalWin = this;
	
	// declare properties
	this.obj;
	this.shadow;
	this.divs;
	this.iframes;
	this.spans;
	this.controlBar;
	this.closeButton;
	this.staticContent;
	this.dynamicContent;
	// end properties
	
	var theModal;
	
	if(document.getElementById) theModal = document.getElementById('theModal')

	this.obj = theModal;
	
	//define the modal children
	this.divs = this.obj.getElementsByTagName('DIV');
	this.iframes = this.obj.getElementsByTagName('IFRAME');
	this.spans = this.obj.getElementsByTagName('SPAN');

	this.controlBar = this.divs[0]
	this.title = this.spans[0]

	this.closeButton = document.getElementById('xButton');

	this.staticContent = this.divs[1]
	// TODO: DYNAMICCONTENT	
	//this.dynamicContent = this.iframes[0]
	
	// Drop shadow
	this.shadow = new DropShadow();
	this.shadow.follow = true;
	this.setShadowPosition = setDropShadowPosition;
	this.resetShadowPosition = resetDropShadowPosition;

	
	//methods
	this.show = showModal;
	this.hide = hideModal;
	this.setPosition = setModalPosition;
	this.getWidth = getAdjustedWidth;
	this.getHeight = getAdjustedHeight;
	this.doFade = fadeModal;
}

ModalWindow.prototype.updModal = function(mName,w,h,htmlNode,url,shouldClose)
{
  this.setPosition(w,h);
  
  //set the modal name
  this.title.innerHTML = mName;
  
  //set modal children dimensions
  this.controlBar.style.width = this.getWidth(w,true);
  this.staticContent.style.height = this.getHeight(h);
  this.staticContent.style.width = this.getWidth(w); 
  // dynamic content does not need to calculate height for NS vs IE
  	// TODO: DYNAMICCONTENT	
  //this.dynamicContent.style.height = h - (this.controlBar.offsetHeight); 
  	// TODO: DYNAMICCONTENT	
  //this.dynamicContent.style.width = this.getWidth(w);
  
  // initialize the visibility of the closebutton, it may have been hidden
  this.closeButton.style.visibility = "";
  
  //set display properties of the modal children
  if(shouldClose == false)
  {
  	this.closeButton.style.visibility = "hidden"
  }
  
  if(htmlNode != '')
  {
  	if(this.staticContent.style.display == 'none')
  	{
  		this.staticContent.style.display = '';
  	// TODO: DYNAMICCONTENT	
  		//this.dynamicContent.style.display = 'none';
  	}
   //now grab the htmlNode content
  	// TODO: DYNAMICCONTENT	
  	//this.dynamicContent.src = 'about:blank';
  	this.staticContent.innerHTML = document.getElementById(htmlNode).innerHTML;
  }
  	// TODO: DYNAMICCONTENT	
  //else if(url != '')
  //{
  	//if(this.dynamicContent.style.display == 'none')
  //	{
  //		this.dynamicContent.style.display = '';
  //		this.staticContent.style.display = 'none';
  //	}
  	//now grab the url
  //	this.dynamicContent.src = url;
  //}
  else
  {
  // handle null case for modal content
  	this.staticContent.innerHTML = errString;
  	// TODO: DYNAMICCONTENT	
  //	this.dynamicContent.src = 'about:blank';
  }
  
  //show the modal
  	this.show();
}

ModalWindow.prototype.closeDown = function()
{
  document.getElementById('xButton').src = oImg_d.src
}

ModalWindow.prototype.closeUp = function()
{
  document.getElementById('xButton').src = oImg_u.src
}

function getAdjustedWidth(w,cBar)
{
  if(is.ie || cBar == true)// controlBar needs to be given same dimensions in NS and IE 
    {
      return w - 4;
    }
  else
    {
      return w - 10; // takes into account the padding for the div
    }
}

function getAdjustedHeight(h)
{
  if(is.ie)
    {
      return h - (this.controlBar.offsetHeight);
    }
  else
    {
      return (h - (this.controlBar.offsetHeight)) - 10;
    }
}

function setModalPosition(w,h)
{
	var cW;
	cW =	(document.body.scrollLeft != 0) ? document.body.scrollWidth + document.body.scrollLeft : document.body.offsetWidth;
	var cH = document.body.offsetHeight + document.body.scrollTop;
	this.obj.style.width = w;
	this.obj.style.height = h;
	this.obj.style.left = ((cW-w)/2);
	this.obj.style.top = ((cH-h)/2);
	
	//document.body.style.clip = 'auto';//'rect(0 0 ' + cH + '' + cW +')';
}

function setSelectDisplay(state)
{
  if(is.ie)
  {
  	for(i=0;i<sels.length;i++)
  	{
  		// alert(sels[i].offsetHeight)
  		// TODO: need to insert some sort of placeholder to maintain the display properties.
  		sels[i].style.visibility = state;
  	}
  }
}

function initModal()
{
  buildModal();
  
  if(!document.getElementById('dropShadow'))
  	{
  		initShadow()
  	}
  	
  var aModal = new ModalWindow();
  modalParent = document.getElementById('modalParent');
  mShield = document.getElementById('shield');
  mXButtonEl = document.getElementById('xButton');
  mShield.onclick = ModalWin.doFade;
  mXButtonEl.onclick = ModalWin.hide;
  mXButtonEl.onmousedown = ModalWin.closeDown;
  mXButtonEl.onmouseout = ModalWin.closeUp;
  setShield();
  window.modalLive = false;
}

function setShield()
{
  // client Width and Height need to be set each time
  // in order to handle the window being resized
  var cW = document.body.scrollWidth;
  var cH = document.body.scrollHeight;
  mShield.style.width = cW;
  mShield.style.height = cH;
}

function fadeModal()
{
  if((fNum < maxIterations) && (mod(fNum,2) == 0))
  {
  	mShield.style.zIndex = 102
  	fNum++;
  	setTimeout("fadeModal()",25)
  }
  else if((fNum < maxIterations) && (mod(fNum,2) == 1))
  {
  	mShield.style.zIndex = 1
  	fNum++;
  	setTimeout("fadeModal()",25)
  }
  else
  {
  	fNum = 0
  	mShield.style.zIndex = 1
  }
}

function hideModal()
{
  setSelectDisplay('visible');
  modalParent.style.visibility = 'hidden';
  // hide shadow. do not use this, as the xButton has a listener as well.
  ModalWin.resetShadowPosition();
  window.modalLive = false;
}

function showModal()
{
  setShield();
  setSelectDisplay('hidden');
  modalParent.style.visibility = 'visible';
  // show the shadow
	this.shadow.obj.style.zIndex = 10;
	this.setShadowPosition();    
  //For some reason, Moz on PC considers the visibility of staticContent to be hidden,
  //because it's parent div was hidden when the innerHTML was extracted from it.  This
  //property is sticking with the innerHTML even when that HTML is extracted and 
  //placed inside a new node.  This is not an issue with any other platform, including
  //Moz on Mac.
  this.staticContent.style.visibility = "inherit";
  window.modalLive = true;
}


function keyedEsc()
{
//only close the modal on key of "Esc" if there is a close button
if(ModalWin.closeButton.style.visibility != 'hidden')
  {
  hideModal()
  }
}
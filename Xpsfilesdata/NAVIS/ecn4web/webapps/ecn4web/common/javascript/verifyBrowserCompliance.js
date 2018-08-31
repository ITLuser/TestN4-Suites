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
* The verifyBrowserCompliance verifies conformance of the client's browser 
*	against the userAgentCompatMatrixN4 document
*
* @version $Revision: 1.6 $ $Date: 2004-01-29 18:52:13 $
*/

/*
* IMPLEMENTATION NOTES:
*
*		Add verifyCompliance() as an onload event listener. 
*
*	Requires:
*		browserSniff.js
*		n4modal.js
*		dropShadow.js
*		cookie.js
*/

function verifyCompliance()
{
  if(is.blocked)
  {
    blockBrowser();
  }
  else if(is.unsupported)
  {
    displayBrowserWarning();
  }
  else
  {
    //do nothing
    displayBrowserWarning();
    return;
  }
}

function blockBrowser()
{
  var htmlHolder = "";
  htmlHolder += '<html>\n';
  htmlHolder += '<head>\n';
  htmlHolder += '<title>Warning</title>\n'
  htmlHolder += '<link type="text/css" rel="stylesheet" href="' + cssModuleRoot + 'font.css" />'
  htmlHolder += '</head>\n';
  htmlHolder += '<body style="margin:20px;">\n';
  htmlHolder += '<div style="text-align:left;vertical-align:center middle">\n';
  htmlHolder += '<h1 class="error">\n';
  htmlHolder += '<img src="'+commonImgRoot+'/popupHeaders/alert.gif" align="left" width="32" height="25" valign="top">\n';
  htmlHolder += 'Unsupported browser detected!</h1>\n';
  htmlHolder += '<p>The web browser you are using does not conform to the requirements of this application.<br />\n';
  htmlHolder += 'Before proceeding you must update your browser to one of the following:</p>\n';
  htmlHolder += '<ul>\n';
  htmlHolder += '<li><a href="http://www.mozilla.org">Mozilla 1.0 or greater</a></li>\n';
  htmlHolder += '<li><a href="http://www.microsoft.com/windows/ie/default.asp">Internet Explorer 6 or greater</a></li>\n';
  htmlHolder += '<li><a href="http://channels.netscape.com/ns/browsers/default.jsp">Netscape 7.0 or greater</a></li>\n';
  htmlHolder += '</ul>\n';
  htmlHolder += '</div>\n';
  htmlHolder += '</body>\n';
  htmlHolder += '</html>';
  document.write(htmlHolder);
}

function displayBrowserWarning()
{
  var vCheckDate = new Date();    // date object used to determine expiry value of the ignoreUnsupported cookie
  var contentHolder = "";
  var mHolderHtml = new String(); // holder of the modal content for the caution message.

  contentHolder += '<h1 class="warning">';
  contentHolder += '<img src="'+commonImgRoot+'/popupHeaders/warning.gif" width="32" height="25" style="vertical-align:middle">';
  contentHolder += 'Unsupported browser detected!</h1>\n'
  contentHolder += '<p>The web browser you are using does not conform to the requirements of this application. \n';
  contentHolder += 'You may proceed without updating your browser, but you may not be able to access all features. \n';
  contentHolder += 'It is strongly recommended that you use one of the following browsers:</p>\n';
  contentHolder += '<ul>\n';
  contentHolder += '<li><a href="http://www.mozilla.org">Mozilla 1.0 or greater</a></li>\n';
  contentHolder += '<li><a href="http://www.microsoft.com/windows/ie/default.asp">Internet Explorer 6 or greater</a></li>\n';
  contentHolder += '<li><a href="http://channels.netscape.com/ns/browsers/default.jsp">Netscape 7.0 or greater</a></li>\n';
  contentHolder += '</ul>\n';
  contentHolder += '<br>\n'

  alert('fine')
  if(document.body.appendChild && !getCookie('ignoreUnsupported'))
  { //if the browser supports this method, display a modal dialog.
    var oNewNode = document.createElement('DIV');
    document.body.appendChild(oNewNode);
    oNewNode.setAttribute('id','mContent');
    oNewNode.style.display = "none";
  
    mHolderHtml += '<div id="mContent">\n'
    mHolderHtml += contentHolder;
    mHolderHtml += '<button class="button1_default" type="submit" style="float:right" id="cont" onClick="ModalWin.hide()">Continue</button>\n'
    mHolderHtml += '<input type="checkbox" name="dismissWarning" onClick="setCookie(\'ignoreUnsupported\', \'true\', new Date(vCheckDate.getYear() + 1, vCheckDate.getMonth(), vCheckDate.getDate()));ModalWin.hide()">\n'
    mHolderHtml += '<label for="dismissWarning" onClick="setCookie(\'ignoreUnsupported\', \'true\', new Date(vCheckDate.getYear() + 1, vCheckDate.getMonth(), vCheckDate.getDate()));ModalWin.hide()"/>Dismiss this warning</label>\n'
    mHolderHtml += '</input>\n'
    mHolderHtml += '</div>\n'
    
    oNewNode.innerHTML = mHolderHtml;
    
    
    
    initModal();
    ModalWin.updModal('Warning!',500,250,'mContent',null,false)
    document.getElementById('cont').focus();
  }
  else
  {
  alert('alternative')
    document.write(mHolderHtml);
    //add buttons
  }
}

/*
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
*
* The n4Confirm provides functionality that will output a standard
* modal confirm
*
*/

/*
* TO DO:
*   Implement an on-accept function.
*   Implement additional styles.
*/

/*
* IMPLEMENTATION NOTES:
* Parameters:
*   confName      Required.   String.   The alert box name (output in top bar of alert).
*   headerMssg    Required.   String.   The alert box header message (output within
*                                       the H1 next to the Caution icon).
*   mssg          Required.   String.   The message you would like to output in the
*                                       body of the alert.
*   url           Required.   url.      The URL to go to when the confirm is accepted.
*                                       This will eventually be an optional param
*   func          Optional.   Function. A function to execute on confirm accept rather
*                                       than going to a URL
*   style         Optional.   Number.   Currently 1 or default. Chooses the confirm style.
*   cancelfunc    Optional.   Function. A function to execute on cancel
*
*   The following is an example of a delete confirm (style 1):
*     <!-- BEGIN EXAMPLE -->
*     onclick="confirmDialog(
*         'Confirm Delete'
*         'Watch for falling rocks:',
*         'Are you sure you want to delete this item? If so, click \'Delete\'.',
*         'http://navis.com',
*         null,
*         1,
*       );return false"
*     <!-- END EXAMPLE -->
*
*   The following is an example of a standard confirm (default style):
*     <!-- BEGIN EXAMPLE -->
*     onclick="confirmDialog(
*         'Confirm'
*         'The following alert requires your attention:',
*         'Click \'OK\' if you would like to proceed.',
*         'http://navis.com',
*         null,
*         null,
*       );return false"
*     <!-- END EXAMPLE -->
*
*   For l10n, you can override the button and title text:
*     on any given page, in a script tag, set a value for overrideCancelText, overrideConfirmText and overrideConfirmTitle
*     <!-- BEGIN EXAMPLE -->
*     overrideCancelText = 'Cancelaci&oacute;n';
*     overrideConfirmText = 'Autorizaci&oacute;n';
*     overrideConfirmTitle = 'Confirmaci&oacute;n';
*     <!-- END EXAMPLE -->
*
* Requires:
*   browserSniff.js
*   common.js
*   n4Modal.js
*/

var defaultCancelText = 'Cancel';
var defaultConfirmText = 'OK';
var overrideCancelText = false;
var overrideConfirmText = false;

var override

var defaultConfirmTitle = 'Confirmation';
var overrideConfirmTitle = false;

function confirmDialog(confName,headerMssg,mssg,url,func,style,cancelfunc)
{
// determine the title for this modal window
  var thisModalDefaultConfirmTitle = (overrideConfirmTitle != false) ? overrideConfirmTitle : defaultConfirmTitle;
  var thisModalConfirmTitle = (confName != false) ? confName : thisModalDefaultConfirmTitle;
  var divWidth = 400;
  confId = 'confirmMssg'+getBTime();
  setConfirmHtml(headerMssg,mssg,url,func,cancelfunc,style,confId,divWidth)
  ModalWin.updModal(thisModalConfirmTitle,divWidth,getAdjustedMessageHeight(confId),confId);
  if(document.getElementById('defaultButton'))
    {
    document.getElementById('defaultButton').focus()
    }
}


function setConfirmHtml(headerMssg,mssg,url,func,cancelfunc,style,id,divWidth)
{
  //This function builds all of the HTML for the confirmation window and adds the nodes to the document.
  //When the modal is called, this HTML is copied into the modal placeholder.
  var confNode = document.createElement("DIV");
  confNode.id = id;
  confNode.style.visibility = 'hidden';
  confNode.style.width = divWidth;


// determine the button text for this modal window
  var thisModalCancelText = (overrideCancelText != false) ? overrideCancelText : defaultCancelText;
  var thisModalConfirmText = (overrideConfirmText != false) ? overrideConfirmText : defaultConfirmText;

// test if a function string is passed in, if so, do not use go;
  if(func!=null)
    {
    confirmOnclickStr = func + ';removeDialog(\''+id+'\')';
    }
    else
    {
    confirmOnclickStr = 'go(\''+url+'\')';
    }

// test if a cancel function string is passed in, if not, use removeDialog;
  if(cancelfunc!=null)
    {
    cancelOnclickStr = cancelfunc + ';removeDialog(\''+id+'\')';
    }
    else
    {
    cancelOnclickStr = 'removeDialog(\''+id+'\')';
    }

  /*<!-- cancel closes window -->
  cancelHtml = '<td>&nbsp;</td>\n<td class="button1Td"><button class="button1" onclick="removeDialog(\''+id+'\')">'+thisModalCancelText+'</button></td>\n'
  */

  buttonHtml = new String();
  buttonHtml += '<br/><table border="0" cellspacing="0" cellpadding="0" class="buttonTable" align="right">\n'
  buttonHtml += '<tr class="buttonRow">\n'
  if(style == 2)
  {
  // if style == 2, show only a confirm button
    buttonHtml += '<td class="button1Td_default"><button type="button" class="button1_default" id="defaultButton" onclick="'+cancelOnclickStr+'">'+thisModalConfirmText+'</button></td>';
  }
  else
  {

  // by default, show the confirm and cancel
    buttonHtml += '<td class="button1Td_default"><button type="button" class="button1_default" id="defaultButton" onclick="'+confirmOnclickStr+'" onKeyDown="moveFocus(event,\'null\',\'cnclButton\')">'+thisModalConfirmText+'</button></td>';
  //<!-- cancel closes window -->
    buttonHtml += '<td>&nbsp;</td>\n<td class="button1Td"><button class="button1" type="button" onclick="'+cancelOnclickStr+'" onKeyDown="moveFocus(event,\'defaultButton\',\'null\')" id="cnclButton">'+thisModalCancelText+'</button></td>\n';
  }

  buttonHtml += '</tr>\n'
  buttonHtml += '</table>\n'

  // BEGIN confirm header
  var confirmH1 = document.createElement("H1");

  var alertImage = document.createElement("IMG");
  var headerMssgNode = document.createTextNode(headerMssg);

  confirmH1.className = 'warning';

  alertImage.src = commonImgRoot+'popupHeaders/warning.gif';
  alertImage.style.verticalAlign = 'middle';
  alertImage.width = '32';
  alertImage.height = '25';

  confirmH1.appendChild(alertImage);
  confirmH1.appendChild(headerMssgNode);
  // END confirm header

  // BEGIN button Table
  var buttonDiv =  document.createElement("DIV");

  buttonDiv.style.width = divWidth - 15;
  buttonDiv.innerHTML = buttonHtml;

  var lineBreak = document.createElement("BR");
  var confMssg = document.createTextNode(mssg);

  confNode.appendChild(confirmH1);
  confNode.appendChild(lineBreak);
  confNode.appendChild(confMssg);
  confNode.appendChild(buttonDiv);

  // add the confNode to the oModalParent (otherwise this will add a bunch of extra whitespace to the page)
  oModalParent.appendChild(confNode);
}

function getAdjustedMessageHeight(id)
{
  var heightOffset = 45;
  if(!is.ie) // if not IE, adjust the offset accordingly
  {
  heightOffset = 63;
  }
  var sH = document.getElementById(id).scrollHeight;
  sH = sH + heightOffset;
  return sH;
}

function removeDialog(id)
{
  var node = document.getElementById(id);
  node.parentNode.removeChild(node);
  ModalWin.hide();
}
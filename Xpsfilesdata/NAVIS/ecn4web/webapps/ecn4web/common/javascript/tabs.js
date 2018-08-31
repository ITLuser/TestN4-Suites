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
* tabs implements tab functionality. The initial rev of this file is pertinent
* to subtabs only
*
*/

/*************************************************************************
***** Used by form subtabs to toggle content between tabs.
*****
***** NOTE:
*****   The DIV that is to be hidden and displayed needs to be linked to
***** the tab by way of naming the div "[tab.id]_content"
**************************************************************************
*****                                                                *****
***** This file depends upon the following JavaScript files:         *****
*****   -common.js                                                   *****
*****   -browserSniff.js                                             *****
*****   -ieEmulation.js                                              *****
*****                                                                *****
*************************************************************************/

var Tabs = new Object();

var onLeftImgSrc = commonImgRoot + 'tabs/tab1/activeTabCapLeft_bottom.gif';
var onRightImgSrc = commonImgRoot + 'tabs/tab1/activeTabCapRight_bottom.gif';
var offLeftImgSrc = commonImgRoot + 'tabs/tab1/tabCapLeft_bottom.gif';
var offRightImgSrc = commonImgRoot + 'tabs/tab1/tabCapRight_bottom.gif';

var focusTab = undefined;
var defaultSubTab = undefined;

function TabSet(id)
{
this.id = id;
this.tabs;
}

function tabClick(evt)
{
obj = getSrcEl(evt);

if(obj.nodeName != 'TD')
  { // user may click on the TD or the ANCHOR
  obj = obj.parentNode
  }

updateSubTabsAndContent(obj)
}

function hideAllSubTabContent(obj)
{
for(i=0;i<Tabs[obj.id].tabs.length;i++)
  {
  if(Tabs[obj.id].tabs[i] != undefined)
    {
    document.getElementById(Tabs[obj.id].tabs[i].id + '_content').style.display = 'none';

    if(classNameExists(document.getElementById(Tabs[obj.id].tabs[i].id),'subTabTd_active'))
      {
      replaceClassName(document.getElementById(Tabs[obj.id].tabs[i].id),'subTabTd_active','subTabTd')
      }
      else if(classNameExists(document.getElementById(Tabs[obj.id].tabs[i].id),'tabTd_active'))
      {
      replaceClassName(document.getElementById(Tabs[obj.id].tabs[i].id),'tabTd_active','tabTd')
      }

    document.getElementById(Tabs[obj.id].tabs[i].id + '_left').childNodes[0].src = offLeftImgSrc;
    document.getElementById(Tabs[obj.id].tabs[i].id + '_right').childNodes[0].src = offRightImgSrc;
    }
  }
}

function updateSubTabsAndContent(obj)
{
if(!obj) return;

tabTable = obj.parentNode.parentNode.parentNode;

hideAllSubTabContent(tabTable);

document.getElementById(obj.id + '_content').style.display = 'inline';

document.getElementById(obj.id + '_left').childNodes[0].src = onLeftImgSrc;
document.getElementById(obj.id + '_right').childNodes[0].src = onRightImgSrc;

replaceClassName(obj,'subTabTd','subTabTd_active')

replaceClassName(obj,'tabTd','tabTd_active')

}

function initSubTabs()
{

if(isFinishedIntializing)
{
  if(focusTab != undefined)
    {
    updateSubTabsAndContent(document.getElementById(focusTab))
    }
  else
    {
    updateSubTabsAndContent(document.getElementById(defaultSubTab))
    }
}
else
{
setTimeout("initSubTabs()", 100)
}

}


/*
* The following functionality allows for the toggling of
* sub-content by way of a radio button
*
* Looks for a div with a class of 'subContentToggle' to initialize.
* Must use the standard form table.
* Looks for a radio button in the tableTitle TD.
*
*/
var subTables = new Array();
function initSubContentToggle(obj)
{
var inputs = obj.getElementsByTagName('input');
var tables = obj.getElementsByTagName('table');
for(ii=0; ii < inputs.length; ii++)
{
if(inputs[ii].type == 'radio' && classNameExists(getParentEl(inputs[ii] ,'TD'),'tableTitle'))
  {
  addEvent(inputs[ii], 'click', updateTextInputs)
  removeEvent(inputs[ii],'unload',updateTextInputs)
  }
}
for(jj=0;jj<tables.length;jj++)
{
if(classNameExists(tables[jj],'formTable'))
  {
  subTables[subTables.length] = tables[jj]
  disableChildrenInputs(tables[jj].tBodies[0])
  }
}
if(subTables.length > 0) enableChildrenInputs(subTables[0].tBodies[0]);
}

function updateTextInputs(evnt)
{
evt = getEvent(evnt)
el = getSrcEl(evt)

elParentTable = getParentEl(getParentEl(el ,'TH') ,'TABLE');

for(i=0; i<subTables.length; i++)
  {
  if(subTables[i] == elParentTable)
    {
    enableChildrenInputs(elParentTable.tBodies[0]);
    }
    else
    {
    disableChildrenInputs(subTables[i].tBodies[0]);
    }
  }
}


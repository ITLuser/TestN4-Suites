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
*
* globalHandlers attaches eventHandlers to DOM objects.
*
*/

/*
* TO DO:
*   None.
*/

/*
* IMPLEMENTATION NOTES:
* Parameters:
*   None.
*
*   These scripts are for internal reference only.
*
* Requires:
*   See each "attach" block for dependencies.
*/

function initHandlers(obj)
{
  //This function generally performs event bindings onload using the document obj as its root.
  //However, it is sometimes necessary to run another set of event bindings on some object
  //AFTER page load--as might be necessary after generating a DOM branch dynamically, sometime after
  //initial page load.  To do this, simply pass in the object you would like this function to
  //crawl through.

  obj = (obj) ? obj : document;

  //TODO: remove this hack
  if (obj != document)
  {
    obj = obj.parentNode;
  }

  var oAll
  if(!document.all && !is.ie6)
  {
  oAll = obj.getElementsByTagName('*');
  }
  else
  {
  oAll =  obj.all
  }

  //TODO: the following doesn't seem to be working correctly.
  //oAll[oAll.length] = obj; //be sure to include the root object itself

  // Before starting loop, calculate constant values just once
  var bindStatusMssg = (window.setStatus && window.clearStatus);
  var bindTips = (window.showTip && window.hideTip);
  var bindCalendar = (window.setCalTimeout && window.clearCalTimeout && window.showCal);
  var bindInputHighlight = (window.paintInputHighlight);
  var bindAutocomplete = (window.lovAutoComplete);

  for (i=0;i<oAll.length;i++)
  {
    var curObj = oAll[i];

	//Form Inputs
    if(curObj.tagName == "INPUT" && (curObj.type=="text" || curObj.type=="password"))
	{
    //give inputs an accent color when in focus
	  if(classNameExists(curObj,'lovInput') && bindAutocomplete)
      {
        curObj.onkeypress = lovInputOnKeyPress;
        curObj.onkeydown = lovInputOnKeyDown;
        curObj.onkeyup = lovInputOnKeyUp;
        curObj.onclick = lovInputOnClick;
        addEvent(curObj,"blur",lovInputOnBlur);
      }
      if(bindInputHighlight)
      {
        addEvent(curObj,"blur",wipeInputHighlight);   //remove accent color
	    addEvent(curObj,"focus",paintInputHighlight); //add accent color
	  }
	}

	if(curObj.tagName == "TEXTAREA" && bindInputHighlight)
	{
      addEvent(curObj,"blur",wipeInputHighlight);   //remove accent color
	  addEvent(curObj,"focus",paintInputHighlight); //add accent color
	}

    if(curObj.getAttribute('statusmssg') && (bindStatusMssg))
    // test for setStatus and clearStatus
    {
      curObj.onmouseover = setStatus;
      curObj.onmouseout  = clearStatus;
    }

    if(curObj.getAttribute('tip') && bindTips)
    // test for showTip and hideTip
    {
      addEvent(curObj,"mousemove",showTip);
      addEvent(curObj,"mouseout",hideTip);
	  curObj.setAttribute('title','',0); //wipe the title attribute
	  //curObj.setAttribute('ALT',curObj.getAttribute('tip')); //set alt attribute to the value of the tip
    }
    /*else
    {
        //required when dynamically removing a tip
        curObj.onmousemove = '';
      curObj.onmouseout = '';
    }*/

    if(curObj.getAttribute('calendar') && (window.setCalTimeout && bindCalendar))
    // test for setCalTimeout and clearCalTimeout showCal
    {
      curObj.onmouseover = clearCalTimeout;
      curObj.onmouseout = setCalTimeout;
      curObj.onclick = showCal;
    }

    if((curObj.getAttribute('cmssg')) && (window.showStandardConfirm))
    // test for setCalTimeout and clearCalTimeout showCal
    {
      if(curObj.getAttribute('onclick') && (!curObj.getAttribute('cfunc') && !curObj.getAttribute('curl')))
     // if it already has an onclick, strip it and pass it in as cfunc
	 {
        lside = curObj.onclick.toString().indexOf('{') + 1;
        rside = curObj.onclick.toString().lastIndexOf('}') - 1;
        oStr1 = curObj.onclick.toString().substring(lside,rside)
        oStr2 = oStr1.replace(/"/g , "'"); //'
        curObj.setAttribute('cfunc',oStr2)
      }
      curObj.onclick = showStandardConfirm;
    }

    if(classNameExists(curObj,'sortable') && window.colClick)
    // test for sortable column header and attach the colClick function to the onclick event
    {
      curObj.onclick = colClick;
      var clickedTable = getParentEl(curObj, 'TABLE', 'BODY');

      if(!clickedTable.id)
      {
        clickedTable.id = 'SortTable' + SortTablesArray.length;
      }
      var curSortTable = getSortTable(clickedTable.id);
    }

    //for interactive table rows
    if(window.initSelectRowObj && classNameExists(curObj,'selectRow') && curObj.tagName == "TR")
    {
      initSelectRowObj(curObj)
    }

    if(curObj.getAttribute('expandWidget') && window.initExpandWidget)
    // expand/collapse sub-forms
    {
      getExpandWidget(curObj.getAttribute('expandWidget'));
    }
    if(classNameExists(curObj,'tabTable') && window.updateSubTabsAndContent)
        {
          tabTds = curObj.getElementsByTagName('TD');

          Tabs[curObj.id] = new TabSet(curObj.id);

          tabArray = new Array();
          for(k=0;k<tabTds.length;k++)
          {
            if(tabTds[k].className == 'subTabTd' || tabTds[k].className == 'subTabTd_active')
            // currently there is no functionality associated w/ top level tabs.
            {
              tabTds[k].onclick = tabClick;
              tabArray[tabArray.length] = tabTds[k];
           }
          }
          if(tabArray.length > 0)
          {
          Tabs[curObj.id].tabs = tabArray;
          defaultSubTab = tabArray[0].id
          }
        }

    if(curObj.getAttribute('menuId') && window.buttonClick)
    // expand/collapse sub-forms
    {
      curObj.onclick = buttonClick;
    }

    if(classNameExists(curObj,'tabTable') && window.updateSubTabsAndContent)
    {
      tabTds = curObj.getElementsByTagName('TD');

      Tabs[curObj.id] = new TabSet(curObj.id);

      tabArray = new Array();
      for(k=0;k<tabTds.length;k++)
      {
        if(tabTds[k].className == 'subTabTd' || tabTds[k].className == 'subTabTd_active')
        // currently there is no functionality associated w/ top level tabs.
        {
          tabTds[k].onclick = tabClick;
          tabArray[tabArray.length] = tabTds[k];
       }
      }
      if(tabArray.length > 0)
      {
      Tabs[curObj.id].tabs = tabArray;
      defaultSubTab = tabArray[0].id
      }
    }

    if(classNameExists(curObj,'dynalistBorder') && window.initDragObj)
    {
      addEvent(curObj,"mousedown",dragStart);
      addEvent(curObj,"mousemove",dragMode);
    }

    if(classNameExists(curObj,'subContentToggle'))
    {
      initSubContentToggle(curObj);
    }

  }//end for loop

  isFinishedIntializing = true;

}

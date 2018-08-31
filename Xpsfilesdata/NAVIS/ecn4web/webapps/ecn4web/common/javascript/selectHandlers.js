/*
* @(#)selectHandlers.js
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
* selectHandlers binds selected items to functionality
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
*
*		NOTE:
*
*	Requires:
*		globalHandler.js
*/
var hasRows = false;
var selectedRow = new Object;
selectedRow.obj = null;
selectedRow.id = null;
selectedRow.origClassName = null;
var selectedCss = 'selectedRow';

function setSelectedRow(e)
{
initalEl = getSrcEl(e)

srcEl = getParentEl(initalEl,'TR');

if(top.selectedRow.obj != srcEl)
		{
		// reset the current selected object's classname to the original
		if(top.selectedRow.obj != null)
			{
			top.selectedRow.obj.className = top.selectedRow.origClassName;
			}
		// set the selected object to the current srcEl
		top.selectedRow.obj = srcEl;
		top.selectedRow.origClassName = srcEl.className;
		// test if the rowKey is set, if so grab it
		if(srcEl.getAttribute('rowKey'))
			{
			top.selectedRow.id = srcEl.getAttribute('rowKey');
			}
		// set the classname
		srcEl.className = selectedCss;
		}
else
		{
		//reset the classname
		top.selectedRow.obj.className = top.selectedRow.origClassName;
		resetSelectedRow()
		}
if(window.setToolbar)
	{
	setToolbar();
	}
}

function resetSelectedRow()
{
	top.selectedRow.obj = null;
	top.selectedRow.origClassName = null;
	top.selectedRow.id = null;
}

function setRowClassOn(e)
{
initalEl = getSrcEl(e)

srcEl = getParentEl(initalEl,'TR');

if(srcEl.className == 'odd' || srcEl.className == 'even')
	{
	srcEl.className = 'rowHover';
	}
}

function setRowClassOff(e)
{
initalEl = getSrcEl(e);

srcEl = getParentEl(initalEl,'TR');

if(srcEl.className == 'rowHover')
	{
	srcEl.className = 'odd';
	}
}
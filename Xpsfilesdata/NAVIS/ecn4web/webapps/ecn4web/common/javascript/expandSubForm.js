//TODO: Clicking on <td>'s border throws exception.
//TODO: it is possible to trigger onclick on the td without clicking the link.  fix this.

/************************************************************************/
/**** GLOBAL VARIABLES                                               ****/
/************************************************************************/

//objects
var ExpandWidgets      = new Object();
var ExpandWidgetsArray = new Array();


/************************************************************************/
/**** CONSTRUCTORS                                                   ****/
/************************************************************************/

function expand(id)
{
  //properties
  this.id             = id;
  this.obj            = null;
  this.linkObj        = null;
  this.inputObj       = null;
  this.hiddenInputObj = null;  //allows state to be preserved on refresh
  this.subFormObj     = null;
  this.expanded       = false;
  
  //methods
  this.toggle               = expandToggle;
  this.expand               = expandWidget;
  this.collapse             = collapseWidget;
  this.expandSubForm        = expandSubForm;
  this.collapseSubForm      = collapseSubForm;
  this.enableSubFormInputs  = enableSubFormInputs;
  this.disableSubFormInputs = disableSubFormInputs
}

/************************************************************************/
/**** FUNCTIONS                                                      ****/
/************************************************************************/

function expandToggle(e)
{  
  var e         = getEvent(e);
  var oObj      = getParentEl(getSrcEl(e),'TD','TABLE');
  var oExpandId = oObj.getAttribute('expandWidget');
  var oExpand   = getExpandWidget(oExpandId);
 
  if (oExpand.expanded)
  {
    oExpand.collapse(); //if expanded, collapse it
  }
  else
  {
    oExpand.expand(); //if collapsed, expand it
  }
	// will fix the issue of changing content dynamically when the top element has a height of 100%
	mozResizeFix();
}

function getExpandWidget(id)
{
  if (!ExpandWidgets[id])
  {
    initExpandWidget(id);
  }
  return ExpandWidgets[id];
}

function initExpandWidget(id)
{
  ExpandWidgets[id] = new expand(id);
  ExpandWidgetsArray[ExpandWidgetsArray.length] = ExpandWidgets[id];
  oExpand = ExpandWidgets[id];
  
  oExpand.obj            = document.getElementById(id);
  oExpand.linkObj        = document.getElementById(oExpand.obj.getAttribute('expandLink'));
  oExpand.hiddenInputObj = document.getElementById(oExpand.obj.getAttribute('expandHiddenInput'));
  oExpand.inputObj       = oExpand.obj.getAttribute('expandInput')!='' &&document.getElementById(oExpand.obj.getAttribute('expandInput')) ? document.getElementById(oExpand.obj.getAttribute('expandInput')) : null;
  oExpand.subFormObj     = document.getElementById(oExpand.obj.getAttribute('expandSubFormBody'));
  
  //get stored expanded/collapsed state
  if(oExpand.hiddenInputObj.value=="1") //expanded
  {
    oExpand.expand();
  }
  else
  {
    oExpand.collapse();
  }
  //get state of checkbox
  if(oExpand.inputObj && oExpand.inputObj.checked) //enabled
  {
    oExpand.enableSubFormInputs();
  }
  else if(oExpand.inputObj)
  {
    oExpand.disableSubFormInputs();
  }
}

// open/expand the sub-form
function expandWidget()
{
  replaceClassName(this.obj,'collapseTd1','collapseTd1_expanded');
  this.expanded = true;
  this.hiddenInputObj.value = "1";
  this.expandSubForm();
  this.linkObj.blur();
}

// close/collapse the sub-form
function collapseWidget()
{
  replaceClassName(this.obj,'collapseTd1_expanded','collapseTd1');
  this.expanded = false;
  this.hiddenInputObj.value = "0";
  this.collapseSubForm();
  this.linkObj.blur();
}

function expandSubForm()
{
  var oTBody = this.subFormObj;
 
  oTBody.style.display = "";
}

function collapseSubForm()
{
  var oTBody = this.subFormObj;
 
  oTBody.style.display = "none";
}

function toggleSubForm(e)
{ 
  var e         = getEvent(e);
  var oObj      = getSrcEl(e);
  var oExpandId = oObj.getAttribute('expandWidget');
  var oExpand   = getExpandWidget(oExpandId);
  
  if (oExpand.inputObj.checked)
  {
    //if checkbox is checked, expand and enable all inputs
    if(!oExpand.expanded) oExpand.expand();
    oExpand.enableSubFormInputs();
    setFirstChildFocus(oExpand.subFormObj);
  }
  else
  {
    if(oExpand.expanded) oExpand.collapse();
    oExpand.disableSubFormInputs();
  }
	// will fix the issue of changing content dynamically when the top element has a height of 100%
	mozResizeFix();
}

function enableSubFormInputs()
{
  enableChildrenInputs(this.subFormObj);
}

function disableSubFormInputs()
{
  disableChildrenInputs(this.subFormObj);
}

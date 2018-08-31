/************************************************************************/
/**** Used to add/delete detail lines to a master-detail form.       ****/
/****                                                                ****/
/************************************************************************/
/****                                                                ****/
/**** This file depends upon the following JavaScript files:         ****/
/****   -common.js                                                   ****/
/****   -ieEmulation.js                                              ****/
/****                                                                ****/
/************************************************************************/


/************************************************************************/
/**** Variables                                                      ****/
/************************************************************************/
//images
var rOnSrc = commonImgRoot + 'icons/deleteLine.gif';
var rOffSrc = commonImgRoot + 'icons/deleteLine_disabled.gif';
var aOnSrc = commonImgRoot + 'icons/addLine.gif';
var aOffSrc = commonImgRoot + 'icons/addLine_disabled.gif';

//parameters
var defaultArMaxRows   = "175";  //set to '*' for unlimited.  Otherwise specify an Int.
var defaultArErrorMssg = 'An error has occurred.';
var defaultResetValues = false;

var currentlyAdding = false;

//objects
var ArTables       =  new Object();
var ArTablesArray  =  new Array();

/************************************************************************/
/**** Constructors                                                   ****/
/************************************************************************/
function ArTable(id)
{
    this.id = id;
    this.obj = document.getElementById(id);
    this.tbody = this.obj.tBodies[0];
    this.bodyRows = this.tbody.rows;
    this.maxRows = defaultArMaxRows;
    this.on = false;
    this.hasError = false;
    this.errorMssg =  defaultArErrorMssg;
    this.templateRow = null;
    this.rowCount = this.bodyRows.length; //Used as incrementor to generate unique input names.  Does not track real row count.

    //methods
    this.updateArButtons = updateArButtons;
    this.setRowCounter = setRowCounter;
    this.updateTable = updateAddRemoveTable;
}

/************************************************************************/
/**** Functions                                                      ****/
/************************************************************************/
function getSrcRow(e)
{
    var e = getEvent(e);
    var srcEl = getSrcEl(e);
    var srcRow = getParentEl(srcEl, 'TR', 'TABLE');
    return srcRow;
}

function getArTable(id)
{
    if (!ArTables[id])
    {
      ArTables[id] = new ArTable(id);
      for (var i=0; i<ArTables[id].tbody.rows.length; i++)
      {
          if (ArTables[id].tbody.rows[i].getAttribute('hiddenRow') == 'hiddenRow')
          {
              ArTables[id].templateRow = ArTables[id].tbody.rows[i];
              break;
          }
      }
      if (!ArTables[id].templateRow)
      {
          alert('ERROR! Add/Remove Widget could not initialize.');
          ArTables[id] = null;
      }
      ArTablesArray[ArTablesArray.length] = ArTables[id];
    }
    return ArTables[id];
}

function setRowCounter()
{
    var rowCounterInput;

    if (getFormInput('rowCount') != null)
    {
        rowCounterInput = this.tbody.rows.length - 1; //current count of the body rows minus the hidden row
        getFormInput('rowCount').value = rowCounterInput;
    }
}

function addNewRow(e)
{
if(currentlyAdding) return;
currentlyAdding = true;

var srcRow = getSrcRow(e);
var srcTable = getParentEl(srcRow,'TABLE','BODY');
var newRow,rowCount,oTable;

if(!srcTable.id)
  {
  srcTable.id = 'ArTable' + ArTablesArray.length;
  }
oTable = getArTable(srcTable.id);
if(oTable == null) return;

rowCount = oTable.rowCount;
// only stop if the limit has been hit
if(oTable.maxRows != "*" && oTable.bodyRows.length > oTable.maxRows)
  {
  alert('Item limit reached.  No more than ' + oTable.maxRows + ' items allowed.');
  currentlyAdding = false;
  return;
  }
newRow = oTable.templateRow.cloneNode(true);
srcRow.insertAdjacentElement("afterEnd", newRow);
scrubRow(newRow,rowCount);
initHandlers(newRow);
newRow.style.display = '';
setFirstChildFocus(newRow);
oTable.rowCount++;
oTable.updateTable();
// will fix the issue of changing content dynamically when the top element has a height of 100%
mozResizeFix();
currentlyAdding = false;
}

function killRow(e)
{
    var srcRow = getSrcRow(e);
    var srcTable = getParentEl(srcRow,'TABLE','BODY');
    var oTable = getArTable(srcTable.id);
    var focusRow;

    if(oTable == null) return;
    if (oTable.bodyRows.length-1 < 2) //only one left
    {
        alert('The last item cannot be deleted.');
        return;

    }
    //if there is another row after the one to delete, set focus on it.  Otherwise, set focus on row prior to the one to delete.
    focusRow = (oTable.obj.rows[srcRow.rowIndex + 1] && oTable.obj.rows[srcRow.rowIndex + 1].style.display != 'none') ? (oTable.obj.rows[srcRow.rowIndex + 1]) : oTable.obj.rows[srcRow.rowIndex - 1];
    setFirstChildFocus(focusRow);
    oTable.obj.deleteRow(srcRow.rowIndex);
    oTable.updateTable();
}

function updateAddRemoveTable()
{
    this.updateArButtons();
    this.setRowCounter();

    //the following will force the session check iframe to refresh, which will redirect the page to login if the session has timed out.
     if(document.getElementById('sessionCheckIframe'))
     {
       oIframe = document.getElementById('sessionCheckIframe');
       oIframe.src = oIframe.src;
     }
}

function resetArInputValues(r){
    /**
    **
    **  NOTE:
    **    This code assumes a prefix of "value(" and a suffix of ")" is to be applied to
    **    a given form field's name. This can be extended to provide for other options.
    **/

    var val;      // placeholder for the new field name
    var subCells; //placeholder for a subtable's cells within the row
    var pChild = new Array();

    if (r.getElementsByTagName('INPUT').length > 0) pChild[pChild.length] = r.getElementsByTagName('INPUT');
    if (r.getElementsByTagName('SELECT').length > 0) pChild[pChild.length] = r.getElementsByTagName('SELECT');
    if (r.getElementsByTagName('TEXTAREA').length > 0) pChild[pChild.length] = r.getElementsByTagName('TEXTAREA');

    for (var i=0; i<pChild.length; i++)
    {
        for (var j=0; j<pChild[i].length; j++)
        {
            resetInput(pChild[i][j]);
        }
    }
}

function resetInput(obj)
{
    //clear the value
    switch(obj.tagName) {
    case 'SELECT':
      obj.options.selectedIndex = -1;
      break;
    case 'INPUT':
      if(obj.type == 'radio' || obj.type == 'checkbox') obj.selected = false;
      else obj.value = '';
      break;
    case 'TEXTAREA':
      obj.value = '';
      break;
  }
}

function scrubRow(r,rowCount)
{
  //In IE row-scrubing can only be accomplished AFTER the row has been appended to the DOM.  This unfortunate limitation is not an issue in Moz.
  var curCell,innerHTMLstr;

  //strip out the string "0000" wherever it is found in the row, and replace it with a serialized number, corresponding with current rowCount
  for (var i=0; i<r.cells.length; i++)
  {
    curCell = r.cells[i];
    innerHTMLstr = curCell.innerHTML.replace(/0000/g,rowCount);
    curCell.innerHTML = innerHTMLstr;

    //Also scrub the cell id if there is one
    var newId = curCell.id.replace(/0000/g,rowCount);
    curCell.id = newId;
  }
  if(defaultResetValues)
  {
    resetArInputValues(r);
  }
  r.setAttribute('hiddenRow',null);
  //TODO: find some way to generically scrub attributes on the TR and TDs themselves.
  //TODO: add tooltips to add/remove buttons and give each a unique ID
}

function updateArButtons()
{
//set button src by state
var curRowCount = this.bodyRows.length-1;
if (curRowCount == 1)
  {
  //if there is only one row left, disabled the delete button
  for(i=0; i<this.bodyRows[0].getElementsByTagName('IMG').length; i++)
    {
    var curImg = this.bodyRows[0].getElementsByTagName('IMG')[i];
    if(curImg.name == 'deleteRow')
      {
      curImg.src = rOffSrc;
      }
    }
  }
  else if (this.maxRows != "*" && (curRowCount >= this.maxRows))
  {
  //if number of items has reached max, disable all add buttons
  for(i=0; i<curRowCount; i++)
    {
    if (this.bodyRows[i].getAttribute('hiddenRow') != 'hiddenRow')
      {
      for(j=0; j<this.bodyRows[i].getElementsByTagName('IMG').length; j++)
        {
        var curImg = this.bodyRows[i].getElementsByTagName('IMG')[j];
        if(curImg.name == 'addRow')
          {
          curImg.src = aOffSrc;
          }
        }
      }
    }
  }
  else
    {
    //otherwise, enable all buttons
    for(i=0; i<curRowCount; i++)
      {
      if (!this.bodyRows[i].getAttribute('hiddenRow'))
        {
        for(j=0; j<this.bodyRows[i].getElementsByTagName('IMG').length; j++)
          {
          var curImg = this.bodyRows[i].getElementsByTagName('IMG')[j];
          if(curImg.name == 'deleteRow')
            {
            curImg.src = rOnSrc;
            }
            else if(curImg.name == 'addRow')
            {
            curImg.src = aOnSrc;
            }
          }
        }
      }
    }
//TODO: make sure tooltip for each button is updated according to button state
}

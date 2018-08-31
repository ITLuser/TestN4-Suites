/************************************************************************/
/**** JavaScript for sorting a table by column header.               ****/
/****                                                                ****/
/************************************************************************/
/****                                                                ****/
/**** This file depends upon the following JavaScript files:         ****/
/****   -common.js                                                   ****/
/****   -browserSniff.js                                             ****/
/****                                                                ****/
/****                                                                ****/
/************************************************************************/
/****                                                                ****/
/**** USAGE                                                          ****/
/**** ListTables usually have at least one sortable column.          ****/
/**** Clicking a sortalbe column executes the following javascript   ****/
/**** which looks inside each cell's contents for a string to use    ****/
/**** for simple string comparisons.  If a string is not present,    ****/
/**** the JavaScript will look for an input or image.  If either     ****/
/**** are found, the input's value or the image's alt string is      ****/
/**** used instead.  Very often, the default string comparisons are  ****/
/**** not enough, and the developer will want to do numeric, time,   ****/
/**** date, etc. comparisons instead.  To do this, the parent cell   ****/
/**** can take an "expando" attribute called "sortValue". If         ****/
/**** present, the string inside the sortValue attribute is used     ****/
/**** for comparisons instead, overriding the default sort string.   ****/
/**** Note that even when a sortValue attribute is used, the         ****/
/**** JavaScript will still only perform string comparisons.         ****/
/****                                                                ****/
/************************************************************************/

/************************************************************************/
/**** Variables                                                      ****/
/************************************************************************/

//images
var ascendingImg = commonImgRoot + 'sortAscending.gif';
var descendingImg = commonImgRoot + 'sortDescending.gif';
var blankSortImg = commonImgRoot + 's.gif';

//objects
var SortTables = new Object();
var SortTablesArray = new Array();
var SortCols = new Object();

//variables
var sortableHeadRow = null;
var sortableColCount = null;
var reverse = false;
var lastclick = -1;    // stores the last used object
var oTR = null;
var oStatus = null;
var none = 0;
var sortImgHeight = 7;
var sortImgWidth = 12;
var caseInsensitive = true;

/************************************************************************/
/**** Constructors                                                   ****/
/************************************************************************/

function SortTable(id)
{
  this.id = id;
  this.obj = document.getElementById(id);
  this.headRow = this.obj.tHead.rows[this.obj.tHead.rows.length -1]; //Assume that bottom-most header row is the column header row
  this.SortColsArray = new Array();
  this.tbody = this.obj.tBodies[0];
  this.bodyRows = this.tbody.rows;

  //methods
  this.init = initTable;
  this.colorRows = colorRows;
}

function SortCol(id,c)
{
  this.id = id;
  this.obj = c;
  this.reverse = true;
  this.colIndex;
  this.sortImg = new Image(sortImgWidth,sortImgHeight);
  this.sortImg.src = blankSortImg;
}

/************************************************************************/
/**** Functions                                                      ****/
/************************************************************************/
function getSortTable(id)
{
  if (!SortTables[id])
  {
    SortTables[id] = new SortTable(id);
    SortTablesArray[SortTablesArray.length] = SortTables[id];
    SortTables[id].init();
  }
  return SortTables[id];
}

function getSortCol(t,c)
{
  if (c.id == "" || c.id == undefined || !c.id)
  {
    c.id = t.id + '_col' + t.SortColsArray.length;
  }
  if (!SortCols[c.id])
  {
    SortCols[c.id] = new SortCol(c.id,c);
    SortCols[c.id].obj.insertAdjacentElement('beforeEnd', SortCols[c.id].sortImg);
    SortCols[c.id].sortImg.width = sortImgWidth;
    SortCols[c.id].sortImg.height = sortImgHeight;
  }
  return SortCols[c.id];
}

function initTable()
{
  var colCount = this.headRow.cells.length;

  //initialize columns;
  for (var j=0; j<colCount; j++)
  {
    if(this.headRow.cells[j].className.indexOf('sortable') > -1)
    {
      var newCol = getSortCol(this, this.headRow.cells[j]);
      newCol.colIndex = getColIndex(this.headRow,newCol);
      this.SortColsArray[this.SortColsArray.length] = newCol;
    }
  }
}

function colClick(e)
{
	try
		{
		//fires when a sortable column header is clicked

		var srcEl = getSrcEl(e);
		var clickedCol  = getParentEl(srcEl, 'TH', 'TABLE');
		var clickedTable = getParentEl(clickedCol, 'TABLE', 'BODY');
		var curSortTable = getSortTable(clickedTable.id);
		var curSortCol = SortCols[clickedCol.id];
		var lastRow = null;

		//clear the sort images in the head
		for (var i=0; i<curSortTable.SortColsArray.length; i++)
		{
			// test
			SortTables[clickedTable.id].SortColsArray[i].sortImg.src = blankSortImg;
		}

		//set sort image
		curSortCol.reverse = (curSortCol.reverse) ? false : true;
		curSortCol.sortImg.src = (curSortCol.reverse) ? descendingImg : ascendingImg;

		//sortRows
		lastRow = (curSortTable.tbody.rows[curSortTable.tbody.rows.length-1]);
		insertionSort(curSortTable.tbody, lastRow, curSortCol.reverse, curSortCol);

		//color alternating row colors
		curSortTable.colorRows();
		}
  catch(e)
		{
		// do nothing
		}
}

function colorRows()
{

  for (var i=0; i<this.tbody.rows.length; i++)
  {
    this.tbody.rows[i].className = (isEven(i)) ? 'even' : 'odd';
  }
}

function getColIndex(headRow, col)
{
  for(i=0; i<headRow.cells.length; i++)
  {
    if(headRow.cells[i] == col.obj)
    {
      return i;
    }
  }
}

function getCompareValue(curEl)
{
  var compVal='';
  /*
  This function will find comparison strings in the following order:
  1) sortValue expando attribute in the parent TD
  2) value of first <input> in cell
  3) Text value of any selected <option> within the first <select> object
  4) alt text of the first <img> object
  5) tip text of the first <img> object
  */

  //TODO: get this working in cells where the first input is either an LOV or a hidden input.
  //TODO: get rid of UTC date.  With "sortval" now available, UTC is no longer necessary.
 /* if((curEl.getElementsByTagName('INPUT').length > 0) && (!curEl.getElementsByTagName('INPUT')[0].getAttribute('utcdate')) || (curEl.getElementsByTagName('INPUT').length > 0) && (curEl.getElementsByTagName('INPUT')[0].getAttribute('utcdate') && curEl.getElementsByTagName('INPUT')[0].getAttribute('utcdate') == 'undefined'))
  // this is NOT a date w/ a UTC value supplied
  {
    txt = curEl.getElementsByTagName('INPUT')[0].value;  //find the first input and use its value
  }
  else if((curEl.getElementsByTagName('INPUT').length > 0) && (curEl.getElementsByTagName('INPUT')[0].getAttribute('utcdate') && curEl.getElementsByTagName('INPUT')[0].getAttribute('utcdate') != 'undefined'))
  // this IS a date w/ a UTC value supplied
  {
    txt = curEl.getElementsByTagName('INPUT')[0].getAttribute('utcdate');  //find the first input and use its UTC value
  }*/
  if(curEl.getAttribute('sortValue'))
  {
    compVal = curEl.getAttribute('sortValue');
  }
  else if(curEl.getElementsByTagName('INPUT').length > 0)
  {
    compVal = curEl.getElementsByTagName('INPUT')[0].value;
  }
  else if(curEl.getElementsByTagName('SELECT').length > 0)
  {
    compVal = curEl.getElementsByTagName('SELECT')[0].options[curEl.getElementsByTagName('SELECT')[0].selectedIndex].text;  //find the first select and use the value of the currently selected option
  }
  else if(curEl.getElementsByTagName('IMG').length > 0 && curEl.getElementsByTagName('IMG')[0].getAttribute('alt'))
  {
    compVal = curEl.getElementsByTagName('IMG')[0].getAttribute('alt');  //find the first image and use its alt string
  }
  else if(curEl.getElementsByTagName('IMG').length > 0 && curEl.getElementsByTagName('IMG')[0].getAttribute('tip'))
  {
    compVal = curEl.getElementsByTagName('IMG')[0].getAttribute('tip');  //find the first image and use its tip string
  }
  else
  {
    compVal = curEl.innerText;
  }
  return compVal;
}

function insertionSort(tBod, lastRow, reverse, curSortCol)
{
  var iRowInsertRow, jRow, current, insert;
  var colIndex = curSortCol.colIndex;

  for (var i=0 ; i<tBod.rows.length; i++)
  {
    //TODO: store column clicks in an array to allow sorting on multiple columns by order clicked.
    var curCell = tBod.rows[i].cells[colIndex];

    //if the parent cell uses the sortValue attribute, this string will override any value within the cell when making comparisons.
    textRowInsert = getCompareValue(curCell);
    for (var j=0; j<=i ; j++)
    {
      var jCell = tBod.rows[j].cells[colIndex];
      textRowCurrent = getCompareValue(jCell);

      current = textRowCurrent;
      insert = textRowInsert;

      if (!isNaN(current) && !isNaN(insert))
      {
        // Numbers that start with zeros are interpretted as Octal by the
        // "eval()" interpreter. Let's make them all equivalent... NDP 12/04
        current = eval("1" + current);
        insert = eval("1" + insert);
      }

      else
      {
        current = (caseInsensitive) ? current.toUpperCase() : current;
        insert = (caseInsensitive) ? insert.toUpperCase() : insert;
      }

      if (((!reverse && insert < current) || ( reverse && insert > current) ) && (i != j) )
      {
        eRowInsert = tBod.rows[i];
        eRowWalk = tBod.rows[j];
        tBod.insertBefore(eRowInsert, eRowWalk);
        j = i; // done
      }
    }
  }
}

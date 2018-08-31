/************************************************************************/
/**** This widget is used to move items from one multiple select     ****/
/**** combo box to another.                                          ****/
/****                                                                ****/
/************************************************************************/
/****                                                                ****/
/**** This file depends upon the following JavaScript files:         ****/
/****   -form.js                                                     ****/
/****   -imageSwap.js                                                ****/
/****                                                                ****/
/************************************************************************/
function selectUnselectMatchingOptions(obj,regex,which,only)
{
  if (window.RegExp) {
    if (which == "select")
    {
      var selected1=true;
      var selected2=false;
    }
    else if (which == "unselect")
    {
      var selected1=false;
      var selected2=true;
    }
    else
    {
      return;
    }
    
    var re = new RegExp(regex);

    for (var i=0; i<obj.options.length; i++)
    {
      if (re.test(obj.options[i].text))
      {
        obj.options[i].selected = selected1;
      }
      else
      {
        if (only)
        {
          obj.options[i].selected = selected2;
        }
      }
    }
  }
}

function selectMatchingOptions(obj,regex)
{
  // Selects all options that match the regular expression passed in.
  // Currently-selected options will not be changed.
  
  selectUnselectMatchingOptions(obj,regex,"select",false);
}

function selectOnlyMatchingOptions(obj,regex)
{
  // selects all options that match the regular expression passed in.
  // Selected options that don't match will be un-selected.
  
  selectUnselectMatchingOptions(obj,regex,"select",true);
}

function unSelectMatchingOptions(obj,regex)
{
  // This function Unselects all options that match the regular expression
  // passed in. 
  
  selectUnselectMatchingOptions(obj,regex,"unselect",false);
}

function sortSelect(obj)
{
  // Pass this function a SELECT object and the options will be sorted
  // by their text (display) values

  var o = new Array();

  for (var i=0; i<obj.options.length; i++)
  {
    o[o.length] = new Option( obj.options[i].text, obj.options[i].value, obj.options[i].defaultSelected, obj.options[i].selected);
  }
  o = o.sort( 
    function(a,b)
    { 
      if ((a.text+"") < (b.text+"")) { return -1; }
      if ((a.text+"") > (b.text+"")) { return 1; }
      return 0;
    } 
  );
  
  for (var i=0; i<o.length; i++)
  {
    obj.options[i] = new Option(o[i].text, o[i].value, o[i].defaultSelected, o[i].selected);
  }
}

function selectAllOptions(obj)
{
  // Takes a select box and selects all options (in a multiple select object). 
  // This is used when passing values between two select boxes. Select all 
  // options in the right box before submitting the form so the values will
  // be sent to the server.
  
  for (var i=0; i<obj.options.length; i++)
  {
    obj.options[i].selected = true;
  }
}

function unSelectAllOptions(obj)
{
	obj.selectedIndex = -1;
}
  
function moveSelectedOptions(from,to,assignedList,storedList,sort,regex) {
  // This function moves options between select boxes. Works best with
  // multi-select boxes to create the common Windows control effect.
  // Passes all selected values from the first object to the second
  // object and re-sorts each box.
  
  // If a fifth argument of 'false' is passed, then the lists are not
  // sorted after the move.
  
  // If a sixth string argument is passed, this will function as a
  // Regular Expression to match against the TEXT or the options. If 
  // the text of an option matches the pattern, it will NOT be moved.
  // It will be treated as an unmoveable option.
  
  // You can also put this into the <SELECT> object as follows:
  //   onDblClick="moveSelectedOptions(this,this.form.target)
  
  // This way, when the user double-clicks on a value in one box, it
  // will be transferred to the other (in browsers that support the 
  // onDblClick() event handler).
  
  // Unselect matching options, if required
  if (regex)
  {
    if (regex != "")
    {
      unSelectMatchingOptions(from,regex);
    }
  }
  
  var newOptionsArray = new Array();
  // Move them over
  for (var i=0; i<from.options.length; i++)
  {
    var o = from.options[i];
	
    if (o.selected)
    {
      var newOption = new Option( o.text, o.value, false, false)
	  to.options[to.options.length] = newOption;
      //TODO: used with dirtyform support
	  //if(window.changes) changesMade();
      newOptionsArray[newOptionsArray.length] = newOption;
    }
  }
  
  // Delete them from original
  for (var i=(from.options.length-1); i>=0; i--)
  {
    var o = from.options[i];
    
    if (o.selected)
    {
      from.options[i] = null;
    }
  }
  
  unSelectAllOptions(to);
  unSelectAllOptions(from);
  
  for(var i=0; i<newOptionsArray.length; i++)
  {
  	newOptionsArray[i].selected = true;
  }
  if (sort && sort==true)
  {
    sortSelect(to);
  }
  
  storeSelectValues(assignedList,storedList);
}

function moveAllOptions(from,to,assignedList,storedList,sort,regex)
{
  // Move all options from one select box to another.
  
  selectAllOptions(from);
  moveSelectedOptions(from,to,assignedList,storedList,sort,regex);
}

function swapOptions(obj,i,j) {
  // Swap positions of two options in a select list

  var o = obj.options;
  var i_selected = o[i].selected;
  var j_selected = o[j].selected;
  var temp = new Option(o[i].text, o[i].value, o[i].defaultSelected, o[i].selected);
  var temp2= new Option(o[j].text, o[j].value, o[j].defaultSelected, o[j].selected);
  
  o[i] = temp2;
  o[j] = temp;
  o[i].selected = j_selected;
  o[j].selected = i_selected;
}

function moveOptionUp(to,assignedList,storedList) {
// Move selected option in a select list up one

  var selectedCount=0;
  
  for (var i=0; i<to.options.length; i++)
  {
    if (to.options[i].selected)
    {
      selectedCount++;
    }
  }
  
  // If more or less than 1 option selected, do nothing
  if (selectedCount != 1)
  {
    return;
  }
  
  // If this is the first item in the list, do nothing
  var i = to.selectedIndex;
  if (i == 0)
  {
    return;
  }
  
  swapOptions(to,i,i-1);
  to.options[i-1].selected = true;
  
  storeSelectValues(assignedList,storedList);
}

function moveOptionDown(to,assignedList,storedList) {
  // Move selected option in a select list down one

  // If > 1 option selected, do nothing
  var selectedCount=0;
  
  for (var i=0; i<to.options.length; i++)
  {
    if (to.options[i].selected)
    {
      selectedCount++;
    }
  }
  // If more or less than 1 option selected, do nothing
  if (selectedCount != 1)
  {
    return;
  }
  
  // If this is the last item in the list, do nothing
  var i = to.selectedIndex;
  if (i == (to.options.length-1))
  {
    return;
  }
  
  swapOptions(to,i,i+1);
  to.options[i+1].selected = true;

  storeSelectValues(assignedList,storedList);
}

function selectUpdateButtons(leftInput,rightInput,moveRightId,moveAllRightId,moveLeftId,moveAllLeftId)
{
  // TODO: implement the following
  
  return;
  
  var r  = document.getElementById(moveRightId);
  var ar = document.getElementById(moveAllRightId);
  var l = document.getElementById(moveLeftId);
  var al = document.getElementById(moveAllLeftId);
  
  //TODO: preload these images
  
  // LEFT input
  if (leftInput.options.length > 0) // there is at least one option in the left input
  {
    //TODO: initialize the allRight button onload
    //ar.src = commonImgRoot + 'buttons/moveAllRight.gif';
  }
  else {
    //ar.src = commonImgRoot + 'buttons/moveAllRight_disabled.gif';
  }
  if(leftInput.selectedIndex > -1) // at least one item is selected in the left input
  {
    r.src = commonImgRoot + 'buttons/moveRight.gif';
  }
  else
  {
    r.src = commonImgRoot + 'buttons/moveRight_disabled.gif';
  }
  
  // RIGHT input
  if (rightInput.options.length > 0) // there is at least one option in the right input
  {
    //TODO: initialize the allLeft button onload
    //al.src = commonImgRoot + 'buttons/moveAllLeft.gif';
  }
  else {
    //al.src = commonImgRoot + 'buttons/moveAllLeft_disabled.gif';
  }
  if(rightInput.selectedIndex > -1) // at least one item is selected in the right input
  {
    l.src = commonImgRoot + 'buttons/moveRight.gif';
  }
  else
  {
    l.src = commonImgRoot + 'buttons/moveRight_disabled.gif';
  }
}

function storeSelectValues(assignedList,storedList)
{
  var storedString = "";
  
  for(var i=0; i < assignedList.options.length; i++)
  {
    storedString += assignedList.options[i].value + ",";
  }
  
  storedList.value = storedString;
}

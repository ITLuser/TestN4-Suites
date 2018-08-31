/************************************************************************/
/**** Used by any resizable object.  By setting a class on any DOM   ****/
/**** object the developer can determine what type of drag-and-drop  ****/
/**** and/or resizing the object permits.                            ****/
/****                                                                ****/
/************************************************************************/
/****                                                                ****/
/**** This file depends upon the following JavaScript files:         ****/
/****   -common.js                                                   ****/
/****   -browserSniff.js                                             ****/
/****   -ieEmulation.js                                              ****/
/****                                                                ****/
/************************************************************************/

/************************************************************************/
/**** GLOBAL VARIABLES                                               ****/
/************************************************************************/
//parameters
var tol = 10;
var fudgeOffset = 0;
var dragPoint;
var dragIsOn = false;
var prevMONode = null;
var minHeight = 10;
var minWidth = 10;

//objects
var pCursor    = new Point();
var dragObj    = new Object();
dragObj.zIndex = 0;
DragObjs       = new Object();
DragObjsArray  = new Array();

//images
var defaultResizeHandle = commonImgRoot + 'images/resizeHandle.gif';

/************************************************************************/
/**** CONSTRUCTORS                                                   ****/
/************************************************************************/
function DragObj()
{
  this.obj     = null;
  this.zindex  = 0;
  this.metrics = null;
  this.pointer = null;
  
  this.allowDrag      = true;
  this.allowHorizDrag = true;
  this.allowVertDrag  = true;
  
  //resize attributes
  this.allowResize   = true;
  this.allowNresize  = true;
  this.allowNEresize = true;
  this.allowEresize  = true;
  this.allowSEresize = true;
  this.allowSresize  = true;
  this.allowSWresize = true;
  this.allowWresize  = true;
  this.allowNWresize = true;  
}


/************************************************************************/
/**** FUNCTIONS                                                      ****/
/************************************************************************/
function initDragObj(obj)
{  
  //give object an ID if it doesn't already have one
  var oId = (obj.id) ? obj.id : "dragObj" + DragObjsArray.length;
  
  DragObjs[oId] = new DragObj(oId);
  DragObjsArray[DragObjsArray.length] = DragObjs[oId]; 
  var dragObj = DragObjs[oId];
  
  //load properties
  
  

}

function getDragObj(id)
{
  if (!DragObjs[id])
  {
    initDragObj(id);
  }
  return DragObjs[id];
}


//-------------------------------------------------------------------
// Determine the result of a drag operation. It can either be:
//
// a) a move
// b) a create ( where the intial and final points of the mouse form the
//    coordinates of the div ).
// c) a resize ( where, if the cursor is found within a given tolerance of
//    a box dimension before the drag begins, the relevant resize action is
//    triggered.
//-------------------------------------------------------------------

function dragMode(event)
{

  // If we're in the middle of a drag, exit immediately. This
  // should have been disabled by detaching the mousemove event
  // from the element, but that doesn't seem to be working.
  
  if (dragIsOn) return (false);
  
  //alert(getSrcEl(event).tagName)
  //var dragObj = getDragObj(id);

  // Get the target element
  dragObj.obj = document.getElementById('lovExample3_menu');

  // Get the position of the cursor relative to the element.
  //getCursorPos(pCursor,event);

  // Calculate positions of the selected node, but only do this
  // the first time we mouse over this element (for better performance).

  if (dragObj.obj != prevMONode)
  {
    var elDim = getElMetrics(dragObj.obj);
    prevMONode = dragObj.obj;
    dragObj.metrics = elDim;
  }
  else 
  {
     var elDim = dragObj.metrics;
  }

  var topleft = elDim.topleft;
  var bottomright = elDim.bottomright;

  // Set the drag operation mode according to whether we're near a side or corner.
  if (Math.abs(topleft.x - getEventX(event)) <= tol)
  // Left edge
  {
     if (Math.abs(topleft.y - getEventY(event)) <= tol)
     {
     // Top left corner
       dragPoint = "topLeftCorner";
       dragCursor = 'nw-resize';
     }
     else if (Math.abs(bottomright.y - getEventY(event)) <= tol)
     // Bottom left corner
     { 
       dragPoint = "bottomLeftCorner";
       dragCursor = 'sw-resize';
     }
     else
     // Left edge
     { 
       dragPoint = "leftEdge";
       dragCursor = 'w-resize';
     }
  }
  else if (Math.abs(bottomright.x - getEventX(event)) <= tol)
  // Right edge
  {
    if (Math.abs(topleft.y - getEventY(event)) <= tol)
    // Top right corner
    {
      dragPoint = "topRightCorner";
      dragCursor = 'ne-resize';
    }
    else if (Math.abs(bottomright.y - getEventY(event)) <= tol)
    // Bottom right corner
    {
      dragPoint = "bottomRightCorner";
      dragCursor = 'se-resize';
    }
    else
    {
      dragPoint = "rightEdge";
      dragCursor = 'e-resize';
    }
  }
  else if (Math.abs(topleft.y - getEventY(event)) <= tol)
  {
  // Top edge
    if (Math.abs(topleft.x - getEventX(event)) <= tol)
    {
      dragPoint = "topLeftCorner";
      dragCursor = 'nw-resize';
    }
    else if (Math.abs(bottomright.x - getEventX(event)) <= tol)
    {
      dragPoint = "topRightCorner";
      dragCursor = 'ne-resize';
    }
    else
    {
      dragPoint = "topEdge";
      dragCursor = 'n-resize';
    }
  }
  else if (Math.abs(bottomright.y - getEventY(event)) <= tol)
  // Bottom edge
  {
     if (Math.abs(topleft.x - getEventX(event)) <= tol)
     // Top right corner
     {
       dragPoint = "bottomLeftCorner";
       dragCursor = 'sw-resize';
     }
     else if (Math.abs(bottomright.x - getEventX(event)) <= tol)
     {
       dragPoint = "bottomRightCorner";
       dragCursor = 'se-resize';
     }
     else
     {
       dragPoint = "bottomEdge";
       dragCursor = 's-resize';
     }
  }
  else 
  {
    dragPoint = "movePoint";
    dragCursor = 'move';
  }
  
  // Set the current cursor accordingly
  dragObj.obj.style.cursor = dragCursor;
}

//-------------------------------------------------------------------
// Start a drag operation.
//-------------------------------------------------------------------

function dragStart(event)
{
  var el;
  var x, y;
  
  dragObj.obj = document.getElementById('lovExample3_menu');

  // Get cursor position with respect to the page.
  getCursorPos(pCursor, event);

  // Save starting positions of cursor.

  dragObj.cursorStartX = getEventX(event);
  dragObj.cursorStartY = getEventY(event);
  
  // If an element is being operated on, store it's initial position. Otherwise,
  // this must be a new element so create it.

  if (dragObj.obj)
  {
    dragObj.elStartLeft = dragObj.obj.offsetLeft;
    dragObj.elStartTop  = dragObj.obj.offsetTop;
    dragObj.elWidth     = dragObj.metrics.bottomright.x - dragObj.metrics.topleft.x;
    dragObj.elHeight    = dragObj.metrics.bottomright.y - dragObj.metrics.topleft.y;
    
    if (isNaN(dragObj.elStartLeft)) dragObj.elStartLeft = 0;
    if (isNaN(dragObj.elStartTop))  dragObj.elStartTop  = 0;

    // Update element's z-index.

    dragObj.obj.style.zIndex = ++dragObj.zIndex;
  }

  // Capture mousemove and mouseup events on the page but disable the mousemove event
  // on the current element.

  removeEvent(dragObj.obj, "mousemove", dragMode);
  addEvent(document, "mousemove", dragGo);
  addEvent(document, "mouseup", dragStop);
  cancelEventPropagation(event);
  
  // Set a global to indicate that a drag is in progress.
  dragIsOn = true;
}

//-------------------------------------------------------------------
// Things to do while dragging.
//-------------------------------------------------------------------

function dragGo(event)
{
  // Get current cursor position with respect to the page.
  getCursorPos(pCursor, event);

  // Move or resize the drag element by the same amount the cursor has moved.

  var mdx = getEventX(event) - dragObj.cursorStartX;
  var mdy = getEventY(event) - dragObj.cursorStartY;
  var edx = 0;
  var edy = 0;
  dragNodeStyle = dragObj.obj.style;

  switch (dragPoint)
  {
    case "topLeftCorner":
      dragNodeStyle.left = (dragObj.elStartLeft + mdx) + "px";
      dragNodeStyle.top  = (dragObj.elStartTop  + mdy) + "px";
      edx = -mdx;
      edy = -mdy;
      break;
    case "topRightCorner":
      dragNodeStyle.top  = (dragObj.elStartTop  + mdy) + "px";
      edx = mdx;
      edy = -mdy;
      break;
    case "bottomLeftCorner":
      dragNodeStyle.left  = (dragObj.elStartLeft  + mdx) + "px";
      edx = -mdx;
      edy = mdy;
      break;
    case "bottomRightCorner":
      edx = mdx;
      edy = mdy;
      break;
    case "topEdge":
      dragNodeStyle.top  = (dragObj.elStartTop  + mdy) + "px";
      edx = 0;
      edy = -mdy;
      break;
    case "bottomEdge":
      edx = 0;
      edy = mdy;
      break;
    case "leftEdge":
      dragNodeStyle.left = (dragObj.elStartLeft + mdx) + "px";
      edx = -mdx;
      edy = 0;
      break;
    case "rightEdge":
      edx = mdx;
      edy = 0;
      break;
    case "movePoint":
      dragNodeStyle.left = (dragObj.elStartLeft + mdx) + "px";
      dragNodeStyle.top  = (dragObj.elStartTop  + mdy) + "px";
      edx = 0;
      edy = 0;
      break;
  }

  // Set the width and height from the difference between the new and old
  // div element dimensions.
  if (edx != 0 && (dragObj.elWidth + edx - fudgeOffset) > 0 && (dragObj.elWidth + edx - fudgeOffset) > minWidth) dragObj.obj.style.width = (dragObj.elWidth + edx - fudgeOffset) + "px";
  if (edy != 0 && (dragObj.elHeight + edy - fudgeOffset) > 0 && (dragObj.elHeight + edy - fudgeOffset) > minHeight) dragObj.obj.style.height  = (dragObj.elHeight + edy - fudgeOffset) + "px";
  
  // Stop event bubbling (so the object can keep moving)
  cancelEventPropagation(event);
}

//-------------------------------------------------------------------
// Stop the drag operation.
//-------------------------------------------------------------------

function dragStop(event)
{
  // Stop capturing mousemove and mouseup events but restore the onmousemove
  // event for the drag element.
  addEvent(dragObj.obj, "mousemove", dragMode);
  removeEvent(document, "mousemove", dragGo);
  removeEvent(document, "mouseup", dragStop);

  // Set the cached drag node to null so the size and position of the element get recalculated.
  prevMONode = null;

  // Set a global to indicate that a drag has finished.
  dragIsOn = false;
}

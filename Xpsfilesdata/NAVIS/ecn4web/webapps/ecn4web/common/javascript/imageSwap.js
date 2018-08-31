/************************************************************************/
/**** The following script is used to preload images into the DOM    ****/
/**** and swaping them with images rendered at initial load time.    ****/
/****                                                                ****/
/************************************************************************/
/****                                                                ****/
/**** This file depends upon the following JavaScript files:         ****/
/****   -none                                                        ****/
/****                                                                ****/
/************************************************************************/
/****                                                                ****/
/**** The following syntax should be used inside any object that     ****/
/**** should trigger an image swap:                                  ****/
/****                                                                ****/
/****     onmouseover="imgSwap('[imgId]','[filepath/fileName]');"    ****/
/****     onmouseout="imgRestore();"                                 ****/
/****                                                                ****/
/************************************************************************/

//objects
var SwapableImgs = new Object();

//variables
var imgRestoreArray = new Array();

/************************************************************************/
/**** Constructors                                                   ****/
/************************************************************************/

function SwapableImg(id,overSrc)
{
  // properties
  this.id = id;
  this.obj = 'undefined';
  this.origSrc = null;
  this.overSrc = overSrc ? overSrc : null;
  
  // methods
  this.setNewSrc = imgSetNewSrc;
  this.restoreOldSrc = imgRestoreOldSrc;
  this.initialize = initSwapableImg;
}


/************************************************************************/
/**** Functions                                                      ****/
/************************************************************************/
function preload() 
{
  if(document.images)
  { 
    if(!document.imgArray)
    {
      document.imgArray = new Array();
    }
    var j = document.imgArray.length;
    var a = arguments;
    for(var i = 0; i < a.length; i++)
    {
      document.imgArray[j] = new Image();
      document.imgArray[j++].src = a[i];
    }
  }
}

//TODO: this function name has been deprecated, but it is still used in some places.
function swapImg() 
{
  var a = arguments;
  for (var i=0; i<a.length; i+=2)
  {
    imgSwap(a[i],a[i+1]);
  }
}

function imgSwap() 
{
  var a = arguments;
  imgRestoreArray = new Array(); //reinitialize
  
  for (var i=0; i<a.length; i+=2)
  {
    var oImg = getSwapableImg(a[i],a[i+1]);
    oImg.setNewSrc();
    imgRestoreArray[i] = oImg;
  }
}

function imgRestore() 
{
  var a = imgRestoreArray;
  var oImg;

  for(var i=0; a && i < a.length; i++)
  {
    oImg = a[i];
    oImg.restoreOldSrc();
  } 
}

function imgSetNewSrc()
{
  this.obj.src = this.overSrc;
}

function imgRestoreOldSrc()
{
  this.obj.src = this.origSrc;
}

function getSwapableImg(id,overSrc)
{
  if (!SwapableImgs[id])
  {
    SwapableImgs[id] = new SwapableImg(id,overSrc);
    SwapableImgs[id].initialize();
  }
  return SwapableImgs[id];
}

function initSwapableImg()
{
    this.obj = document.getElementById(this.id) ? document.getElementById(this.id) : document.images[this.id];
    this.origSrc = this.obj.src;
    this.overSrc = this.overSrc ? this.overSrc : this.origSrc;
}
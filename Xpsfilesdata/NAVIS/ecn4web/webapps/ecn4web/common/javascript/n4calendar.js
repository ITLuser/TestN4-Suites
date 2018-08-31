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
* The N4Calendar is an extensible calendar interface.
* NCalendar was derived from the "DHTML Calendar" of
* Lea Smart, www.totallysmartit.com
* addDays, daysinyear, isLeapYear adapted from
* http://tech.irt.org/articles/js052/index.htm
*
/

/*
* IMPLEMENTATION NOTES:
*
*   to override i18n strings, include the following in the head of your output html:
*     overrideDaysOfWeek = new Array('ds','sd','d','23','sd','sd','sd');
*     overrideMonths = new Array('www','ww23','ws','2e','May','June','July','August','September','October','November','December');
*     overrideTodayStr = 'd324';
*
*   onclick where 'sfoo' is the id of a text element. this will use a valid date range:
*     <!-- BEGIN -->
*     NavisCalendar.show(event,'foo',new Date(2003,07,01),new Date(2003,07,17))
*     <!-- END -->
*
*       -or-
*
*   onclick where 'foo' is the id of a text element. without date range:
*     <!-- BEGIN -->
*     NavisCalendar.show(event,'foo')
*     <!-- END -->
*
*   to override the date format:
*     <!-- BEGIN -->
*     <script>
*       var dateFormatOverride = 'yyyy-mm-dd';
*         //options: 'dd-mmm-yyyy', 'dd-mon-yyyy', dd-mm-yyyy', 'mm-dd-yyyy', 'mon-dd-yyyy', 'yyyy-mm-dd', 'dd/mm/yyyy', 'mm/dd/yyyy'
*     </script>
*     <!-- END -->
*
*   onmouseover:
*     <!-- BEGIN -->
*     if (timeoutId) clearTimeout(timeoutId);window.status='Show Calendar';return true;
*     <!-- END -->
*
*   onmouseout:
*     <!-- BEGIN -->
*     if (timeoutDelay) navisCalendarTimeout();window.status=''
*     <!-- END -->
*/

// preload images
var imgUp = new Image(5,10);
imgUp.src = commonImgRoot + 'up.gif';
var imgDown = new Image(5,10);
imgDown.src = commonImgRoot + 'down.gif';

var defDaysOfWeek = new Array('Su','Mo','Tu','We','Th','Fr','Sa');
var defMonths = new Array('January','February','March','April','May','June','July','August','September','October','November','December');
var defTodayStr = 'today'
var overrideDaysOfWeek = false;
var overrideMonths = false;
var overrideTodayStr = false;

var myDaysOfWeek;
var myMonths;


var timeoutDelay = 1000; // milliseconds, change this if you like, set to 0 for the calendar to never auto disappear
var calStyleSheet = cssModuleRoot + 'calendar.css';
var useCalPopup = 0;
var calPopup = null;

// used by timeout auto hide functions
var timeoutId = false;


// dom browsers require this written to the HEAD section
document.write('<div id="container" class="calBgColor"');
if (timeoutDelay) document.write(' onmouseout="navisCalendarTimeout(event);" onmouseover="if (timeoutId) clearTimeout(timeoutId);"');
document.write(' width="116"></div>');


if(window.createPopup) //aware of popup object
{
  calPopup = window.createPopup();
  calPopup.document.createStyleSheet(calStyleSheet);
  calPopup.document.body.id = 'cPop';
  calPopup.document.body.style.color = '#000';

  // create even listeners to manage with popup
  calPopup.document.body.onmouseover = clearIt;
  calPopup.document.body.onmouseleave = timeIt;

  window.onfocus = killIt;
  // END create even listeners to manage with popup

  var popHTML = '<div id="containerPop" name="calPopDiv" style="position:absolute;top:0px;left:0px;z-index:100;visibility:visible;width:100%"></div>';

  calPopup.document.body.innerHTML = popHTML
  useCalPopup = 0; //TODO: Cal popup position is not working correctly.  Setting this to 0 until fixed.
}

var NavisCalendar;  // global to hold the calendar reference, set by constructor

function clearIt()
{
if (timeoutId)
  {
    clearTimeout(timeoutId);
  }
}

function timeIt()
{
  navisCalendarTimeout(calPopup.document.body.onmouseleave);
}

function listenToForms(){
// need to listen to the forms as well because the
// window events will not get caught
// TODO [8/8/2003]: this currently only affects fields that
//  allow text entry (ie, text, textarea.)
//  Need to expand to include other nodes
  for(i=0;i<document.forms.length;i++)
  {
    document.forms[i].onbeforeeditfocus = killIt;
  }
}

function killIt()
{
// close the NavisCalendar if the calPopup is open
// b/c the popup object closes as soon as it loses focus,
// there may be a lag btwn the closing of the popup object
// and the closing of the DropShadow.
  if(calPopup.isOpen == false)
  {
    NavisCalendar.hide()
  }
}

function navisCalendarTimeout(e)
{
  timeoutId=setTimeout('NavisCalendar.hide();',timeoutDelay);
}

// constructor for calendar class
function NCalendar()
{
  NavisCalendar = this;
// declare properties
  this.daysOfWeek;
  this.months;
  this.daysInMonth;
  this.utcdate;
  this.shadow;
  this.obj;
  this.useCalPopup;
  this.nudgeX;
  this.nudgeY;
  this.forceBelow;

// some constants needed throughout the program
  this.daysOfWeek = myDaysOfWeek;
  this.months = myMonths;
  this.daysInMonth = new Array(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);

// positioning
  this.setPosition = setCalendarPosition;
  this.resetPosition = resetCalendarPosition;

// Drop shadow
  this.shadow = new DropShadow();
  this.setShadowPosition = setDropShadowPosition;
  this.resetShadowPosition = resetDropShadowPosition;

// POP UP
  this.useCalPopup = (is.ie5_5up && is.win) ? (useCalPopup == 0) ? useCalPopup : 1 : 0;

  var tmpLayer = document.getElementById('container');
// calPopup.document.getElementById('containerPop')

  this.obj = tmpLayer;

  this.forceBelow = 1;
  this.nudgeX = 0;
  this.nudgeY = 0;
}

NCalendar.prototype.getFirstDOM = function()
{
  var thedate = new Date();
  thedate.setDate(1);
  thedate.setMonth(this.month);
  thedate.setFullYear(this.year); // setYear() also possible
  this.utcdate = thedate.getTime()
  return thedate.getDay();
}

NCalendar.prototype.getDaysInMonth = function ()
{
 if (this.month!=1)
 {
  return this.daysInMonth[this.month]
 }
 else
 {
// is it a leap year
  if (this.isLeapYear(this.year))
  {
    return 29;
  }
  else
  {
    return 28;
  }
 }
}

NCalendar.prototype.isLeapYear = function()
{
  if (this.year%4==0 && ((this.year%100!=0) || (this.year%400==0))) return true; else return false;
}

NCalendar.prototype.buildString = function()
{ //<form onSubmit="this.year.blur();return false;">

  var myTodayStr = (overrideTodayStr == false) ? defTodayStr : overrideTodayStr;

  var tmpStr = '<table style="height:100%;width:100%;" border="0" cellspacing="0" cellpadding="2" class="calBorderColor"><tr><td valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="1" class="calBgColor">';
  tmpStr += '<tr>';
  tmpStr += '<td width="60%" class="cal" align="left">';
  tmpStr += '<table border="0" cellspacing="0" cellpadding="0"><tr><td class="cal calBtn" onMouseDown="NavisCalendar.changeMonth(-1);"><img name="calendar" src="'+commonImgRoot+'down.gif" width="5" height="10" border="0" alt="" hidefocus></td><td class="cal" width="100%" align="center">' + this.months[this.month] + ' ' + this.year + '</td><td class="cal calBtn" onMouseDown="NavisCalendar.changeMonth(+1);"><img name="calendar" src="'+commonImgRoot+'up.gif" width="5" height="10" border="0" alt="" hidefocus ></td></tr></table>';
  tmpStr += '</td></tr></table>';

// divider
  tmpStr += '<hr class="calDiv" />';

  var iCount = 1;
  var iFirstDOM = this.getFirstDOM(); // to prevent calling it in a loop
  var iDaysInMonth = this.getDaysInMonth(); // to prevent calling it in a loop

  tmpStr += '<table width="100%" border="0" cellspacing="0" cellpadding="1" class="calBgColor">';
// output days of the week
  tmpStr += '<tr>';
  for (var i=0;i<this.daysOfWeek.length;i++)
  {
    tmpStr += '<td align="center" class="daysOfWeek">' + this.daysOfWeek[i] + '</td>';
  }
  tmpStr += '</tr>';
// END output days of the week
  for (var j=1;j<=6;j++)
  {
     tmpStr += '<tr>';
     for (var i=1;i<=7;i++)
     {
     tmpStr += '<td width="16" align="center" class="cal">'
     if ( (7*(j-1) + i)>=iFirstDOM+1  && iCount <= iDaysInMonth)
     {
/* could create a date object here and compare that but probably more efficient to convert to a number
and compare number as numbers are primitives */
// test if the current date is within the date range, if not, disable
/* REMOVING COMPARE... DOES NOT SEEM TO WORK AS EXPECTED, AND IS NOT REQUIRED
  var tmpFrom = parseInt('' + this.dateFromYear + this.dateFromMonth + this.dateFromDay,10);
  var tmpTo = parseInt('' + this.dateToYear + this.dateToMonth + this.dateToDay,10);
  var tmpCompare;
     tmpCompare = parseInt(padZero(this.year) + padZero(this.month) + padZero(iCount),10);
     if (tmpCompare >= tmpFrom && tmpCompare <= tmpTo)
     {
        tmpStr += '<div ';
// test if it is TODAY, if so highlight
    if (iCount==this.day && this.year==this.oYear && this.month==this.oMonth)
    {
      tmpStr += 'class="calHighlightColor"';
    }
      tmpStr += 'onClick="NavisCalendar.clickDay(' + iCount + ')">';
      tmpStr += '<a class="cal" href="javascript:NavisCalendar.clickDay(' + iCount + ');" hidefocus>' + iCount + '</a>';
      tmpStr += '</div>';
    }
  //  else
    {
      tmpStr += '<div class="disableDay">' + iCount + '</div>';
//      tmpStr += '<div class="disableDay">' + 'tmpCompare&nbsp;>=&nbsp;tmpFrom&nbsp;\''+ tmpCompare +'&nbsp;>=&nbsp;'+ tmpFrom + '\'  tmpCompare&nbsp;<=&nbsp;tmpTo&nbsp;\''+ tmpCompare + '&nbsp;<=&nbsp;' + tmpTo +'\'  ; iCount '+ iCount + '</div>';
    }
// END test if the current date is within the date range, if not, disable
*/

// test if it is TODAY, if so highlight
    tmpStr += '<div ';
    if (iCount==this.day && this.year==this.oYear && this.month==this.oMonth)
    {
      tmpStr += 'class="calHighlightColor"';
    }
    tmpStr += 'onClick="NavisCalendar.clickDay(' + iCount + ')">';
    tmpStr += '<a class="cal" href="javascript:NavisCalendar.clickDay(' + iCount + ');" hidefocus>' + iCount + '</a>';
    tmpStr += '</div>';
    iCount++;
    }
    else
    {
      tmpStr += '&nbsp;';
    }
    tmpStr += '</td>'
    }
  tmpStr += '</tr>';
  }
  tmpStr += '</table>';
// divider
  tmpStr += '<hr class="calDiv" />';
// add today link
  tmpStr += '<div style="text-align:center;"><a class="cal u-cal" href="#" onClick="NavisCalendar.selectToday();return false;">'+myTodayStr+'</a></div>';
  return tmpStr;
}

NCalendar.prototype.selectChange = function()
{
  this.month = is.nav?this.obj.ownerDocument.forms[0].month.selectedIndex:this.obj.document.forms[0].month.selectedIndex;
  this.writeString(this.buildString());
}

NCalendar.prototype.inputChange = function()
{
  var tmp = is.nav?this.obj.ownerDocument.forms[0].year:this.obj.document.forms[0].year;
  if (tmp.value >=1900 || tmp.value <=2100)
  {
    this.year = tmp.value;
    this.writeString(this.buildString());
  }
  else
  {
    tmp.value = this.year;
  }
}

NCalendar.prototype.selectToday = function()
{
  var myDate = new Date();

  this.month = myDate.getMonth();
  this.year = myDate.getFullYear(); // was getYear() 4/28/04
  this.clickDay(myDate.getDate())
}


NCalendar.prototype.changeYear = function(incr)
{
  (incr==1)?this.year++:this.year--;
  this.writeString(this.buildString());
}

NCalendar.prototype.changeMonth = function(incr)
{
  if (this.month==11 && incr==1)
  {
    this.month = 0;
    this.changeYear(+1)
  }
  else if (this.month==0 && incr==-1)
  {
    this.month = 11;
    this.changeYear(-1)
  }
  else
  {
    (incr==1)?this.month++:this.month--;
  }
  this.writeString(this.buildString());
}

NCalendar.prototype.clickDay = function(day)
{
  var tmp = document.getElementById(this.target);
  tmp.utcdate =   this.utcdate;
  var theYear2D = new String(parseInt(this.year))
  year2D = theYear2D.charAt(2) + theYear2D.charAt(3);
  // TRPS-3186: creating a date with current date's value is not correct:
  // for example today is 2010-04-09
  // when the day is set to May 31
  // first we set the day: which becomes April 31: it does not exist and becomes May 1st,
  // then we set the month May: then the selected day becomes May 1st: which is not the one selected
  // for that reason: we are creating the date with January 31 which has 31 days
  // NOTE: months start with 0: 0 is January
  // And similar problem may happen for non - leap years, so broadest initial date i.e. 2012 - January - 01 is best choice
  // create a UTC date for UTC output
  // var myDate = new Date();
  var myDate = new Date(2012, 0, 1);
  myDate.setDate(day);
  myDate.setMonth(this.month);
  myDate.setFullYear(this.year);
  var myUtcDate = myDate.getTime();
  // end UTC date
  if (this.dateFormat=='dd-mmm-yyyy') tmp.value = day + this.dateDelim + this.months[this.month].substr(0,3) + this.dateDelim + this.year;
  if (this.dateFormat=='dd-mon-yyyy') tmp.value = day + this.dateDelim + this.months[this.month].substr(0,3) + this.dateDelim + this.year;
  if (this.dateFormat=='dd-mm-yyyy') tmp.value = day + this.dateDelim + (this.month+1) + this.dateDelim + this.year;
  if (this.dateFormat=='mm-dd-yyyy') tmp.value = (this.month+1) + this.dateDelim + day + this.dateDelim + this.year;
  if (this.dateFormat=='mon-dd-yyyy') tmp.value = this.months[this.month].substr(0,3) + this.dateDelim + day + this.dateDelim + this.year;
  if (this.dateFormat=='yyyy-mm-dd') tmp.value = this.year + this.dateDelim +(this.month+1)+ this.dateDelim +day;
  if (this.dateFormat=='dd/mm/yyyy') tmp.value = day + this.dateDelim + (this.month+1) + this.dateDelim + this.year;
  if (this.dateFormat=='mm/dd/yyyy') tmp.value = padZero(this.month+1) + this.dateDelim + padZero(day) + this.dateDelim + this.year;
  if (this.dateFormat=='mm/dd/yy') tmp.value = padZero(this.month+1) + this.dateDelim + padZero(day) + this.dateDelim + year2D;
  if (this.dateFormat=='dd/mm/yy') tmp.value = padZero(day) + this.dateDelim + padZero(this.month+1) + this.dateDelim + year2D;
  if (this.dateFormat=='mmddyyyy') tmp.value = padZero(this.month+1) + '' + padZero(day) + '' + this.year;
  // UTC output
  if (this.dateFormat=='utc') tmp.value = myUtcDate;
  // end UTC output
  if (is.ie)
  {
    document.getElementById(this.target).click();
  }
  else
  {
    document.getElementById(this.target).focus();
  }
  if (document.getElementById(this.target).onchange){
    document.getElementById(this.target).onchange();
  }
  NavisCalendar.hide()
}

NCalendar.prototype.writeString = function(str)
{
  if(this.useCalPopup && calPopup.isOpen == true)
  {
  // if IE and the calendar popup is open, just set the popup innerHTML
    calPopup.document.getElementById('containerPop').innerHTML = str;
  }
  else{
    this.obj.innerHTML = str;
  }
}

NCalendar.prototype.show = function(event, target, dateFrom, dateTo, dFormat)
{
// for simplicity''s sake, I am hardcoding the date format
  var dateFormat = 'mm/dd/yyyy';

  try
  {
    dateFormat = dateFormatOverride;
  }
  catch(e)
  {
   // do nothing
  }

/* 10/19/2004 11:53AM -- cdn
*   Moved the dFormat below the dateFormatOverride.
*   The dFormat is set on the object when specific values are needed by other mechanisms.
*   These should not be overrided by the user''s locale or by a specific page.
*/
  if(dFormat)
    {
    dateFormat = dFormat;
    }

/* calendar can restrict choices between 2 dates, if however no restrictions
** are made, let them choose any date between 1900 and 3000
** dateFrom and dateTo expect a new Date() object
*/
  if (dateFrom) this.dateFrom = dateFrom; else this.dateFrom = new Date(1900,0,1);
  this.dateFromDay = padZero(this.dateFrom.getDate());
  this.dateFromMonth = padZero(this.dateFrom.getMonth());
  this.dateFromYear = this.dateFrom.getFullYear();
  if (dateTo) this.dateTo = dateTo; else this.dateTo = new Date(3000,0,1);
  this.dateToDay = padZero(this.dateTo.getDate());
  this.dateToMonth = padZero(this.dateTo.getMonth());
  this.dateToYear = this.dateTo.getFullYear(); // setYear() also possible

// test if a date format has been selected, if not, set default
  if (dateFormat) this.dateFormat = dateFormat; else this.dateFormat = 'dd-mmm-yyyy';

  switch (this.dateFormat)
  {
    case 'dd/mm/yyyy':
      this.dateDelim = '/';
      break;
    case 'mm/dd/yyyy':
      this.dateDelim = '/';
      break;
    case 'mm/dd/yy':
      this.dateDelim = '/';
      break;
    case 'dd/mm/yy':
      this.dateDelim = '/';
      break;
    default:
      this.dateDelim = '-';
      break;
  }

  if (this.obj.style.visibility=='visible')
  {
    NavisCalendar.hide();
    return;
  }

  this.setPosition(event);

  this.target = target;
  var tmp = document.getElementById(target);
  if (tmp && tmp.value && tmp.value.split(this.dateDelim).length==3)
  {
    var atmp = tmp.value.split(this.dateDelim)
    this.day = this.oDay = this.dateFormat.substr(0,2)=='dd'?parseInt(atmp[0],0):parseInt(atmp[1],0);
    if (this.dateFormat=='dd-mmm-yyyy' ||this.dateFormat=='dd-mon-yyyy' )
    {
      for (var i=0;i<this.months.length;i++)
      {
        if (atmp[1].toLowerCase()==this.months[i].substr(0,3).toLowerCase())
        {
          this.month = this.oMonth = i;
          break;
        }
      }
    }
    else if (this.dateFormat.substr(0,2)=='dd')
    {
      this.month = this.oMonth = parseInt(atmp[1]-1,0);
    }
    else if ( this.dateFormat=='mon-dd-yyyy' )
    {
      for (var i=0;i<this.months.length;i++)
      {
        if (atmp[0].toLowerCase()==this.months[i].substr(0,3).toLowerCase())
        {
          this.month = this.oMonth = i;
          break;
        }
      }
    }
    else
    {
      this.month = this.oMonth = parseInt(atmp[0]-1,0);
    }
  // check to see if the year in the tmp object is < 1000, if so, it is very likely 2000!
  var myActualYr = (parseInt(atmp[2],10)<1000) ? 2000 + parseInt(atmp[2],10) : parseInt(atmp[2],10);
  this.year = this.oYear = myActualYr;
  }
  else // no date set, default to today
  {
    var theDate = new Date();
     this.year = this.oYear = theDate.getFullYear(); // getYear() also possible
     this.month = this.oMonth = theDate.getMonth();
     this.day = this.oDay = theDate.getDate();
  }
  this.writeString(this.buildString());

  if(this.useCalPopup)
  {
  // if IE and the calendar popup is not open, set the popup content and show it
    var tarBody = calPopup.document.getElementById('containerPop');

    tarBody.innerHTML = this.obj.innerHTML;

    calPopup.show(this.obj.offsetLeft+2, this.obj.offsetTop+2, this.obj.offsetWidth, this.obj.offsetHeight, document.body)
  }
  else{
  this.obj.style.visibility='visible';
  }
// show the shadow
  this.setShadowPosition();
  this.shadow.obj.style.zIndex = 1;
}

NCalendar.prototype.hide = function()
{
  this.obj.style.visibility='hidden';
  this.resetPosition;
  this.resetShadowPosition();
  if(this.useCalPopup)
  {
    calPopup.hide()
  }
}


function setCalendarPosition(e)
{
  var e = getEvent(e);
  var eX = getEventX(e);
  var eY = getEventY(e);
  var lefter;
  var topper;
  var roomRight;
  var roomLeft;
  var roomAbove;
  var roomBelow;
  var availableWidth;
  var availableHeight;
  var floatPointer = false;

  if (this.isVisible && this.isFixed)
  {
    return;
  }

//determine available space
  availableWidth = (document.body.scrollLeft + document.body.clientWidth) - this.shadow.nudgeX;  //determine maximum range for width
  availableHeight = (document.body.scrollTop  + document.body.clientHeight) - (this.obj.offsetHeight + this.shadow.nudgeY); //determine maximum range for height

//determine if there is space to the right
  roomRight = (eX + this.obj.offsetWidth < availableWidth) ? true : false;

//determine if there is space to the left
  roomLeft = (eX - this.obj.offsetWidth > 0) ? true : false;

//determine if there is space above
  roomAbove = (eY - this.obj.offsetHeight) ? true : false;

//SET VERTICAL POSITION:

//if there is no room above but there is room below, position below
  if (this.forceBelow || !roomAbove)
  {
   this.obj.style.top = eY + (this.nudgeY * 2) + "px";
  }
//otherwise, position above
  else
  {
   this.obj.style.top = eY - this.obj.offsetHeight + "px";
  }

//SET HORIZONTAL POSITION:

//if there is no room right and no room left, float the pointer
  if(!roomRight && !roomLeft)
  {
    floatPointer = true;
  }
  else
  {
    floatPointer = false;
  }

//if there is no room right but there is room left, position left
  if (this.forceLeft || (!roomRight && roomLeft))
  {
  lefter = eX - this.obj.offsetWidth;
    this.obj.style.left = lefter + "px"
  }
//otherwise, position right
  else
  {
    if(floatPointer)
    {
      lefter = Math.min((eX + this.obj.offsetWidth), availableWidth);
      this.obj.style.left = (lefter - this.obj.offsetWidth) + "px"
    }
    else
    {
      this.obj.style.left = (eX) + "px";
    }
  }
}

function resetCalendarPosition()
{
  this.obj.style.top = 1 + "px";
  this.obj.style.left = 1 + "px";
}


// events capturing
//window.document.onclick=calendarDocumentClick

function calendarDocumentClick(e)
{
try{
  var e = getEvent(e);
  var eX = getEventX(e);
  var eY = getEventY(e);

  if (is.nav)
  {
    if (e.target.name!='imgCalendar' && e.target.name!='month'  && e.target.name!='year' && e.target.name!='calendar')
    {
      NavisCalendar.hide();
    }
  }
  if (is.ie)
  {
// extra test to see if user clicked inside the calendar but not on a valid date, we don't want it to disappear in this case
   var bTest = (eX > parseInt(NavisCalendar.obj.style.left,10) && eX <  (parseInt(NavisCalendar.obj.style.left,10)+125) && eY < (parseInt(NavisCalendar.obj.style.top,10)+125) && e > parseInt(NavisCalendar.obj.style.top,10));
    if ((e.srcElement.name!='imgCalendar' && e.srcElement.name!='month' && e.srcElement.name!='year' && !bTest & typeof(e.srcElement)!='object'))
    {
      NavisCalendar.hide();
    }
  }
}
catch(e)
{
// do nothing
}
}

function initCalendar()
{
  myDaysOfWeek = (!overrideDaysOfWeek) ? defDaysOfWeek : overrideDaysOfWeek;
  myMonths = (!overrideMonths) ? defMonths : overrideMonths;

  if(!document.getElementById('dropShadow'))
    {
      initShadow()
    }
  var aCalendar = new NCalendar(new Date());
  // this listener had to be set up onload in order to get a handle on all form objects
  listenToForms();
}

// utility function
function padZero(num)
{
  return ((num <= 9) ? ("0" + num) : num);
}

// calendar year functions
function addDays(startDate,addition)
{
  var accumulate    = new Array(0,31, 59, 90,120,151,181,212,243,273,304,334);
  var accumulateLY  = new Array(0,31, 60, 91,121,152,182,213,244,274,305,335);
  var year = startDate.getFullYear();
  var month = startDate.getMonth();
  var day = startDate.getDate();

  if (isLeapYear(year))
  {
    var number = day + accumulateLY[month] + addition;
  }
  else
  {
    var number = day + accumulate[month]   + addition;
  }

  var days = daysinyear(year);

  while (number > days)
  {
    number -= days;
    days = daysinyear(++year);
  }
  while (number < 1)
  {
    days = daysinyear(--year);
    number += days;
  }

  month = 0;

  if (isLeapYear(year))
  {
    while (number > accumulateLY[month])
    {
      month++;
    }
    day = number - accumulateLY[--month];
  }
  else
  {
    while (number > accumulate[month])
    {
      month++;
    }
    day = number - accumulate[--month];
  }
return new Date(year,month,day);
}

function daysinyear(year)
{
  if (isLeapYear(year))
  {
    return 366;
  }
  else
  {
    return 365;
  }
}

function isLeapYear(year)
{
  if (year%4==0 && ((year%100!=0) || (year%400==0)))
  {
    return true;
  }
  else
  {
    return false;
  }
}

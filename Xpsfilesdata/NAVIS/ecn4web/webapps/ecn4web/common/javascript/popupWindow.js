/************************************************************************/
/**** JavaScript for poping up new windows.                          ****/
/****                                                                ****/
/************************************************************************/
/****                                                                ****/
/**** This file depends upon the following JavaScript files:         ****/
/****   -none                                                        ****/
/****                                                                ****/
/************************************************************************/


function popWin(targetURL,h,w,winName,props) {
  var winProps,myWin;

  winName = (winName) ? winName : 'popup';
  winProps = (h != null) ? 'height=' + h + ',' : 'height=400,';
  winProps += (w != null) ? 'width=' + w + ',' : 'width=600,';
  winProps += (props) ? props : 'fullscreen=no,location=no,menubar=no,resizable=yes,scrollbars=yes,status=no,titlebar=no,toolbar=no,directories=no';
  
  myWin = window.open(targetURL,winName,winProps);
  myWin.focus();
  return myWin;
}

function popModal(targetURL,h,w,args,props) {
  var winH,winW,winArgs,winProps,myWin;

  winH = (h) ? h + 'px' : '600px';
  winW = (w) ? w + 'px': '400px';
  winArgs = (args) ? args : '';
  winProps = (props) ? props : '';

  winProps = (h) ? 'dialogHeight:' + h + 'px;' : 'dialogHeight:400px;';
  winProps += (w) ? 'dialogWidth:' + w + 'px;' : 'dialogWidth:600px;';
  winProps += (props) ? props : 'center:yes;edge:sunken;resizeable:no;scroll:no;status:no;unadorned:yes';

  myWin = showModalDialog(targetURL,winArgs,winProps);
  return myWin;
}

function popModeless(targetURL,h,w,args,props) {
  var winH,winW,winArgs,winProps,myWin;

  winH = (h) ? h + 'px' : '600px';
  winW = (w) ? w + 'px': '400px';
  winArgs = (args) ? args : '';
  winProps = (props) ? props : '';

  winProps = (h) ? 'dialogHeight:' + h + 'px;' : 'dialogHeight:400px;';
  winProps += (w) ? 'dialogWidth:' + w + 'px;' : 'dialogWidth:600px;';
  winProps += (props) ? props : 'center:yes;edge:sunken;resizeable:no;scroll:no;status:no;unadorned:yes';

  myWin = showModelessDialog(targetURL,winArgs,winProps);
  return myWin;
}

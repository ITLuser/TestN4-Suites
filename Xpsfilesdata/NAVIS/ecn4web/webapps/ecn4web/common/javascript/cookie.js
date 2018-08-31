/************************************************************************/
/**** Getters and setters for browser cookies.                       ****/
/****                                                                ****/
/************************************************************************/
/****                                                                ****/
/**** This file depends upon the following JavaScript files:         ****/
/****   -none                                                        ****/
/****                                                                ****/
/************************************************************************/
/****                                                                ****/
/**** Cookie functions use the following arguments:                  ****/
/****                                                                ****/
/****   name      - name of the cookie                               ****/
/****   value     - value of the cookie                              ****/
/****   [expires] - expiration date of the cookie (defaults to end   ****/
/****               of current session)                              ****/
/****   [path]    - path for which the cookie is valid (defaults to  ****/
/****               path of calling document)                        ****/
/****   [domain]  - domain for which the cookie is valid (defaults   ****/
/****               to domain of calling document)                   ****/
/****   [secure]  - Boolean value indicating if the cookie           ****/
/****               transmission requires a secure transmission      ****/
/****                                                                ****/
/************************************************************************/

function setCookie(name, value, expires, path, domain, secure) {
  var curCookie = name + "=" + escape(value) +
  ((expires) ? "; expires=" + expires.toGMTString() : "") +
  ((path) ? "; path=" + path : "") +
  ((domain) ? "; domain=" + domain : "") +
  ((secure) ? "; secure" : "");
  
  document.cookie = curCookie;
}

function getCookie(name) {
  var dc = document.cookie;
  var prefix = name + "=";
  var begin = dc.indexOf("; " + prefix);
  var end;
  
  if (begin == -1) {
    begin = dc.indexOf(prefix);
    if (begin != 0) return null;
  }
  else {
    begin += 2;
  }

  end = document.cookie.indexOf(";", begin);
  if (end == -1) {
    end = dc.length;
  }
  
  return unescape(dc.substring(begin + prefix.length, end));
}

function deleteCookie(name, path, domain) {
  if (getCookie(name)) {
    document.cookie = name + "=" + 
    ((path) ? "; path=" + path : "") +
    ((domain) ? "; domain=" + domain : "") + "; expires=Thu, 01-Jan-70 00:00:01 GMT";
  }
}

function fixDate(date) {
// date - any instance of the Date object
// hand all instances of the Date object to this function for "repairs"
  var base = new Date(0);
  var skew = base.getTime();

  if (skew > 0)
  date.setTime(date.getTime() - skew);
}

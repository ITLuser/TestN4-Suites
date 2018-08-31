// Ultimate client-side JavaScript client sniff. Version 4.02
// based upon: Ultimate client-side JavaScript client sniff. Version 3.03
// (C) Netscape Communications 1999-2001.  Permission granted to reuse and distribute.
// Revised 17 May 99 to add is.nav5up and is.ie5up (see below).
// Revised 21 Nov 00 to add is.gecko and is.ie5_5 Also Changed is.nav5 and is.nav5up to is.nav6 and is.nav6up
// Revised 22 Feb 01 to correct Javascript Detection for IE 5.x, Opera 4, 
//                      correct Opera 5 detection
//                      add support for winME and win2k
//                      synch with browser-type-oo.js
//                      add is.aol5, is.aol6
// Revised 26 Mar 01 to correct Opera detection
// Revised 02 Oct 01 to add IE6 detection
// Revised 08 Oct 02 by Tim Dobbelaere (http://tim.dobbelaere.com)
//                   to add WinXP (is.winxp), Windows.NET (is.windotnet)
//                      correct Mozilla & Netscape browser/engine distiction <<< use engine detection!
//                      mozilla engine: is.moz, is.moz2, is.moz2up, is.moz3, is.moz3up, is.moz4, is.moz4up, is.moz5, is.moz5up
//                        mozilla browser: is.mozilla, is.mozilla1
//                      correct is.nav6 and is.nav6up, add is.nav7, is.aol7, is.aol8, is.opera6, is.opera6up
//                        add is.macos, is.macos8, is.macos9, is.macosx
// Revised 21 Apr 03 by Darren J Luvaas
//                   safari engine: is.safari

// Everything you always wanted to know about your javascript client
// but were afraid to ask ... "Is" is the constructor function for "is" object,
// which has properties indicating:
// (1) browser vendor:
//     is.nav, is.ie, is.opera, is.hotjava, is.webtv, is.tvnavigator, is.aoltv, is.safari
// (2) browser version number:
//     is.major (integer indicating major version number: 2, 3, 4 ...)
//     is.minor (float   indicating full  version number: 2.02, 3.01, 4.04 ...)
// (3) mozilla engine generation
//     is.moz2, is.moz2up, is.moz3, is.moz3up, is.moz4, is.moz4up, is.moz5, is.moz5up, is.gecko
// (4) browser vendor and major version number
//     is.nav2, is.nav3, is.nav4, is.nav4up, is.nav6, is.nav6up, is.nav7, is.nav7up
//     is.mozilla1
//     is.ie3, is.ie4, is.ie4up, is.ie5, is.ie5up, is.ie5_5, is.ie5_5up, is.ie6, is.ie6up, is.ie7, is.ie7up,
//     is.hotjava3, is.hotjava3up, is.opera2, is.opera3, is.opera4, is.opera5, is.opera5up, is.opera6, is.opera6up
//     is.aol3, is.aol4, is.aol5, is.aol6, is.aol7, is.aol8,
// (5) javascript version number:
//     is.js (float indicating full javascript version number: 1, 1.1, 1.2 ...)
// (6) os platform and version:
//     is.win, is.win16, is.win32, is.win31, is.win95, is.winnt, is.win98, is.winme, is.win2k, is.winxp, is.windotnet
//     is.os2
//     is.mac, is.mac68k, is.macppc
//     is.unix
//     is.sun, is.sun4, is.sun5, is.suni86
//     is.irix, is.irix5, is.irix6
//     is.hpux, is.hpux9, is.hpux10
//     is.aix, is.aix1, is.aix2, is.aix3, is.aix4
//     is.linux, is.sco, is.unixware, is.mpras, is.reliant
//     is.dec, is.sinix, is.freebsd, is.bsd
//     is.vms
//
// see http://www.it97.de/javascript/js_tutorial/bstat/navobj.html and
// http://www.it97.de/javascript/js_tutorial/bstat/browseraol.html
// for detailed lists of userAgent strings.
//
// note: you don't want your nav4 or ie4 code to "turn off" or
// stop working when nav5 and ie5 (or later) are released, so
// in conditional code forks, use is.nav4up ("Nav4 or greater")
// and is.ie4up ("IE4 or greater") instead of is.nav4 or is.ie4
// to check version in code which you want to work on future
// versions.

function Is ()
{   // convert all characters to lowercase to simplify testing
    var agt=navigator.userAgent.toLowerCase();

    // *** browser version ***
    // note: On IE5, these return 4, so use is.ie5up to detect IE5
    // or is.ie6up to detect IE6.

    this.major = parseInt(navigator.appVersion);
    this.minor = parseFloat(navigator.appVersion);

    // note: opera, webtv, and safari spoof navigator.  we do strict client detection.
    // if you want to allow spoofing, take out the tests for opera, webtv, and safari.
    this.moz     = ((agt.indexOf('mozilla') != -1) && (agt.indexOf('spoofer')==-1)
                   && (agt.indexOf('compatible') == -1) && (agt.indexOf('opera')==-1)
                   && (agt.indexOf('webtv')==-1) && (agt.indexOf('hotjava')==-1))
                   && (agt.indexOf('safari')==-1);
    this.moz2    = (this.moz && (this.major == 2));
    this.moz3    = (this.moz && (this.major == 3));
    this.moz4    = (this.moz && (this.major == 4));
    this.moz4up  = (this.moz && (this.major >= 4));
    this.moz5    = (this.moz && (this.major == 5));
    this.moz5up  = (this.moz && (this.major >= 5));
    this.gecko   = (agt.indexOf('gecko') != -1);

    this.nav2    = this.moz2;
    this.nav3    = this.moz3;
    this.nav4    = this.moz4;
    this.nav4up  = (this.nav4 || ((this.major >= 4) && (agt.indexOf("netscape") != -1)));
    this.nav     = (this.nav2 || this.nav3 || this.nav4);
    this.nav6    = (this.moz && (this.major == 5) && (agt.indexOf("netscape6/6") != -1));
    this.nav6up  = (this.moz && (this.major >= 5) && (agt.indexOf("netscape") != -1));
    this.nav7    = (this.moz && (this.major == 5) && (agt.indexOf("netscape/7") != -1));
    this.nav7up  = (this.nav6up && !this.nav6);
    this.navonly = (this.nav && ((agt.indexOf(";nav") != -1) || (agt.indexOf("; nav") != -1)) );

    this.mozilla  = (this.moz && this.gecko);
    this.mozilla1 = (this.moz && this.gecko && (agt.indexOf("rv:1") != -1));

    this.ie      = ((agt.indexOf("msie") != -1) && (agt.indexOf("opera") == -1));
    this.ie3     = (this.ie && (this.major < 4));
    this.ie4     = (this.ie && (this.major == 4) && (agt.indexOf("msie 4") != -1) );
    this.ie4up   = (this.ie && (this.major >= 4));
    this.ie5     = (this.ie && (this.major == 4) && (agt.indexOf("msie 5.0") != -1) );
    this.ie5_5   = (this.ie && (this.major == 4) && (agt.indexOf("msie 5.5") != -1));
    this.ie5up   = (this.ie && !this.ie3 && !this.ie4);
    this.ie5_5up = (this.ie && !this.ie3 && !this.ie4 && !this.ie5);
    this.ie6     = (this.ie && (this.major == 4) && (agt.indexOf("msie 6.") != -1) );
    this.ie6up   = (this.ie && !this.ie3 && !this.ie4 && !this.ie5 && !this.ie5_5);
    this.ie7     = (this.ie && (this.major == 4) && (agt.indexOf("msie 7.") != -1) );
    this.ie7up   = (this.ie && !this.ie3 && !this.ie4 && !this.ie5 && !this.ie5_5 && !this.ie6);

    this.msn    = (this.ie4up && (agt.indexOf("msn") != -1));
    this.msn2_5 = (this.msn && (agt.indexOf("msn 2.5") != -1));
    this.msn2_6 = (this.msn && (agt.indexOf("msn 2.6") != -1));

    this.aol      = (agt.indexOf("aol") != -1);
    this.aol3     = (this.aol && this.ie3);
    this.aol4ie3  = (this.aol && this.ie3);
    this.aol4ie4  = (this.aol && this.ie4);
    this.aol4     = (this.aol4ie3 || this.aol4ie4);
    this.aol5     = (agt.indexOf("aol 5") != -1);
    this.aol6     = (agt.indexOf("aol 6") != -1);
    this.aol7     = ((agt.indexOf("aol 7") != -1) || agt.indexOf("aol/7") != -1);
    this.aol8     = ((agt.indexOf("aol 8") != -1) || agt.indexOf("aol/8") != -1);

    this.opera = (agt.indexOf("opera") != -1);
    this.opera2 = (agt.indexOf("opera 2") != -1 || agt.indexOf("opera/2") != -1);
    this.opera3 = (agt.indexOf("opera 3") != -1 || agt.indexOf("opera/3") != -1);
    this.opera4 = (agt.indexOf("opera 4") != -1 || agt.indexOf("opera/4") != -1);
    this.opera5 = (agt.indexOf("opera 5") != -1 || agt.indexOf("opera/5") != -1);
    this.opera5up = (this.opera && !this.opera2 && !this.opera3 && !this.opera4);
    this.opera6 = (agt.indexOf("opera 6") != -1 || agt.indexOf("opera/6") != -1);
    this.opera6up = (this.opera6 || this.opera5up);

    this.webtv = (agt.indexOf("webtv") != -1); 

    this.TVNavigator = ((agt.indexOf("navio") != -1) || (agt.indexOf("navio_aoltv") != -1)); 
    this.AOLTV = this.TVNavigator;

    this.hotjava = (agt.indexOf("hotjava") != -1);
    this.hotjava3 = (this.hotjava && (this.major == 3));
    this.hotjava3up = (this.hotjava && (this.major >= 3));
    
    this.safari = (agt.indexOf("safari") != -1);

    // *** JAVASCRIPT VERSION CHECK ***
    if (this.nav2 || this.ie3) this.js = 1.0;
    else if (this.nav3) this.js = 1.1;
    else if (this.opera5up) this.js = 1.3;
    else if (this.opera) this.js = 1.1;
    else if ((this.nav4 && (this.minor <= 4.05)) || this.ie4) this.js = 1.2;
    else if ((this.nav4 && (this.minor > 4.05)) || this.ie5) this.js = 1.3;
    else if (this.hotjava3up) this.js = 1.4;
    else if (this.nav6 || this.gecko) this.js = 1.5;
    // NOTE: In the future, update this code when newer versions of JS
    // are released. For now, we try to provide some upward compatibility
    // so that future versions of Nav and IE will show they are at
    // *least* JS 1.x capable. Always check for JS version compatibility
    // with > or >=.
    else if (this.nav6up) this.js = 1.5;
    // note ie5up on mac is 1.4
    else if (this.ie5up) this.js = 1.3

    // HACK: no idea for other browsers; always check for JS version with > or >=
    else this.js = 0.0;

    // *** PLATFORM ***
    this.win   = ( (agt.indexOf("win") != -1) || (agt.indexOf("16bit") != -1) );
    // NOTE: On Opera 3.0, the userAgent string includes "Windows 95/NT4" on all
    //        Win32, so you can't distinguish between Win95 and WinNT.
    this.win95 = ((agt.indexOf("win95") != -1) || (agt.indexOf("windows 95") != -1));

    // is this a 16 bit compiled version?
    this.win16 = ((agt.indexOf("win16") != -1) || 
               (agt.indexOf("16bit") != -1) || (agt.indexOf("windows 3.1") != -1) || 
               (agt.indexOf("windows 16-bit") != -1) );  

    this.win31 = ((agt.indexOf("windows 3.1") != -1) || (agt.indexOf("win16") != -1) ||
                    (agt.indexOf("windows 16-bit") != -1));

    // NOTE: Reliable detection of Win98 may not be possible. It appears that:
    //       - On Nav 4.x and before you'll get plain "Windows" in userAgent.
    //       - On Mercury client, the 32-bit version will return "Win98", but
    //         the 16-bit version running on Win98 will still return "Win95".
    this.win98 = ((agt.indexOf("win98") != -1) || (agt.indexOf("windows 98") != -1));
    this.winnt = ((agt.indexOf("winnt") != -1) || (agt.indexOf("windows nt") != -1));
    this.win32 = (this.win95 || this.winnt || this.win98 || 
                    ((this.major >= 4) && (navigator.platform == "Win32")) ||
                    (agt.indexOf("win32") != -1) || (agt.indexOf("32bit") != -1));

    this.winme = ((agt.indexOf("win 9x 4.90") != -1));
    this.win2k = ((agt.indexOf("windows nt 5.0") != -1));
    this.winxp = ((agt.indexOf("windows nt 5.1") != -1));
    this.windotnet = ((agt.indexOf("windows nt 5.2") != -1));

    this.os2   = ((agt.indexOf("os/2") != -1) || 
                    (navigator.appVersion.indexOf("OS/2") != -1) ||   
                    (agt.indexOf("ibm-webexplorer") != -1));

    this.mac    = (agt.indexOf("mac") != -1);
    // hack ie5 js version for mac
    if (this.mac && this.ie5up) this.js = 1.4;
    this.mac68k = (this.mac && ((agt.indexOf("68k") != -1) || 
                               (agt.indexOf("68000") != -1)));
    this.macppc = (this.mac && ((agt.indexOf("ppc") != -1) || 
                                (agt.indexOf("powerpc") != -1)));
    // macos detection not a real science, too little info in ua
    this.macos  = (this.mac && ((agt.indexOf("mac os") != -1) ||
                                (agt.indexOf("macos") != -1) ||
                                this.ie));
    this.macos8 = (this.macos && ((agt.indexOf("os 8") != -1) ||
                                  (agt.indexOf("os8") != -1)));
    // ie5.13 reports as ie5.12 on os x
    this.macos9 = ((this.mac && (this.ie5 && (agt.indexOf("msie 5.13") != -1))) ||
                   (this.macos && ((agt.indexOf("os 9") != -1) ||
                                   (agt.indexOf("os9") != -1))));
    this.macosx = (this.macos && ((agt.indexOf("os x") != -1) ||
                                  (agt.indexOf("osx") != -1)));

    this.sun   = (agt.indexOf("sunos") != -1);
    this.sun4  = (agt.indexOf("sunos 4") != -1);
    this.sun5  = (agt.indexOf("sunos 5") != -1);
    this.suni86= (this.sun && (agt.indexOf("i86") != -1));
    this.irix  = (agt.indexOf("irix") != -1);    // SGI
    this.irix5 = (agt.indexOf("irix 5") != -1);
    this.irix6 = ((agt.indexOf("irix 6") != -1) || (agt.indexOf("irix6") != -1));
    this.hpux  = (agt.indexOf("hp-ux") != -1);
    this.hpux9 = (this.hpux && (agt.indexOf("09.") != -1));
    this.hpux10= (this.hpux && (agt.indexOf("10.") != -1));
    this.aix   = (agt.indexOf("aix") != -1);      // IBM
    this.aix1  = (agt.indexOf("aix 1") != -1);    
    this.aix2  = (agt.indexOf("aix 2") != -1);    
    this.aix3  = (agt.indexOf("aix 3") != -1);    
    this.aix4  = (agt.indexOf("aix 4") != -1);    
    this.linux = (agt.indexOf("inux") != -1);
    this.sco   = (agt.indexOf("sco") != -1) || (agt.indexOf("unix_sv") != -1);
    this.unixware = (agt.indexOf("unix_system_v") != -1); 
    this.mpras    = (agt.indexOf("ncr") != -1); 
    this.reliant  = (agt.indexOf("reliantunix") != -1);
    this.dec   = ((agt.indexOf("dec") != -1) || (agt.indexOf("osf1") != -1) || 
                  (agt.indexOf("dec_alpha") != -1) || (agt.indexOf("alphaserver") != -1) || 
                  (agt.indexOf("ultrix") != -1) || (agt.indexOf("alphastation") != -1)); 
    this.sinix = (agt.indexOf("sinix") != -1);
    this.freebsd = (agt.indexOf("freebsd") != -1);
    this.bsd = (agt.indexOf("bsd") != -1);
    // hack macos if not linux or bsd
    this.macos = (this.macos || (!this.linux && !this.bsd));
    this.unix  = ((agt.indexOf("x11") != -1) || this.sun || this.irix || this.hpux || 
                 this.sco ||this.unixware || this.mpras || this.reliant || 
                 this.dec || this.sinix || this.aix || this.linux || this.bsd || this.freebsd);

    this.vms   = ((agt.indexOf("vax") != -1) || (agt.indexOf("openvms") != -1));
    
    // set the various compatabilities to false initially.
    this.certified = 0;
    this.supported = 0;
    this.unsupported = 0;
    this.blocked = 0;
    
    // "blocked" if
    //		if ie and not greater than 4
    //		ns4.x
    //      safari
    if((this.ie && !this.ie4up) || this.nav)
    {
    	this.blocked = 1;
    }
    // "supported" if
    //		ie5.5 is it:
    //			NT, XP or 2K
    else if(this.ie5_5 && (this.winnt || this.winxp || this.win2k))
    {
    	this.supported = 1;
    }
    // "certified" if
    //		IE6 is it:
    //			NT, XP or 2K
    else if((this.ie6up && (this.winnt || this.winxp || this.win2k)) || (this.mozilla1))
    {
    	this.certified = 1;
    }
    // "unsupported" if
	// 		ns 6
	// 		if IE, is it:
	//			ie5 or greater but less not ie5.5 and greater?
	// 		if it is ie5.5, ie6, or mozilla1 and:
	//			win95 or win98
	//      safari
	else
    {
    	this.unsupported = 1;
    }
}

var is;
var isIE3Mac = false;
// this section is designed specifically for IE3 for the Mac

if ((navigator.appVersion.indexOf("Mac") != -1) && (navigator.userAgent.indexOf("MSIE") != -1) && 
(parseInt(navigator.appVersion)==3))
       isIE3Mac = true;
else   is = new Is(); 

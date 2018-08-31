<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Cache-Control" content="no-cache" />
<%
    // Constructing a legal full Url, per spec for base tag.
    String httpContext = request.getScheme() + // http or https?
            "://" +
            request.getServerName() + // anything
            ":" +
            request.getServerPort() + // probably 8080 or 80, but anything possible
            request.getContextPath();
%>
<base href="<%= httpContext %>/skins/default/" />
<link type="text/css" rel="stylesheet" href="<%= httpContext %>/common/css/main.css" />
<script type="text/javascript">
//the following variables are used inside JavaScript resources where the JS needs to get at an image path
var skinImgRoot   =  'images/';                                  //skin-level images
var appImgRoot    =  '../../images/';                               //application-level images
var commonImgRoot =  '<%= httpContext %>/common/images/';        //framework-level images
var cssModuleRoot =  '<%= httpContext %>/common/css/modules/';   //css root for various modules
</script>
<script type="text/javascript" src="<%= httpContext %>/common/javascript/browserSniff.js"></script>
<script type="text/javascript" src="<%= httpContext %>/common/javascript/imageSwap.js"></script>
<script type="text/javascript" src="<%= httpContext %>/common/javascript/toolTip.js"></script>
<script type="text/javascript" src="<%= httpContext %>/common/javascript/autocomplete.js"></script>
<script type="text/javascript" src="<%= httpContext %>/common/javascript/common.js"></script>
<script type="text/javascript" src="<%= httpContext %>/common/javascript/globalEvents.js"></script>
<script type="text/javascript" src="<%= httpContext %>/common/javascript/form.js"></script>
<script type="text/javascript" src="<%= httpContext %>/common/javascript/menu.js"></script>
<script type="text/javascript" src="<%= httpContext %>/common/javascript/popupWindow.js"></script>
<script type="text/javascript" src="<%= httpContext %>/common/javascript/ieEmulation.js"></script>
<script type="text/javascript" src="<%= httpContext %>/trips/javascript/operations.js"></script>
<script type="text/javascript" src="<%= httpContext %>/common/javascript/cookie.js"></script>
<script type="text/javascript" src="<%= httpContext %>/common/javascript/tableSort.js"></script>
<script type="text/javascript" src="<%= httpContext %>/common/javascript/assignment.js"></script>
<script type="text/javascript" src="<%= httpContext %>/common/javascript/addRemoveLine.js"></script>
<script type="text/javascript" src="<%= httpContext %>/common/javascript/dropShadow.js"></script>
<script type="text/javascript" src="<%= httpContext %>/common/javascript/n4calendar.js"></script>
<script type="text/javascript" src="<%= httpContext %>/common/javascript/n4Confirm.js"></script>
<script type="text/javascript" src="<%= httpContext %>/common/javascript/n4Modal.js"></script>
<script type="text/javascript" src="<%= httpContext %>/common/javascript/math.js"></script>
<script type="text/javascript" src="<%= httpContext %>/common/javascript/globalHandlers.js"></script>
<script type="text/javascript" src="<%= httpContext %>/common/javascript/statusHandlers.js"></script>
<script type="text/javascript" src="<%= httpContext %>/common/javascript/confirmHandlers.js"></script>
<script type="text/javascript" src="<%= httpContext %>/common/javascript/calendarHandlers.js"></script>
<script type="text/javascript" src="<%= httpContext %>/common/javascript/selectHandlers.js"></script>
<script type="text/javascript" src="<%= httpContext %>/common/javascript/expandSubForm.js"></script>
<script type="text/javascript" src="<%= httpContext %>/common/javascript/lovHandlers.js"></script>
<script type="text/javascript" src="<%= httpContext %>/common/javascript/getOptions.js"></script>
<%--<script type="text/javascript" src="<%= httpContext %>/common/javascript/pagination.js"></script>--%>
</head>

<body>

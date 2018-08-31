<%@ page language="java" %>
<%@ taglib prefix="bean" uri="/WEB-INF/tlds/struts-bean.tld" %>
<%@ taglib prefix="html" uri="/WEB-INF/tlds/struts-html.tld" %>
<%@ taglib prefix="logic" uri="/WEB-INF/tlds/struts-logic.tld" %>
<%@ taglib prefix="meta" uri="/WEB-INF/lib/n4-metafields.jar" %>
<%@ taglib prefix="layout" uri="/WEB-INF/lib/n4-layout.jar" %>
<%@ taglib prefix="site" uri="/WEB-INF/lib/n4-sitemap.jar" %>
<%@ page import=" org.apache.commons.lang.StringUtils,
                 com.navis.framework.FrameworkPropertyKeys,
                 com.navis.framework.web.actions.CrudPlusAction,
                 com.navis.security.presentation.UserCache" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
    <title><site:pageName/></title>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"/>
    <meta http-equiv="Pragma" content="no-cache"/>
    <meta http-equiv="Cache-Control" content="no-cache"/>
    <layout:calendarDefaults/>
    <%
        // Constructing a legal full Url, per spec for base tag.
        String httpContext = request.getScheme() + // http or https?
                "://" +
                request.getServerName() + // anything
                ":" +
                request.getServerPort() + // probably 8080 or 80, but anything possible
                request.getContextPath();

        // Show a "Page loading" message here. This would better if we could do this
        // earlier in the page presentation cycle, but it appears we can't. I have tried
        // a few things and this is the easiest place to make it completely transparent
        // to the caller.  AJP 2/04
        final String w = request.getParameter(CrudPlusAction.WAIT_PARAMETER_KEY);
        final boolean isWaiting = StringUtils.isNotEmpty(w) && StringUtils.equals(w, "true");

    %>
    <base href="<%= httpContext %>/skins/default/"/>
    <link type="text/css" rel="stylesheet" href="<%= httpContext %>/common/css/main.css"/>
    <script type="text/javascript">
        //the following variables are used inside JavaScript resources where the JS needs to get at an image path
        var skinImgRoot = 'images/';
        //skin-level images
        var appImgRoot = '../images/';
        //application-level images
        var commonImgRoot = '<%= httpContext %>/common/images/';
        //framework-level images
        var cssModuleRoot = '<%= httpContext %>/common/css/modules/';
        //css root for various modules

        <% if (isWaiting) { %>
        function toggleLoad()
        {
            replaceClassName(document.getElementById('loader'), 'makeVisible', 'makeInVisible');
            replaceClassName(document.getElementById('mc'), 'makeInVisible', 'makeVisible');
        }
        <% } %>

        function initPage()
        {
        <% if (isWaiting) { %>
            toggleLoad();
        <% } %>
        }
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
    <script type="text/javascript" src="<%= httpContext %>/common/javascript/debug.js"></script>
    <script type="text/javascript" src="<%= httpContext %>/common/javascript/tabs.js"></script>
    <%--<script type="text/javascript" src="<%= httpContext %>/common/javascript/pagination.js"></script>--%>
</head>
<%




String strOnLoad = (String) request.getAttribute("ON_LOAD");
if (strOnLoad == null) {
    strOnLoad = "";
}




%>
<body>
    <%




     if (isWaiting) {




    %>
    <table cellpadding="0" cellspacing="0" border="0" style="height:100%;width:100%;" class="makeVisible" id="loader">
        <tr>
            <td style="vertical-align:middle;text-align:center;">
                <table border="0" cellspacing="0" cellpadding="0" align="center" style="width:150px;height:150px;">
                    <tr>
                        <td>
                            <div style="font-weight:bold;text-align:center;vertical-align:middle"><img
                                    src="<%= httpContext %>/common/images/icons/clock.gif" width="68" height="68"><br/>
                                <bean:message key="<%=FrameworkPropertyKeys.LABEL_LOADING_PAGE_PLEASE_WAIT.getKey()%>"/>
                            </div>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
    <%




     }




    %>
    <table border="0" cellspacing="0" cellpadding="0" style="width:100%;height:100%;"
    <% if (isWaiting) { %> class="makeInVisible"<% }%>
                           id="mc">
        <tr>
            <td>
                <table cellpadding="0" cellspacing="0" border="0" style="width:100%;background-color:#ffffff">
                    <tr class="headerRow">
                        <td width="189" style="vertical-align:middle">
                            <div class="lDiv"></div>
                        </td>
                        <td width="100%">
                            <table cellpadding="0" cellspacing="0" border="0" style="width:100%;">
                                <tr style="vertical-align:top;text-align:right;">
                                    <td style="text-align:right;" class="userInfoPanel">
                                        <%
                                            String userInfoBeanName = UserCache.SESSION_USER_INFO_KEY;
                                        %>
                                        <logic:present name="<%=userInfoBeanName %>">
                                            <logic:equal name="<%=userInfoBeanName %>" property="loggedIn" value="true">
                                                <table cellpadding="0" cellspacing="1" border="0" class="userInfoTable" align="right">
                                                    <tr>
                                                        <td><b>
                                                            <bean:message key="LABEL_FRAME_LOGIN_COMPANY"/>
                                                            :</b>
                                                            <bean:write
                                                                    name="<%=userInfoBeanName %>" property="userPrimOrgName"/>
                                                        </td>
                                                        <td><b>
                                                            <bean:message key="LABEL_FRAME_LOGIN_USERNAME"/>
                                                            :</b>
                                                            <bean:write
                                                                    name="<%=userInfoBeanName %>" property="userId"/>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </logic:equal>
                                        </logic:present>
                                    </td>
                                </tr>
                                <tr valign="bottom">
                                    <td>
                                        <!-- begin header tabs -->
                                        <site:navBar navBarId="TOP_TABS" format="tabs3D"/>
                                        <!-- end header tabs -->
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
                <table border="0" cellspacing="0" cellpadding="0" width="100%">
                    <tr>
                        <td class="headerActionBar">
                            <div class="menuBar">
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td style="width:100%">
                                            <% //@todo: place menus here %>
                                        </td>
                                        <td style="text-align:right;padding-right:10px;" nowrap="nowrap">
                                            <% //@todo: this is important for all projects using Sec20 %>
                                            <%-- a href="<%= request.getContextPath() %>/modifyUser20.do" class="utilLink" --%>
                                            <%-- tip="<bean:message key="SEC20_EDIT_MY_PROFILE"/>"><img --%>
                                            <%-- alt="" src="../../common/images/buttons/utilityButtons/myProfile.gif" --%>
                                            <%-- width="17" height="17" border="0" class="utilLink" /><bean:message key="SEC20_MY_PROFILE"/></a> --%>
                                            <a href="<%= request.getContextPath() %>/logoff.do" class="utilLink"
                                               tip="<bean:message key="LABEL_FRAME_LOG_OUT"/>"><img
                                                    alt="" src="../../common/images/buttons/utilityButtons/logout.gif"
                                                    width="17" height="17" border="0" class="utilLink"/>
                                                <bean:message key="LABEL_FRAME_LOG_OUT"/>
                                            </a>
                                            <a href="" onClick="popWin('<site:helpUrl />',400,700,'help');return false;" class="utilLink"
                                               tip="Open online help system"><img alt="" src="../../common/images/buttons/utilityButtons/help.gif"
                                                                                  border="0" class="utilLink"/>Help</a>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                            <!-- begin build menus -->
                            <!-- these menus can be built anywhere in the document body -->
                            <div class="menuBorder" id="createMenu">
                                <div lass="menu" onclick="cancelEventPropagation(event)">
                                    <a href="" class="menuItem" onClick="newDelivery();resetButton();return false;" accesskey="n"><span
                                            style="text-decoration:underline">N</span>ew Delivery</a>
                                    <!--<a href="" class="menuItem" onClick="newNote();resetButton();return false;" accesskey="o">New N<span style="text-decoration:underline">o</span>te...</a>-->
                                </div>
                            </div>
                            <div id="viewMenu" class="menuBorder">
                                <div class="menu" onclick="cancelEventPropagation(event)">
                                    <a href="" class="menuItem" onClick="toggleTooltips();resetButton();return false;"
                                       onmouseover="imgSwap('tipMenuCheck','<%= httpContext %>/images/menuCheck_over.gif');"
                                       onmouseout="imgRestore('tipMenuCheck');" accesskey="t" style="padding-left:3px;"><img
                                            src="<%= httpContext %>/images/menuCheck.gif" width="9" height="9" border="0"
                                            style="vertical-align:baseline;" id="tipMenuCheck">Show <span style="text-decoration:underline">T</span>oolTips</a>
                                </div>
                            </div>
                            <!-- end build menus -->
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr style="height:100%;">
            <td>
                <table border="0" cellspacing="0" cellpadding="0" style="width:100%;height:100%;">
                    <tr style="vertical-align:top;height:100%">
                        <td class="navPanel">
                            <table border="0" cellspacing="0" cellpadding="0" style="width:100%;height:100%;">
                                <tr>
                                    <td>
                                        <site:navBar slot="LEFT_NAV" format="leftNav3D" inherited="true"/>
                                    </td>
                                </tr>
                                <tr style="height:100%">
                                    <td valign="bottom" class="navUtilities">
                                        <span class="navUtilTitle"><label for="Search for">
                                            <bean:message key="LABEL_FRAME_SEARCH_TITLE"/>
                                        </label></span>

                                        <div class="searchPanel">
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td style="width:11px;background-image:url(images/pageGutterBgTile_middle.gif);background-repeat:repeat-y;"><img alt=""
                                                                                                                                         src="images/pageGutter_middleTop.gif"
                                                                                                                                         width="11"
                                                                                                                                         height="2"/>
                        </td>
                        <td class="contentPanel">
                            <table border="0" cellspacing="0" cellpadding="0" class="contentPanelTable">
                                <tr>
                                    <td>
                                        <table border="0" cellspacing="0" cellpadding="0" width="100%">
                                            <tr>
                                                <td class="actionBar">
                                                    <div class="breadcrumb">
                                                        <site:breadcrumbs/>
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <site:navBar slot="TOOLS" format="toolbar" inherited="false"/><!-- begin status area -->
                                <tr>
                                    <td class="statusArea">
                                        <layout:messagesPresent message="false">
                                            <h1 class="error"><img src="../../common/images/popupHeaders/alert.gif" width="32" height="25"
                                                                   style="vertical-align:middle">
                                                <bean:message key="LABEL_ERRORS_HEADER"/>
                                            </h1>

                                            <p class="error">
                                                <bean:message key="LABEL_ERRORS_INTRO"/>
                                            </p>
                                            <ul class="error">
                                                <html:messages id="errorB" message="false">
                                                    <li class="error">
                                                        <bean:write name="errorB"/>
                                                    </li>
                                                </html:messages>
                                            </ul>
                                        </layout:messagesPresent>
                                        <layout:messagesPresent message="true">
                                            <h1 class="warning"><img src="../../common/images/popupHeaders/warning.gif" width="32" height="25"
                                                                     style="vertical-align:middle"/>
                                                <bean:message key="LABEL_MESSAGES_INTRO"/>
                                            </h1>
                                            <ul class="warning">
                                                <html:messages id="errorA" message="true">
                                                    <li class="warning">
                                                        <bean:write name="errorA"/>
                                                    </li>
                                                </html:messages>
                                            </ul>
                                        </layout:messagesPresent>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="globalPageDescArea">
                                        <table cellpadding="0" cellspacing="0" border="0" width="100%">
                                            <tr>
                                                <td nowrap="nowrap"><h1>
                                                    <!--img src="../../common/images/popupHeaders/newAppointmentWizard.gif" width="32" height="25" style="vertical-align:middle" / -->
                                                    <site:treeName/>
                                                </h1></td>
                                                <td style="width:100%;text-align:right;">
                                                </td>
                                            </tr>
                                        </table>
                                        <site:treeDescription/>
                                    </td>
                                </tr>
                                                                                              <!-- end global page description row -->
                                <tr style="height:100%">
                                    <td>
                                        <!-- begin pageContentTag -->

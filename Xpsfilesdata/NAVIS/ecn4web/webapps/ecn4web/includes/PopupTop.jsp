<%@ page import="org.springframework.web.context.WebApplicationContext,
                 org.springframework.web.context.support.WebApplicationContextUtils,
                 com.navis.framework.web.util.ConfigKeys,
                 com.navis.framework.web.skin.ApplicationSkinner"%>
 <%--
A common "top" section of your jsp document. Include this in your page
IMMEDIATELY after setting the page id, and before doing anything else.
This include takes care of:

	1. Opening the <html>, <head>, <body> tag.
	2. Including any common Javascript, Css, etc.
	3. Drawn the whole frame of the page, including banners, login areas,
	   navbars, menus, breadcrumbs, status messages, and copyright notices.
	4. Sets <base> to the top of the templates folder, so resources can
	   be found.
	5. Leaves you in a state where you can just drawn the contents of the page.

Always pair this page with "Bottom.jsp".


Internals:
This must figure out the current template, and from there, include the
appropriate information.

Right now, it is a test.

--%>

<%
    /*
    Here, we could decide what skin to use.
    */
    WebApplicationContext wac = WebApplicationContextUtils.getWebApplicationContext(getServletConfig().getServletContext());
    ApplicationSkinner skinner = null;
    skinner = (ApplicationSkinner)wac.getBean(ConfigKeys.SKINNER, ApplicationSkinner.class);
    String filePath;
    if (skinner != null) {
        filePath = skinner.getFilePath("PopupTemplateTop.jsp");
    } else {
        filePath = "/skins/default/PopupTemplateTop.jsp";
    }
%>

<jsp:include page="<%= filePath %>" />

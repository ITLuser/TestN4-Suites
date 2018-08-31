<%@ page import="org.springframework.web.context.WebApplicationContext,
                 org.springframework.web.context.support.WebApplicationContextUtils,
                 com.navis.framework.web.util.ConfigKeys,
                 com.navis.framework.web.skin.ApplicationSkinner"%>
<%
    /*
    See ./Top.jsp.
    Here, we could decide what skin to use.
    */
    WebApplicationContext bwac = WebApplicationContextUtils.getWebApplicationContext(getServletConfig().getServletContext());
    ApplicationSkinner bskinner = null;
    bskinner = (ApplicationSkinner) bwac.getBean(ConfigKeys.SKINNER, ApplicationSkinner.class);
    String bfilePath;
    if (bskinner != null) {
        bfilePath = bskinner.getFilePath("MainTemplateBottom.jsp");
    } else {
        bfilePath = "/skins/default/MainTemplateBottom.jsp";
    }
%>

<jsp:include page="<%= bfilePath %>" />

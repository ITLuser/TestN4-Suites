<%@ page import="org.springframework.web.context.WebApplicationContext,
                 org.springframework.web.context.support.WebApplicationContextUtils,
                 com.navis.framework.web.util.ConfigKeys,
                 com.navis.framework.web.skin.ApplicationSkinner"%>
<%
    // See ./Top.jsp.
    WebApplicationContext bwac = WebApplicationContextUtils.getWebApplicationContext(getServletConfig().getServletContext());
    ApplicationSkinner bskinner = null;
    bskinner = (ApplicationSkinner) bwac.getBean(ConfigKeys.SKINNER, ApplicationSkinner.class);
    String bfilePath;
    if (bskinner != null) {
        bfilePath = bskinner.getFilePath("IFrameTemplateBottom.jsp");
    } else {
        bfilePath = "/skins/default/IFrameTemplateBottom.jsp";
    }
%>
<!-- IFrameBottom.jsp start -->
<!-- including: <%= bfilePath %> -->
<jsp:include page="<%= bfilePath %>" />
<!-- IFrameBottom.jsp end -->
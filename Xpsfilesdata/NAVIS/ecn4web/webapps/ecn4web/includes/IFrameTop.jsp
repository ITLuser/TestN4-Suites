<%@ page import="org.springframework.web.context.WebApplicationContext,
                 org.springframework.web.context.support.WebApplicationContextUtils,
                 com.navis.framework.web.util.ConfigKeys,
                 com.navis.framework.web.skin.ApplicationSkinner"%>
 <%--
See Top.jsp
--%>
<%
    /*
    Here, we could decide what skin to use.
    */
    WebApplicationContext wac = WebApplicationContextUtils.getWebApplicationContext(getServletConfig().getServletContext());
    ApplicationSkinner skinner = null;
    skinner = (ApplicationSkinner) wac.getBean(ConfigKeys.SKINNER, ApplicationSkinner.class);
    String filePath;
    if (skinner != null) {
        filePath = skinner.getFilePath("IFrameTemplateTop.jsp");
    } else {
        filePath = "/skins/default/IFrameTemplateTop.jsp";
    }
%>
<!-- IFrameTop.jsp start -->
<!-- including: <%= filePath %> -->
<jsp:include page="<%= filePath %>" />
<!-- IFrameTop.jsp end -->
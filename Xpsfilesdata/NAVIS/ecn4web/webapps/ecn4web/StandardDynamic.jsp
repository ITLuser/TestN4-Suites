<%@ page import="org.apache.commons.lang.StringUtils"%>
<%@ page language="java" %>
<%@ include file="/includes/Top.jsp" %>

<%
    /* This is the page that dynamic content gets inserted into. This could all be done
    with ONLY the servlet technogy, EXCEPT:
    - templates rely on the include mechanism. This could be written-- not too hard just
    not done.
    - templates/skins rely upon the taglibs to implement certain pieces. I do not
    currently know of a solution around this.
    In the end, this little bit of Jsp ain't so bad.
    */

    String content = (String)request.getAttribute("content");
    if (StringUtils.isNotEmpty(content)) {
        out.print(content);
    }
%>
<%@ include file="/includes/Bottom.jsp" %>

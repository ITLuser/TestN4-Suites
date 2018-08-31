<%@ page language="java" %><jsp:useBean
    id="csvTitle"
    scope="request"
    class="java.lang.String"></jsp:useBean><%
    response.setContentType("application/vnd.ms-excel");
    response.addHeader("Content-Disposition", "attachment;filename=\""+csvTitle+".csv\"");
%><jsp:useBean
    id="csvData"
    scope="request"
    class="java.lang.String">
</jsp:useBean><%=csvData%>
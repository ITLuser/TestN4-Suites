<%@ page language="java" %>
<%@ taglib prefix="layout" uri="/WEB-INF/lib/n4-layout.jar" %>
<%@ taglib prefix="site" uri="/WEB-INF/lib/n4-sitemap.jar" %>


<!-- We must set the page name first, either with a taglib or in the Action. -->

<site:setPageId pageId="PAGE_ERROR" />

<%@ include file="/includes/Top.jsp" %>
<layout:pageContent>

<table width="450" border="0" cellspacing="0" cellpadding="0" align="center">
<tr>
<td><div class="lDiv"></div></td>
</tr>
<tr>
<td>
<table border="0" cellspacing="0" cellpadding="0" align="center" class="contentTable">

<tr class="contentBodyRow" style="height:100%">
<td class="contentBody_left"><img src="../../common/images/s.gif" width="2" height="2"></td>
<td class="contentBody">
<h1 class="error"><img src="../../common/images/popupHeaders/alert.gif" width="32" height="25" style="vertical-align:middle">Error has Ocurred!</h1>
<ul>
<li class="error"></li>
</ul>
</td>
<td class="contentBody_right"><img src="../../common/images/s.gif" width="2" height="2"></td>
</tr>
<tr class="contentFooterRow">
<td class="contentFooterRow_leftCorner"><img src="../../common/images/tabs/tab1/tabBodyCorner_bottomLeft.gif" width="2" height="2"></td>
<td><img src="../../common/images/s.gif" width="1" height="2"></td>
<td><img src="../../common/images/tabs/tab1/tabBodyCorner_bottomRight.gif" width="2" height="2"></td>
</tr>
</table>
</td>
</tr>
</table>
</td>
</tr>
</table>

</layout:pageContent>
<%@ include file="/includes/Bottom.jsp" %>

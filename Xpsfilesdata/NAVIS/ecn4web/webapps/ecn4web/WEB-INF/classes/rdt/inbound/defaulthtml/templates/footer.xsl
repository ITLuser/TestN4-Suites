<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
                xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
                version='2.0'>
    <xsl:param name="contextPath"/>
    <xsl:param name="xslt.device.prefix"/>
    <xsl:param name="User-Agent"/>

    <xsl:template name="footer">
        <script type="text/javascript" src="{$contextPath}/js/jquery.js"/>
        <script type="text/javascript" src="{$contextPath}/js/poller.js"/>
        <xsl:choose>
            <xsl:when test="contains($User-Agent, 'Windows CE')">
                <script type="text/javascript" src="{$contextPath}/js/scripts_ie6_wince_fixes.js"/>
            </xsl:when>
            <xsl:otherwise>
                <script type="text/javascript" src="{$contextPath}/js/scripts.js"/>
            </xsl:otherwise>
        </xsl:choose>
        <script type="text/javascript">
            $(document).ready(function () {
                init();
            });
        </script>
    </xsl:template>

</xsl:stylesheet>

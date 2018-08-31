<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:param name="contextPath"/>
    <xsl:param name="xslt.device.prefix"/>
    <xsl:param name="User-Agent"/>

    <xsl:template name="ie-css">
        <xsl:choose>
            <xsl:when test="contains($User-Agent, 'MSIE 6')or contains($User-Agent, 'MSIE 5') or contains($User-Agent, 'MSIE 4')">
                <link rel="stylesheet" href="{concat($contextPath, '/css/', $xslt.device.prefix, '/ie6_fixes.css')}" type="text/css"/>
            </xsl:when>
            <xsl:when test="contains($User-Agent, 'MSIE 7')">
                <link rel="stylesheet" href="{concat($contextPath, '/css/', $xslt.device.prefix, '/ie7_fixes.css')}" type="text/css"/>
            </xsl:when>
            <xsl:when test="contains($User-Agent, 'MSIE 8')">
                <link rel="stylesheet" href="{concat($contextPath, '/css/', $xslt.device.prefix, '/ie8_fixes.css')}" type="text/css"/>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="ie-css-js">
        <xsl:message>User-Agent:
            <xsl:value-of select="$User-Agent"/>
        </xsl:message>
        <xsl:choose>
            <xsl:when test="contains($User-Agent, 'Windows CE')">
                <script src="{concat($contextPath, '/js/ie6_wince_fixes.js')}" type="text/javascript"/>
            </xsl:when>
            <xsl:when test="contains($User-Agent, 'MSIE 6')">
                <script src="{concat($contextPath, '/js/ie6_fixes.js')}" type="text/javascript"/>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
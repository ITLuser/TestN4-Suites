<?xml version='1.0' encoding="utf-8"?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">
    <xsl:param name="contextPath"/>
    <xsl:param name="User-Agent"/>
    <xsl:param name="xslt.device.prefix"/>
    <xsl:param name="com.navis.ecn4web.theme"/>
    <!-- This template is used to select a scheme for ECN4-Web-->
    <xsl:template name="css-theme">
        <link rel="stylesheet" href="{$contextPath}/css/{$xslt.device.prefix}/{$com.navis.ecn4web.theme}_theme.css" type="text/css"/>
        <xsl:choose>
            <xsl:when
                    test="contains($User-Agent, 'MSIE 4') or contains($User-Agent, 'MSIE 5') or contains($User-Agent, 'MSIE 6') or contains($User-Agent, 'MSIE 7')">
                <link rel="stylesheet"
                      href="{concat($contextPath, '/css/', $xslt.device.prefix, '/ie_6_and_7_' , $com.navis.ecn4web.theme, '_theme.css')}"
                      type="text/css"/>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
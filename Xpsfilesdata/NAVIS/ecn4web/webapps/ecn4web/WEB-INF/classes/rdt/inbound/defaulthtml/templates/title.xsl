<?xml version='1.0' encoding="utf-8"?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform' xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="xs"
                xmlns:text="http://www.navis.com/ecn4web/functions"
                version='2.0'>
    <xsl:param name="cheId"/>
    <xsl:param name="aCheId"/>
    <xsl:param name="sCheId"/>
    <xsl:param name="ecn4web.version"/>
    <xsl:param name="timestamp"/>

    <xsl:template name="title">
        <xsl:param name="pageTitle"/>
        <xsl:param name="mode"/>
        <xsl:param name="chassis" required="no" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="$aCheId != ''">
                <xsl:value-of select="concat($pageTitle, if($mode ne '') then
                 concat(' ', text:format(concat('mode.', $mode))) else '', ' [', $cheId, ', Asgn:',$aCheId, ']')"/>
            </xsl:when>
            <xsl:when test="$sCheId != ''">
                <xsl:value-of select="concat($pageTitle, if($mode ne '') then
                 concat(' ', text:format(concat('mode.', $mode))) else '', ' [', $cheId, ', Surr:',$sCheId, ']')"/>
            </xsl:when>
            <xsl:when test="$chassis != ''">
                <xsl:value-of select="concat($pageTitle, if($mode ne '') then
                 concat(' ', text:format(concat('mode.', $mode))) else '', ' [', $cheId,$chassis, ']')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat($pageTitle, if($mode ne '') then
                 concat(' ', text:format(concat('mode.', $mode))) else '', ' [', $cheId, ']')"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$ecn4web.version">
            <xsl:value-of select="concat(' - ECN4Web ', $ecn4web.version)"/>
        </xsl:if>
        <xsl:value-of select="concat(' ', format-dateTime(xs:dateTime($timestamp), '[H01]:[m01]:[s01]'))"/>
    </xsl:template>
</xsl:stylesheet>

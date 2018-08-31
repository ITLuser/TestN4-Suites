<?xml version='1.0' encoding='utf-8'?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:template name="main">
        <xsl:param name="cheId" required="yes"/>
        <xsl:param name="pivot" required="yes"/>
        <xsl:param name="maxPageItems" required="yes"/>
        <xsl:param name="msid" required="yes"/>
        <xsl:param name="formId" required="yes"/>
        <xsl:param name="index" required="yes"/>
        <xsl:param name="ppos" required="yes"/>
        <xsl:param name="eqId" required="yes"/>
        <xsl:variable name="size">
            <xsl:choose>
                <xsl:when test="$paginationOperator = '-'">
                    <xsl:value-of select="-number($maxPageItems)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$maxPageItems"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <message type="2630" formId="{$formId}" MSID="{$msid}">
            <che CHID="{$cheId}" action="Pull">
                <position PPOS="{ppos}" CHASSIS="{$eqId}"/>
            </che>
        </message>
    </xsl:template>
</xsl:stylesheet>

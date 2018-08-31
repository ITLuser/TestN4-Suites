<?xml version='1.0' encoding='utf-8'?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:param name="cheId" required="yes"/>
    <xsl:param name="msid" required="yes"/>
    <xsl:param name="formId" required="yes"/>
    <xsl:param name="pposTo" required="yes"/>
    <xsl:param name="eqId" required="no" select="''"/>
    <xsl:param name="lnth" required="no" select="20"/>
    <xsl:param name="spos" required="no">
        <xsl:choose>
            <xsl:when test="$lnth = 20">2</xsl:when>
            <xsl:when test="$lnth = 40">4</xsl:when>
            <xsl:otherwise>Unknown</xsl:otherwise>
        </xsl:choose>
    </xsl:param>

    <xsl:template match="/">
        <message type="2630" MSID="{$msid}" formId="{$formId}">
            <che CHID="{$cheId}" action="L" SPOS="{$spos}">
                <container EQID="{$eqId}" JPOS="CTR"/>
                <position PPOS="{$pposTo}" JPOS="CTR"/>
            </che>
        </message>
    </xsl:template>

</xsl:stylesheet>

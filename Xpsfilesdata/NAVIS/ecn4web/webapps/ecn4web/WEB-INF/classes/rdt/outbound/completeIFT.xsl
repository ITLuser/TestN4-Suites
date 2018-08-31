<?xml version='1.0' encoding="utf-8"?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:param name="cheId" required="yes"/>
    <xsl:param name="msid" required="yes"/>
    <xsl:param name="formId" required="yes"/>
    <xsl:param name="inputValue"/>
    <xsl:param name="eqId" required="yes"/>
    <xsl:param name="pposTo1" required="yes"/>
    <xsl:param name="jpos1" required="yes"/>
    <xsl:param name="trkl" select="$inputValue"/>
    <xsl:template match="/">
        <message type="2630" MSID="{$msid}" formId="{$formId}">
            <che CHID="{$cheId}" action="D">
                <container EQID="{$eqId}" TRKL="{$trkl}"/>
                <position PPOS='{$pposTo1}' JPOS='{$jpos1}'/>
            </che>
        </message>

    </xsl:template>
</xsl:stylesheet>

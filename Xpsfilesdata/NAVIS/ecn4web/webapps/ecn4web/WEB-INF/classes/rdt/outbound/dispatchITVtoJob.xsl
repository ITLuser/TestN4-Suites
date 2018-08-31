<?xml version='1.0' encoding="utf-8"?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:param name="cheId" required="yes"/>
    <xsl:param name="msid" required="yes"/>
    <xsl:param name="formId" required="yes"/>
    <xsl:param name="eqId" required="yes"/>
    <xsl:param name="inputValue"/>
    <xsl:param name="itv" select="$inputValue"/>
    <xsl:template match="/">
        <message type="2630" MSID="{$msid}" formId="{$formId}">
            <che CHID="{$cheId}" action="I">
                <container EQID="{$eqId}" CHID="{$itv}"/>
            </che>
        </message>

    </xsl:template>
</xsl:stylesheet>
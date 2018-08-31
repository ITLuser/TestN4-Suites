<?xml version='1.0' encoding='utf-8'?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href="doConfirmContainer.xsl"/>

    <xsl:param name="cheId" required="yes"/>
    <xsl:param name="msid" required="yes"/>
    <xsl:param name="formId" required="yes"/>
    <xsl:param name="mode" required="no"/>
    <xsl:param name="eqId" required="yes"/>
    <xsl:param name="inputValue" select="$eqId" required="no"/>
    <xsl:param name="eqId2" select="''" required="no"/>
    <xsl:param name="inputValue2" select="$eqId2"/>

    <xsl:template match="/">

        <xsl:call-template name="main">
            <xsl:with-param name="cheId" select="$cheId"/>
            <xsl:with-param name="msid" select="$msid"/>
            <xsl:with-param name="formId" select="$formId"/>
            <xsl:with-param name="eqId" select="$inputValue"/>
            <xsl:with-param name="eqId2" select="$inputValue2"/>
            <xsl:with-param name="mode" select="$mode"/>
        </xsl:call-template>

    </xsl:template>
</xsl:stylesheet>

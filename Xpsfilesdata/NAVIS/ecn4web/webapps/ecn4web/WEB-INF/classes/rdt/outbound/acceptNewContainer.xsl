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
    <xsl:param name="pposTo" required="no"/>
    <xsl:param name="mode" required="yes"/>
    <xsl:param name="index" required="yes"/>
    <xsl:param name="inputValue"/>
    <xsl:param name="inputValue2" required="no"/>

    <xsl:template match="/">

        <xsl:call-template name="main">
            <xsl:with-param name="cheId" select="$cheId"/>
            <xsl:with-param name="msid" select="$msid"/>
            <xsl:with-param name="formId" select="$formId"/>
            <xsl:with-param name="eqId" select="$inputValue"/>
            <xsl:with-param name="eqId2" select="$inputValue2"/>
            <xsl:with-param name="mode" select="$mode"/>
            <xsl:with-param name="pposTo" select="''"/>
        </xsl:call-template>

    </xsl:template>
</xsl:stylesheet>

<?xml version='1.0' encoding='utf-8'?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <!-- This template is a pre-processor  for the show job list request to include pagination attributes -->
    <xsl:import href="doDropContainer.xsl"/>

    <xsl:param name="cheId" required="yes"/>
    <xsl:param name="msid" required="yes"/>
    <xsl:param name="formId" required="yes"/>
    <xsl:param name="pposTo1" required="yes"/>
    <xsl:param name="pposTo2" select="''" required="no"/>
    <xsl:param name="jpos1" required="no"/>
    <xsl:param name="jpos2" select="''" required="no"/>
    <xsl:param name="mode" required="yes"/>
    <xsl:template match="/">
        <xsl:call-template name="main">
            <xsl:with-param name="cheId" select="$cheId"/>
            <xsl:with-param name="formId" select="$formId"/>
            <xsl:with-param name="msid" select="$msid"/>
            <xsl:with-param name="jpos1" select="$jpos1"/>
            <xsl:with-param name="jpos2" select="$jpos2"/>
            <xsl:with-param name="pposTo1" select="$pposTo2"/>
            <xsl:with-param name="pposTo2" select="$pposTo1"/>
        </xsl:call-template>
    </xsl:template>
</xsl:stylesheet>

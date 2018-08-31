<?xml version='1.0' encoding="utf-8"?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->
<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform' version='2.0'>
    <xsl:import href="parkTrailer.xsl"/>

    <xsl:param name="cheId" required="yes"/>
    <xsl:param name="formId" required="yes"/>
    <xsl:param name="msid" required="yes"/>
    <xsl:param name="index" required="yes"/>
    <xsl:param name="inputValue" required="yes"/>

    <xsl:template match="/">

        <xsl:call-template name="mainTemplate">
            <xsl:with-param name="cheId" select="$cheId"/>
            <xsl:with-param name="formId" select="$formId"/>
            <xsl:with-param name="msid" select="$msid"/>
            <xsl:with-param name="index" select="$index"/>
            <xsl:with-param name="inputValue" select="$inputValue"/>
            <xsl:with-param name="action" select="'Park'"/>
        </xsl:call-template>

    </xsl:template>

</xsl:stylesheet>
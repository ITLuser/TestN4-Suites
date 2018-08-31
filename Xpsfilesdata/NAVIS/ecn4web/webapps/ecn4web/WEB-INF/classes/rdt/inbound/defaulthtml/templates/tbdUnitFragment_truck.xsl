<?xml version='1.0' encoding="utf-8"?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
                xmlns:text="http://www.navis.com/ecn4web/functions"
                exclude-result-prefixes="text"
                version='2.0'>
    <xsl:import href="functions.xsl"/>
    <xsl:template match="tbdunit">
        <xsl:value-of select='@LOPR'/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="." mode="hght-attr"/>
        <xsl:text> </xsl:text>
    </xsl:template>

    <!--done to avoid masking the same template used for straddle, acts as a tunnel template-->
    <xsl:template match="tbdunit" mode="first">
        <xsl:apply-templates select="."/>
    </xsl:template>

</xsl:stylesheet>


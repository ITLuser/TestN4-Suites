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
        <xsl:value-of select="text:format('label.Line_Op')"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select='@LOPR'/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="text:format('label.Type')"/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="." mode="hght-attr"/>
        <xsl:apply-templates select="." mode="prefix"/>
    </xsl:template>
    <!--
    <xsl:template match="tbdunit" mode="prefix">
        <br/>
        <xsl:value-of select="text:format('label.Prefix')"/>
        <xsl:text> </xsl:text>
        <xsl:for-each select="tokenize(@TBDR, ', ')">
            <div class="line-item">
                <xsl:value-of select="."/>
            </div>
        </xsl:for-each>
    </xsl:template>
    -->
    <!--Display tbd unit info for first one and prefix details only for second tbdunit. Both tbds have the same details-->
    <xsl:template match="tbdunit" mode="first">
        <xsl:choose>
            <xsl:when test="ancestor::work/job[1]/tbdunit/@EQID eq @EQID">
                <xsl:apply-templates select="."/>
            </xsl:when>
            <!--Display prefix only for 2nd tbdunit-->
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="prefix"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>


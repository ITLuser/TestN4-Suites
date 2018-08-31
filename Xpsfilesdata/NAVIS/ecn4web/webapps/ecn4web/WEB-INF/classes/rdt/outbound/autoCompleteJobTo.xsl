<?xml version='1.0' encoding="utf-8"?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:param name="cheId" required="yes"/>
    <xsl:param name="msid" required="yes"/>
    <xsl:param name="formId" required="yes"/>
    <xsl:param name="inputValue" required="no"/>
    <xsl:param name="eqId" required="no"/>
    <xsl:param name="pposTo" required="yes"/>
    <xsl:template match="/">

        <xsl:variable name="toPos">
            <xsl:choose>
                <xsl:when test="$inputValue">
                    <xsl:value-of select="$inputValue"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$pposTo"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <message type="2630" MSID="{$msid}" formId="{$formId}">
            <che CHID="{$cheId}" action="C">
                <xsl:call-template name="main">
                    <xsl:with-param name="eqIdParam" select="$eqId"/>
                    <xsl:with-param name="pposToParam" select="$toPos"/>
                </xsl:call-template>
            </che>
        </message>

    </xsl:template>

    <xsl:template name="main">
        <xsl:param name="eqIdParam"/>
        <xsl:param name="pposToParam"/>
        <container EQID="{$eqIdParam}">
            <position PPOS="{$pposToParam}"/>
        </container>
    </xsl:template>

</xsl:stylesheet>

<?xml version='1.0' encoding="utf-8"?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
                xmlns:text="http://www.navis.com/ecn4web/functions"
                exclude-result-prefixes="text"
                version='2.0'>
    <xsl:import href="/templates/functions.xsl"/>
    <xsl:template match="job" mode="instruction">
        <xsl:choose>
            <xsl:when test="@moveStage = 'CARRY_UNDERWAY' and container and (container/@JPOS = 'FWD' or container/@PUTJPOS = 'FWD')">
                <xsl:value-of
                        select="text:format('message.Laden', concat(text:format('message.Twin_Forward_abbreviation'),' ',container/@EQID))"/>
            </xsl:when>
            <xsl:when test="@moveStage = 'CARRY_UNDERWAY' and container and (container/@JPOS = 'AFT' or container/@PUTJPOS = 'AFT')">
                <xsl:value-of
                        select="text:format('message.Laden', concat(text:format('message.Twin_After_abbreviation'),' ',container/@EQID))"/>
            </xsl:when>
            <xsl:when test="@moveStage = 'CARRY_UNDERWAY' and container and (container/@JPOS = 'CTR' or container/@PUTJPOS = 'CTR')">
                <xsl:value-of select="text:format('message.Laden', container/@EQID)"/>
            </xsl:when>
            <xsl:when test="@moveStage = 'CARRY_UNDERWAY' and container">
                <xsl:value-of select="text:format('message.Laden', container/@EQID)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="text:format('message.Drive_to')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="@AREA_TYPE[. = 'YardRow']">
        <xsl:choose>
            <xsl:when test="parent::position/transferZone[1]">
                <xsl:value-of select="text:format('message.Block')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="text:format('message.Row')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'YardRowWheeled']">
        <xsl:value-of select="text:format('message.Wheeled')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'YardTransTZ']">
        <xsl:value-of select="text:format('message.CARMGTZ')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'YardBlock']">
        <xsl:value-of select="text:format('message.Block')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'YardLSTZ']">
        <xsl:value-of select="text:format('message.LSTZ')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'YardWSTZ']">
        <xsl:value-of select="text:format('message.WSTZ')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'YardRailTZ']">
        <xsl:value-of select="text:format('message.RAILTZ')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'YardVesselTZ']">
        <xsl:value-of select="text:format('message.VESSELTZ')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'YardTransTZ']">
        <xsl:value-of select="text:format('message.CARMGTZ')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'Vessel']">
        <xsl:value-of select="text:format('message.Crane')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'Rail']">
        <xsl:value-of select="text:format('message.POW')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'Grid']">
        <xsl:value-of select="text:format('message.Grid')"/>
    </xsl:template>
    <xsl:template match="container">
        <xsl:value-of select="@EQTP"/>
    </xsl:template>

</xsl:stylesheet>
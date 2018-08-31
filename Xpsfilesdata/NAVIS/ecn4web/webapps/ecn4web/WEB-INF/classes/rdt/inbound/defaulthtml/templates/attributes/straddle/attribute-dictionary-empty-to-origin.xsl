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
        <xsl:value-of select="text:format('message.Drive_to')"/>
    </xsl:template>
    <xsl:template match="option[matches(@AREA_TYPE, 'YardRow|YardRowWheeled')]">
        <xsl:value-of select="text:format('message.Row')"/>
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
    <xsl:template match="@AREA_TYPE[. = 'YardRailStackTZ']">
        <xsl:value-of select="text:format('message.RAILTZ')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'YardVesselTZ']">
        <xsl:value-of select="text:format('message.VESSELTZ')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'Vessel']">
        <xsl:value-of select="text:format('message.Crane')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'Rail']">
        <xsl:value-of select="text:format('message.Track')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'Grid']">
        <xsl:value-of select="text:format('message.Grid')"/>
    </xsl:template>
    <xsl:template match="job[child::position[@type = 'from'][@VBAY != '']]" mode="line-one-variable">
        (<xsl:value-of select="position[@type = 'from']/@VBAY"/>)
    </xsl:template>
    <xsl:template match="job[@ingress != '']" mode="line-one-variable">-<xsl:value-of select="@ingress"/>
    </xsl:template>
    <xsl:template match="job[@ingressTierwise != '']" mode="line-one-variable-2">-<xsl:value-of select="@ingressTierwise"/>
    </xsl:template>
    <xsl:template match="@MVKD[. = 'LOAD']" mode="line-two-variable">
        <xsl:text> ==&gt; </xsl:text><xsl:value-of select="../position[@type = 'to']/@AREA"/>
    </xsl:template>
    <xsl:template match="container[@OD = 'Y']">
        <div>
            <xsl:value-of select="text:format('message.Planned_lift_is_OD,_verify_if_special_gear_required')"/>
        </div>
    </xsl:template>
</xsl:stylesheet>
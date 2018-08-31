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
        <xsl:value-of select="text:format('message.Lift')"/>
    </xsl:template>
    <xsl:template
            match="job[@MVKD = 'DSCH' and ancestor::work[@moveStage = 'PLANNED'] and child::position[@type = 'from'][@AREA_TYPE = 'Vessel' or @AREA_TYPE = 'Rail']]" mode="instruction">
        <xsl:value-of select="text:format('message.Stand_by_for_discharge')"/>
    </xsl:template>
    <xsl:template match="option[matches(@AREA_TYPE, 'YardRow|YardRowWheeled')]">
        <xsl:value-of select="text:format('message.from_Slot')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'YardBlock']">
        <xsl:value-of select="text:format('message.from_Block')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'YardLSTZ']">
        <xsl:value-of select="text:format('message.from_LSTZ')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'YardWSTZ']">
        <xsl:value-of select="text:format('message.from_WSTZ')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'YardRailStackTZ']">
        <xsl:value-of select="text:format('message.from_RAILTZ')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'YardVesselTZ']">
        <xsl:value-of select="text:format('message.from_VESSELTZ')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'Vessel']">
        <xsl:value-of select="text:format('message.under_Crane')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'Rail']">
        <xsl:value-of select="text:format('message.by_Car')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'Grid']">
        <xsl:value-of select="text:format('message.from_Grid')"/>
    </xsl:template>
    <xsl:template match="container">
        <xsl:value-of select="@EQID"/>
    </xsl:template>
    <xsl:template match="job[child::position[@type = 'from'][@VBAY != '']]" mode="line-one-variable">(<xsl:value-of
            select="position[@type = 'from']/@VBAY"/>)
    </xsl:template>
    <xsl:template match="job[@ingress != '']" mode="line-one-variable">-<xsl:value-of select="@ingress"/>
    </xsl:template>
    <xsl:template match="job[@ingressTierwise != '']" mode="line-one-variable-2">-<xsl:value-of select="@ingressTierwise"/>
    </xsl:template>
    <xsl:template match="@MVKD[. = 'LOAD']" mode="line-two-variable">
        <xsl:text> ==&gt; </xsl:text><xsl:value-of select="job/position[@type = 'to']/@AREA"/>
    </xsl:template>
    <xsl:template match="job[@MVKD = 'RECV']" mode="line-two-variable">
        <xsl:value-of select="text:format('message.on_Truck', position[@type = 'from']/@TRKL)"/>
    </xsl:template>
</xsl:stylesheet>
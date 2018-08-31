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
        <xsl:value-of select="text:format('message.Carry')"/>
    </xsl:template>
    <xsl:template match="option[matches(@AREA_TYPE, 'YardRow|YardRowWheeled')]">
        <xsl:value-of select="text:format('message.to_Row')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'YardRow']">
        <xsl:value-of select="text:format('message.to_Row')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'YardBlock']">
        <xsl:value-of select="text:format('message.to_Block')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'YardLSTZ']">
        <xsl:value-of select="text:format('message.to_LSTZ')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'YardWSTZ']">
        <xsl:value-of select="text:format('message.to_WSTZ')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'YardRailStackTZ']">
        <xsl:value-of select="text:format('message.to_RAILTZ')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'YardVesselTZ']">
        <xsl:value-of select="text:format('message.to_VESSELTZ')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'Vessel']">
        <xsl:value-of select="text:format('message.to_Crane')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'Rail']">
        <xsl:value-of select="text:format('message.to_Track')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'Grid']">
        <xsl:value-of select="text:format('message.to_Grid')"/>
    </xsl:template>
    <xsl:template match="job[child::position[@type = 'to'][@VBAY != '']]" mode="line-one-variable">(<xsl:value-of
            select="position[@type = 'to']/@VBAY"/>)
    </xsl:template>
    <xsl:template match="job[@ingress != '']" mode="line-one-variable">-<xsl:value-of select="@ingress"/>
    </xsl:template>
    <xsl:template match="job[@ingressTierwise != '']" mode="line-one-variable-2">-<xsl:value-of select="@ingressTierwise"/>
    </xsl:template>
    <xsl:template match="job[@MVKD = 'DLVR' and child::position[@AREA_TYPE = 'Grid']]" mode="line-two-variable">
        <xsl:value-of select="text:format('message.Trk', position[@type = 'to']/@TRKL)"/>
    </xsl:template>
    <xsl:template match="job[@MVKD = 'LOAD' and @twinPut != '' and ancestor::work[@count = '1']]" mode="line-three-variable-1">
        <xsl:value-of select="text:format('message.Twin_With', @twinPut)"/>
    </xsl:template>
    <xsl:template match="job[ancestor::work[@count = '2']]" mode="line-three-variable-1">
        <!-- only display Twin Carry after the last job otherwise its redundant-->
        <xsl:if test="not(following-sibling::*)">
            <xsl:value-of select="text:format('message.Twin_Carry')"/>
        </xsl:if>
    </xsl:template>
    <xsl:template match="job[@MVKD = 'LOAD' and child::position[@type = 'to' and @AREA_TYPE = 'Vessel']]"
                  mode="line-three-variable-2">
        <xsl:apply-templates select="position[@type = 'to']/@DOOR"/>
    </xsl:template>
</xsl:stylesheet>
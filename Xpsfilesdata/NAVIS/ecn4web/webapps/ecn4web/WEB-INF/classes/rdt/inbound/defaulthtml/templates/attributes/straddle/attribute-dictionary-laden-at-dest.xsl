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
        <xsl:value-of select="text:format('message.Place')"/>
    </xsl:template>
    <xsl:template match="option[matches(@AREA_TYPE, 'YardRow|YardRowWheeled')]">
        <xsl:value-of select="text:format('message.in_Slot')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'YardBlock']">
        <xsl:value-of select="text:format('message.in_Block')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'YardLSTZ']">
        <xsl:value-of select="text:format('message.in_LSTZ')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'YardWSTZ']">
        <xsl:value-of select="text:format('message.in_WSTZ')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'YardRailStackTZ']">
        <xsl:value-of select="text:format('message.in_RAILTZ')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'YardVesselTZ']">
        <xsl:value-of select="text:format('message.in_VESSELTZ')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'Vessel']">
        <xsl:value-of select="text:format('message.under_Crane')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'Rail']">
        <xsl:value-of select="text:format('message.by_Car')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'Grid']">
        <xsl:value-of select="text:format('message.onto_Truck')"/>
    </xsl:template>
    <xsl:template match="job[child::position[@type = 'to'][@VBAY != '']]" mode="line-one-variable">(<xsl:value-of
            select="position[@type = 'to']/@VBAY"/>)
    </xsl:template>
    <xsl:template match="job[@ingress != '']" mode="line-one-variable">-<xsl:value-of select="@ingress"/>
    </xsl:template>
    <xsl:template match="job[@ingressTierwise != '']" mode="line-one-variable-2">-<xsl:value-of select="@ingressTierwise"/>
    </xsl:template>
    <xsl:template match="job[child::position[@type = 'to'][@AREA_TYPE = 'Grid']]" mode="line-two-variable">
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
    <xsl:template match="job[@MVKD = 'DLVR'][child::position[@type = 'to'][@AREA_TYPE = 'Grid']]"
                  mode="line-three-variable-2">
        <br/>
        <xsl:variable name="door-attr">
            <xsl:apply-templates select="position[@type = 'to']/@DOOR"/>
        </xsl:variable>
        <xsl:value-of select="text:format('message.Truck_position', (position[@type = 'to']/@TKPS, $door-attr))"/>
    </xsl:template>
    <xsl:template match="@MVKD[. = 'LOAD']" mode="partner">
        <xsl:if test="ancestor::job[@partnerContainer]">
            <xsl:value-of select="concat(' ',text:format('message.PartnerWith', ancestor::job/@partnerContainer))"/>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
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

    <xsl:template match="job[position[@type='to' and @parkable]]" mode="instruction">
        <xsl:value-of select="text:format('message.Park')"/>
    </xsl:template>
    <xsl:template match="job" mode="instruction">
        <xsl:value-of select="text:format('message.Wait')"/>
    </xsl:template>

    <xsl:template match="job[(container/@JPOS = 'FWD' or container/@PUTJPOS = 'FWD') and /message/che/work/@planningIntent='TWIN']" mode="position">
        <xsl:value-of select="text:format('message.Twin_Forward_abbreviation')"/>
    </xsl:template>

    <xsl:template match="job[(container/@JPOS = 'AFT' or container/@PUTJPOS = 'AFT') and /message/che/work/@planningIntent='TWIN']" mode="position">
        <xsl:value-of select="text:format('message.Twin_After_abbreviation')"/>
    </xsl:template>

    <xsl:template match="@AREA_TYPE[. = 'YardRow']">
        <xsl:value-of select="text:format('message.by_Slot')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'YardBlock']">
        <xsl:value-of select="text:format('message.by_Block')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'YardRowWheeled']">
        <xsl:value-of select="text:format('message.in_Wheeled')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'YardLSTZ']">
        <xsl:value-of select="text:format('message.in_LSTZ')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'YardWSTZ']">
        <xsl:value-of select="text:format('message.in_WSTZ')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'YardRailTZ']">
        <xsl:value-of select="text:format('message.in_RAILTZ')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'YardVesselTZ']">
        <xsl:value-of select="text:format('message.in_VESSELTZ')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'YardTransTZ']">
        <xsl:value-of select="text:format('message.in_CARMGTZ')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'Vessel']">
        <xsl:value-of select="text:format('message.by_Crane')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'Rail']">
        <xsl:choose>
            <xsl:when test="/message/che/work/job[1]/position[@type = 'from'][@TPOS]">
                <xsl:value-of select="text:format('message.by_Track')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="text:format('message.by_Car')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'Grid']">
        <xsl:value-of select="text:format('message.by_Grid')"/>
    </xsl:template>
    <xsl:template match="@MVKD[. = 'LOAD']" mode="partner">
        <xsl:if test="ancestor::work[@pairedCHE]">
            <xsl:value-of select="concat(' ',text:format('message.PartnerWith', ancestor::work/@pairedCHE))"/>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
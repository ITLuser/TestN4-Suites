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

    <xsl:template match="job[@moveStage = 'CARRY_UNDERWAY' and tbdunit]" mode="instruction">
        <xsl:value-of select="text:format('message.Laden', tbdunit/@EQID)"/>
    </xsl:template>

    <xsl:template match="job[@moveStage = 'CARRY_UNDERWAY' and container]" mode="instruction">
        <xsl:choose>
            <xsl:when test="container/@JPOS = 'FWD' or container/@PUTJPOS = 'FWD'">
                <xsl:value-of
                        select="text:format('message.Laden', concat(' ',text:format('message.Twin_Forward_abbreviation'),' ',container/@EQID))"/>
            </xsl:when>
            <xsl:when test="container/@JPOS = 'AFT' or container/@PUTJPOS = 'AFT'">
                <xsl:value-of
                        select="text:format('message.Laden', concat(' ',text:format('message.Twin_After_abbreviation'),' ',container/@EQID))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="text:format('message.Laden', container/@EQID)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="job[@moveStage != 'CARRY_UNDERWAY']" mode="instruction">
        <xsl:apply-templates select="position[@type='from']"/>
    </xsl:template>

    <xsl:template match="position[@parkable]">
        <xsl:value-of select="concat(text:format('message.Park'), ' ', ../../../@CHASSIS, ' ', text:format('message.at'))"/>
    </xsl:template>

    <xsl:template match="position[@pullable]">
        <xsl:value-of select="concat(text:format('message.Pull'), ' ', ../container/@EQID)"/>
        <xsl:text> </xsl:text>
        <xsl:if test="/message/che/work/boolean(@chassisQual)">
            <xsl:value-of select="text:format('message.on')"/>
        </xsl:if>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="/message/che/work/@chassisQual"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="text:format('message.from')"/>
    </xsl:template>

    <xsl:template match="position">
        <xsl:value-of select="text:format('message.Wait')"/>
        <xsl:apply-templates select="../@MVKD" mode="waiting"/>
    </xsl:template>

    <xsl:template match="@MVKD[. = 'DSCH']" mode="waiting">
        <xsl:value-of select="' '"/>
        <xsl:apply-templates select="../../@planningIntent"/>
        <xsl:apply-templates select="../../@pairedCHE"/>
        <xsl:if test="../../@moveStage = 'PLANNED' and ../position[@type = 'from']/@AREA_TYPE = 'Vessel'">
            <xsl:value-of select="concat(' ',text:format('message.at'))"/>
            <xsl:value-of select="concat(' ',text:format('message.Crane'),' ')"/>
            <xsl:value-of select="../position[@type = 'from']/@AREA"/>
        </xsl:if>
    </xsl:template>
    <xsl:template match="@MVKD[. != 'DSCH']" mode="waiting"/>

    <xsl:template match="@planningIntent[contains(., 'LANDSIDE')]">
        <xsl:value-of select="text:format('message.Landside')"/>
    </xsl:template>

    <xsl:template match="@planningIntent[contains(., 'WATERSIDE')]">
        <xsl:value-of select="text:format('message.Waterside')"/>
    </xsl:template>

    <xsl:template match="@pairedCHE">
        <xsl:value-of select="concat(' ',text:format('message.PartnerWith', .))"/>
    </xsl:template>

    <xsl:template match="@AREA_TYPE[. = 'YardRow']">
        <xsl:value-of select="text:format('message.by_Slot')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'YardRowWheeled']">
        <xsl:value-of select="text:format('message.Wheeled')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'YardBlock']">
        <xsl:value-of select="text:format('message.by_Block')"/>
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

</xsl:stylesheet>
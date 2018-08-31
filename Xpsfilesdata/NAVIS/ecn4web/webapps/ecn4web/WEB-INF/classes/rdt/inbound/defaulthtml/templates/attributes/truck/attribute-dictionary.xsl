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

    <!--customized pull chassis mission statement for FORM_TRUCK_FETCH_TRAILER-->
    <xsl:template name="pull-chassis-message">
        <xsl:value-of select="text:format('message.Pull')"/>
        <xsl:text> </xsl:text>
        <xsl:call-template name="chassis-length"/>
        <xsl:value-of select="text:format('unit.Feet_abbreviation')" disable-output-escaping="yes"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="/message/che/work/job[1]/container[1]/@LOPR"/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="/message/che/work/@chassisQual"/>
        <xsl:apply-templates select="/message/che/work"/>
        <xsl:apply-templates select="/message/che/work/@chassisName"/>
        <xsl:apply-templates select="/message/che/work/@chassisPos"/>
    </xsl:template>

    <xsl:template match="/message/che/work/@chassisQual">
        <xsl:choose>
            <xsl:when test="/message/che/work/@chassisQual='C'">
                <xsl:value-of select="text:format('message.Chassis')"/>
            </xsl:when>
            <xsl:when test="/message/che/work/@chassisQual='S'">
                <xsl:value-of select="text:format('message.Cassette')"/>
            </xsl:when>
            <xsl:when test="/message/che/work/@chassisQual='K'">
                <xsl:value-of select="text:format('message.TrackedBombcart')"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="/message/che/work/@chassisName">
        <xsl:text> </xsl:text>
        <xsl:value-of select="/message/che/work/@chassisName"/>
    </xsl:template>

    <xsl:template match="/message/che/work">
        <xsl:if test="exists(/message/che/work[not(@chassisQual)])">
            <xsl:value-of select="text:format('message.Chassis')"/>        </xsl:if>
    </xsl:template>

    <xsl:template match="/message/che/work/@chassisPos">
        <xsl:text> </xsl:text>
        <xsl:value-of select="text:format('message.from')"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="/message/che/work/@chassisPos"/>
    </xsl:template>

    <xsl:template match="/message/che/@CHASSIS" mode="line-three-variable-two">
        <xsl:value-of select="text:format('message.Open_bracket')"/>
        <xsl:value-of select="text:format('message.Need')"/>
        <xsl:text> </xsl:text>
        <xsl:call-template name="chassis-length"/>
        <xsl:value-of select="text:format('unit.Feet_abbreviation')" disable-output-escaping="yes"/>
        <xsl:text> </xsl:text>
        <xsl:choose>
            <xsl:when test="../@isCassette='Y'">
                <xsl:value-of select="text:format('message.Cassette')"/>
            </xsl:when>
            <xsl:when test=". != 'BOMBCART'">
                <xsl:value-of select="/message/che/work/job[1]/container[1]/@LOPR"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="text:format('message.Chassis')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="text:format('message.Bombcart')"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="text:format('message.Close_bracket')"/>
    </xsl:template>

    <!--Chassis length calculated as sum of length of all container in job
        Example with two containers of length 20' each, chassis length will be 40'-->
    <xsl:template name="chassis-length">
        <xsl:value-of select="sum(/message/che/work/job/*/@LNTH)"/>
    </xsl:template>

    <!--Get chassis id-->
    <xsl:template match="/message/che/@CHASSIS[. != 'BOMBCART']">
        <xsl:value-of select="text:format('message.Chassis_colon_chassis_id',/message/che/@CHASSIS)"/>
    </xsl:template>

    <!--Get customized Bombcart (special kind of chassis)-->
    <xsl:template match="/message/che/@CHASSIS[. = 'BOMBCART']">
        <xsl:value-of select="text:format('message.Chassis_colon_chassis_id',text:format('message.Bombcart'))"/>
    </xsl:template>

    <!--wait message for TRUCK_IDLE-->
    <xsl:template name="wait-message">
        <xsl:value-of select="text:format('message.Await_for_next_job')"/>
    </xsl:template>

</xsl:stylesheet>
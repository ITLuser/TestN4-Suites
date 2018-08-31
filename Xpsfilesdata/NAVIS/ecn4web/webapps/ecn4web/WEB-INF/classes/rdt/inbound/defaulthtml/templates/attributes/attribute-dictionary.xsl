<?xml version='1.0' encoding="utf-8"?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
                xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
                xmlns:text="http://www.navis.com/ecn4web/functions"
                exclude-result-prefixes="text"
                version='2.0'>
    <xsl:import href="/templates/functions.xsl"/>
    <xsl:template match="@MVKD[. = 'LOAD']">
        <xsl:value-of select="text:format('message.Vessel_Load')"/>
    </xsl:template>
    <xsl:template match="@MVKD[. = 'YARD']">
        <xsl:value-of select="text:format('message.Yard')"/>
    </xsl:template>
    <xsl:template match="@MVKD[. = 'DSCH']">
        <xsl:value-of select="text:format('message.Vessel_Discharge')"/>
    </xsl:template>
    <xsl:template match="@MVKD[. = 'SHFT']">
        <xsl:value-of select="text:format('message.Yard_Shift')"/>
    </xsl:template>
    <xsl:template match="@MVKD[. = 'RECV']">
        <xsl:value-of select="text:format('message.Receival')"/>
    </xsl:template>
    <xsl:template match="@MVKD[. = 'DLVR']">
        <xsl:value-of select="text:format('message.Delivery')"/>
    </xsl:template>
    <xsl:template match="@MVKD[. = 'RDSC']">
        <xsl:value-of select="text:format('message.Rail_Disch')"/>
    </xsl:template>
    <xsl:template match="@MVKD[. = 'RLOD']">
        <xsl:value-of select="text:format('message.Rail_Load')"/>
    </xsl:template>

    <xsl:template match="@DOOR[. = 'A']">
        <xsl:value-of select="text:format('message.Doors_facing_Aft')"/>
    </xsl:template>
    <xsl:template match="@DOOR[. = 'F']">
        <xsl:value-of select="text:format('message.Doors_facing_Fwd')"/>
    </xsl:template>
    <xsl:template match="container/@QWGT">
        <xsl:value-of select="concat(round(number(.) div 1000), text:format('unit.T'))"/>
    </xsl:template>
    <xsl:template match="container/@LNTH">
        <xsl:value-of select="."/>'
    </xsl:template>

    <xsl:template match="@AREA">
        <xsl:variable name="transferZone" select="parent::position/transferZone[1]/@BLOCK"/>
        <xsl:choose>
            <!--use transfer zone block if going to/from CARMG-->
            <xsl:when test="$transferZone">
                <xsl:value-of select="$transferZone"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tbdunit" mode="hght-attr">
        <xsl:variable name="apos">&apos;</xsl:variable>
        <xsl:variable name="quot">&quot;</xsl:variable>
        <xsl:variable name="feet" select='substring(@HGHT_DISP, 1, 1)'/>
        <xsl:variable name="inches" select='substring(@HGHT_DISP, 2, 1)'/>
        <xsl:value-of
                select="normalize-space(concat(@LNTH, $apos, ' ', @ISGP, ' ', $feet, $apos, $inches, $quot))"/>
    </xsl:template>
    <xsl:template match="@MVKD[. = 'LOAD']" mode="planningIntent">
        <xsl:if test="contains(ancestor::work/@planningIntent, 'LANDSIDE')">
            <xsl:value-of select="text:format('message.Landside')"/>
        </xsl:if>
        <xsl:if test="contains(ancestor::work/@planningIntent, 'WATERSIDE')">
            <xsl:value-of select="text:format('message.Waterside')"/>
        </xsl:if>
    </xsl:template>
    <xsl:template match="@MVKD[. = 'LOAD' or . = 'DSCH']" mode="driveDirection">
        <xsl:if test="ancestor::work/@driveDirection">
            <xsl:text>(</xsl:text>
            <xsl:value-of select="ancestor::work/@driveDirection"/>
            <xsl:text>)</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="work">
        <xsl:variable name="MEN_WORKING" select="'MEN_WORKING'"/>
        <xsl:variable name="positions">
            <xsl:value-of
                    select="job/position[contains(@warning, $MEN_WORKING)]/@PPOS | job/position/transferZone[contains(@warning, $MEN_WORKING)]/@BLOCK"/>
        </xsl:variable>
        <xsl:call-template name="men-working">
            <xsl:with-param name="positions" select="$positions"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="work" mode="position-type">
        <xsl:param name="position-type" required="yes"/>
        <xsl:param name="che-in-transferZone" required="no"/>
        <xsl:variable name="MEN_WORKING" select="'MEN_WORKING'"/>
        <xsl:variable name="positions">
            <xsl:choose>
                <xsl:when test="$che-in-transferZone">
                    <!--Assuming CHE location to be not null at this point-->
                    <xsl:variable name="che-location" select="if (parent::che/@location) then parent::che/@location else ''"/>
                    <xsl:value-of
                            select="job/position[@type = $position-type and contains(@warning, $MEN_WORKING)]/@PPOS
                                            | job/position[@type = $position-type]/transferZone[contains($che-location, @BLOCK)][contains(@warning, $MEN_WORKING)]/@BLOCK"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                            select="job/position[@type = $position-type and contains(@warning, $MEN_WORKING)]/@PPOS
                                            | job/position[@type = $position-type]/transferZone[contains(@warning, $MEN_WORKING)]/@BLOCK"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:call-template name="men-working">
            <xsl:with-param name="positions" select="$positions"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="men-working">
        <xsl:param name="positions"/>
        <xsl:if test="$positions != ''">
            <div class="message-fragment workZone">
                <div class="exclamation-button warning-color"/>
                <xsl:value-of select="text:format('message.Caution_Men_Working_Around')"/>
                <xsl:text> </xsl:text>
                <xsl:call-template name="list-positions">
                    <xsl:with-param name="positions" select="$positions"/>
                </xsl:call-template>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="list-positions">
        <xsl:param name="positions" required="yes"/>
        <xsl:variable name="count" select="count(tokenize($positions, ' '))"/>
        <xsl:for-each select="tokenize($positions, ' ')">
            <xsl:choose>
                <xsl:when test="contains(.,'.')">
                    <xsl:value-of select="substring-before(., '.')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="string(.)"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="position() != last() and $count gt 1">
                <xsl:text>, </xsl:text>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <!-- This index serializes all container items to string form: 1:TEST0000001:FWD:AA21:Yard, ...
    This field will be processed by the outbound message to ECN4 -->
    <xsl:template match="job" mode="indexEmpty">
        <xsl:value-of select="position()"/>
        <xsl:text>:</xsl:text><xsl:value-of select="container/@EQID|tbdunit/@EQID"/>
        <xsl:text>:</xsl:text><xsl:value-of select="container/@JPOS|tbdunit/@JPOS"/>
        <xsl:text>:</xsl:text><xsl:value-of select="position[@type = 'from']/@PPOS"/>
        <xsl:text>:</xsl:text><xsl:value-of select="position[@type = 'from']/@pullable"/>
        <xsl:text>:</xsl:text>
        <xsl:choose>
            <xsl:when test="container[@swappableDelivery = 'Y']">e</xsl:when>
            <xsl:when test="container">c</xsl:when>
            <xsl:when test="tbdunit">t</xsl:when>
        </xsl:choose>
        <xsl:text>:</xsl:text><xsl:value-of select="position[@type = 'from']/transferZone[1]/@BLOCK"/>
        <xsl:text>:</xsl:text><xsl:value-of select="position[@type = 'from']/transferZone[2]/@BLOCK"/>
        <xsl:if test="position() != last()">,</xsl:if>
    </xsl:template>

    <!-- This index serializes all container items to string form: 1:TEST0000001:FWD:AA21:Yard, ...
    This field will be processed by the outbound message to ECN4 -->
    <xsl:template match="job" mode="indexLaden">
        <xsl:value-of select="position()"/>
        <xsl:text>:</xsl:text><xsl:value-of select="container/@EQID|tbdunit/@EQID"/>
        <xsl:text>:</xsl:text><xsl:value-of select="container/@JPOS|tbdunit/@JPOS"/>
        <xsl:text>:</xsl:text><xsl:value-of select="position[@type = 'to']/@PPOS"/>
        <xsl:text>:</xsl:text><xsl:value-of select="position[@type = 'to']/@AREA_TYPE"/>
        <xsl:text>:</xsl:text>
        <xsl:choose>
            <xsl:when test="container[@swappableDelivery = 'Y']">e</xsl:when>
            <xsl:when test="container">c</xsl:when>
            <xsl:when test="tbdunit">t</xsl:when>
        </xsl:choose>
        <xsl:text>:</xsl:text><xsl:value-of select="position[@type = 'to']/transferZone[1]/@BLOCK"/>
        <xsl:text>:</xsl:text><xsl:value-of select="position[@type = 'to']/transferZone[2]/@BLOCK"/>
        <xsl:if test="position() != last()">,</xsl:if>
    </xsl:template>

    <xsl:template name="rail-track-dsch-pos">
        <xsl:choose>
            <xsl:when
                    test="(/message/che/work/job[1][@MVKD='RDSC']) and (/message/che/work/job[1]/position[@type='from'][@AREA_TYPE='Rail']) and (/message/che/work/job[1]/position[@type = 'from'][@TPOS])">
                <xsl:text> </xsl:text>
                <xsl:value-of select="text:format('message.Slot')"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="position[@type = 'from']/@TPOS"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text> </xsl:text>
                <xsl:value-of select="position[@type = 'from']/@PPOS"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="@MVKD" mode="position-to">
        <xsl:choose>
            <xsl:when test="/message/che/work/job[1]/position[@type = 'to'][@TPOS]">
                <xsl:value-of select="text:format('message.Slot')"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="ancestor::job/position[@type = 'to']/@TPOS"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text> </xsl:text>
                <xsl:value-of select="ancestor::job/position[@type = 'to']/@PPOS"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>

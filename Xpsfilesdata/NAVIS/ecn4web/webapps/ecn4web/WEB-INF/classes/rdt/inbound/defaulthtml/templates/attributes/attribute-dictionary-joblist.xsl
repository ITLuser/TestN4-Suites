<?xml version='1.0' encoding='utf-8'?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:text="http://www.navis.com/ecn4web/functions"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
                version="2.0" exclude-result-prefixes="xs text">
    <xsl:import href="/templates/functions.xsl"/>
    <xsl:output method="xhtml" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
                doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" indent="yes" omit-xml-declaration="yes"
                encoding="UTF-8"/>

    <!-- Container rendering -->
    <xsl:template match='job[child::container]'>
        <xsl:variable name="index" select="@index"/>
        <xsl:variable name="twinPut" select="@twinPut"/>

        <xsl:variable name="twinUpId" select="preceding-sibling::job[position() = 1]/container/@EQID"/>
        <xsl:variable name="twinDownId" select="following-sibling::job[position() = 1]/container/@EQID"/>

        <!--set a background color to indicated twinned containers-->
        <xsl:variable name="style" select="if ($twinUpId = $twinPut) then 'button twin' else 'button'"/>
        <xsl:variable name="trStyle" select="if ($twinDownId = $twinPut) then concat($style, ' twin') else $style"/>

        <!--Remove table row border to indicate twinned containers-->
        <xsl:variable name="twinBorder">
            <xsl:if test="$twinUpId = $twinPut">
                <xsl:value-of select="'no-border'"/>
            </xsl:if>
        </xsl:variable>

        <xsl:variable name="carryPosition">
            <xsl:choose>
                <xsl:when test="container/@JPOS = 'FWD'">
                    <xsl:value-of select="text:format('message.Twin_Forward_abbreviation')"/>
                </xsl:when>
                <xsl:when test="container/@JPOS = 'AFT'">
                    <xsl:value-of select="text:format('message.Twin_After_abbreviation')"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="containerPositionFromCarriage">
            <xsl:choose>
                <xsl:when test="position[@type= 'from']/@TKPS != '' and position[@type= 'from']/@TRKL != ''">
                    <xsl:value-of select="concat('&#x2329;', position[@type= 'from']/(@TKPS),'&#x232A;' )"/>
                </xsl:when>
                <xsl:when test="position[@type= 'from']/@TKPS != '' and position[@type= 'from']/@AREA_TYPE[. = 'ITV']">
                    <xsl:value-of select="concat('&#x2329;', position[@type= 'from']/(@TKPS),'&#x232A;' )"/>
                </xsl:when>
                <xsl:when test="position[@type= 'from']/@TKPS != '' and position[@type= 'from']/@transport[. = '']">
                    <xsl:value-of select="concat('&#x2329;', position[@type= 'from']/(@TKPS),'&#x232A;' )"/>
                </xsl:when>
                <xsl:when test="position[@type= 'from']/@TKPS != '' and position[@type= 'to']/@AREA_TYPE[. = 'Rail']
                        and position[@type= 'from']/@AREA_TYPE[. = 'YardRailTZ']">
                    <xsl:value-of select="concat('&#x2329;', position[@type= 'from']/(@TKPS),'&#x232A;' )"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="containerPositionToCarriageInJobList">
            <xsl:choose>
                <xsl:when test="position[@type= 'to']/@TKPS != '' and position[@type= 'from']/@AREA_TYPE[. = 'Rail']
                        and position[@type= 'to']/@AREA_TYPE[. = 'YardRailTZ']">
                    <xsl:value-of select="concat('&#x2329;', position[@type= 'to']/(@TKPS),'&#x232A;' )"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="liftPosition">
            <xsl:choose>
                <xsl:when test="container/@PUTJPOS = 'FWD'">
                    <xsl:value-of select="text:format('message.Twin_Forward_abbreviation')"/>
                </xsl:when>
                <xsl:when test="container/@PUTJPOS = 'AFT'">
                    <xsl:value-of select="text:format('message.Twin_After_abbreviation')"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="EQID" select="container/@EQID"/>
        <tr class="{$trStyle}" id="{$EQID}">
            <xsl:call-template name="select-style"/>
            <td class="line-index {$twinBorder}">
                <xsl:if test="@promoted = 'Y'">
                    <abbr title="Promoted">*</abbr>
                </xsl:if>
                <xsl:if test="count(position[contains(@warning, 'MEN_WORKING')]) ge 1">
                    <abbr title="Men Working">!</abbr>
                </xsl:if>
                <a href="#" class="button">
                    <xsl:call-template name="select-style"/>
                    <xsl:value-of select="@index"/>
                </a>
            </td>
            <xsl:if test="$carryPosition or $liftPosition">
                <td class="{$twinBorder}">
                    <xsl:choose>
                    <xsl:when test="$carryPosition">
                        <xsl:value-of select="$carryPosition"/>
                    </xsl:when>
                        <xsl:when test="$liftPosition">
                            <xsl:value-of select="$liftPosition"/>
                        </xsl:when>
                    </xsl:choose>
                </td>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="@swappableDelivery = 'Y'">
                    <td class="{$twinBorder}">
                        <xsl:apply-templates select="container/@EQTP"/>
                    </td>
                    <td class="{$twinBorder}">
                        <xsl:apply-templates select="container/@LOPR"/>
                    </td>
                </xsl:when>
                <xsl:otherwise>
                    <td class="{$twinBorder}">
                        <xsl:apply-templates select="container/@EQID"/>
                    </td>
                    <td class="{$twinBorder}">
                        <xsl:apply-templates select="container/@TRKC"/>
                    </td>
                </xsl:otherwise>
            </xsl:choose>
            <td class="attr-left {$twinBorder}">
                <xsl:apply-templates
                        select="position[@type= 'from']/(@TRKL[. != ''], @TRNS[. != ''], @transport[. != ''], @PPOS)[1]"/>
                <xsl:value-of select="$containerPositionFromCarriage"/>
            </td>
            <td class="attr-op {$twinBorder}">&#xbb;</td>
            <td class="attr-right {$twinBorder}">
                <xsl:apply-templates
                        select="position[@type= 'to']/(@TRKL[. != ''], @TRNS[. != ''], @transport[. != ''], @PPOS)[1]"/>
                <xsl:value-of select="$containerPositionToCarriageInJobList"/>
            </td>
            <td class="{$twinBorder}">
                <xsl:apply-templates select="container/@LNTH"/>
            </td>
            <xsl:choose>
                <xsl:when test="position() = 1">
                    <!-- This value will be used for pagination -->
                    <input type="hidden" name="startEqId" value="{$EQID}"/>
                </xsl:when>
                <xsl:when test="position() = last()">
                    <!-- This value will be used for pagination -->
                    <input type="hidden" name="pivotEqId" value="{$EQID}"/>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
            <xsl:if test="container/@MNRS != ''">
                <td class="{$twinBorder}">
                    <xsl:apply-templates select="container/@MNRS"/>
                </td>
            </xsl:if>
            <xsl:if test="position/@FLIP != ''">
                <td class="{$twinBorder}">
                    <xsl:apply-templates select="position/@FLIP"/>
                </td>
            </xsl:if>
            <xsl:if test="container/@onPower = 'Y'">
                <td class="{$twinBorder}">
                    <xsl:choose>
                        <xsl:when test="contains($User-Agent, 'Windows CE')">
                            <xsl:value-of select="text:format('label.Connected')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <img src="{$contextPath}/image/plug.png" alt="C" class="" width="22px" height="18px"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
            </xsl:if>
        </tr>
    </xsl:template>

    <xsl:template match="@LNTH">
        <xsl:value-of select="."/>
        <xsl:value-of select="text:format('unit.Feet_abbreviation')" disable-output-escaping="yes"/>
    </xsl:template>
    <xsl:template match="position/@TRKL">
        <xsl:text>+</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>+</xsl:text>
    </xsl:template>
    <xsl:template match="position/@TRNS">
        <xsl:text>+</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>+</xsl:text>
    </xsl:template>
    <xsl:template match="position/@transport">
        <xsl:text>*</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>*</xsl:text>
    </xsl:template>
    <xsl:template match="position/@PPOS">
        <xsl:value-of select="."/>
    </xsl:template>
    <xsl:template match="position/@FLIP">
        <xsl:value-of select="text:format('message.Flip_abbr')"/>
    </xsl:template>

    <xsl:template name="select-style">
        <xsl:if test="@promoted = 'Y'">
            <xsl:attribute name="class">button promotedJob</xsl:attribute>
        </xsl:if>
        <xsl:if test="count(position[contains(@warning, 'MEN_WORKING')]) ge 1">
            <xsl:attribute name="class">button workZone</xsl:attribute>
        </xsl:if>
    </xsl:template>

    <!-- TBDUnit rendering -->
    <xsl:template match="job[child::tbdunit]">
        <xsl:variable name="EQID" select="tbdunit/@EQID"/>
        <tr class="button" id="{$EQID}">
            <xsl:call-template name="select-style"/>
            <td class="line-index">
                <xsl:if test="count(position[contains(@warning, 'MEN_WORKING')]) ge 1">
                    <abbr title="Men Working">!</abbr>
                </xsl:if>
                <a href="#">
                    <xsl:call-template name="select-style"/>
                    <xsl:apply-templates select="@index"/>
                </a>
            </td>
            <td>
                <xsl:apply-templates select="tbdunit/@EQTP"/>
                <xsl:text> </xsl:text>
                <xsl:apply-templates select="tbdunit/@LOPR"/>
            </td>
            <td>
                <xsl:apply-templates select="tbdunit/@TRKC"/>
            </td>
            <td class="attr-left">
                <xsl:apply-templates select="position[@type= 'from']/(@TRKL[. != ''], @transport[. != ''], @PPOS)[1]"/>
            </td>
            <td class="attr-op">&#xbb;</td>
            <td class="attr-right">
                <xsl:apply-templates select="position[@type= 'to']/(@TRKL[. != ''], @transport[. != ''], @PPOS)[1]"/>
            </td>
            <td colspan="2">
                <xsl:apply-templates select="tbdunit/@LNTH"/>
            </td>
            <xsl:choose>
                <xsl:when test="position() = 1">
                    <!-- This value will be used for pagination -->
                    <input type="hidden" name="startEqId" value="{$EQID}"/>
                </xsl:when>
                <xsl:when test="position() = last()">
                    <!-- This value will be used for pagination -->
                    <input type="hidden" name="pivotEqId" value="{$EQID}"/>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
            <td>
                <xsl:apply-templates select="position/@FLIP"/>
            </td>
        </tr>
    </xsl:template>

    <!-- This index serializes all container/tbdunit items to string form: 1:TEST0000001:container, ...
This field will be processed by the outbound message to ECN4, mapping index to ID and
getting unit type to determine outgoing message -->
    <xsl:template match="job" mode="index">
        <xsl:variable name="unit-id" select="tbdunit/@EQID | container/@EQID"/>
        <xsl:variable name="unit-type">
            <xsl:choose>
                <xsl:when test="name(container) and not(@swappableDelivery = 'Y')">c</xsl:when>
                <!-- empty delivery job -->
                <xsl:when test="name(container) and @swappableDelivery = 'Y'">e</xsl:when>
                <xsl:otherwise>t</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="concat(@index,':',$unit-id,':',$unit-type)"/>
        <xsl:if test="position() != last()">,</xsl:if>
    </xsl:template>

    <xsl:template match="@filterUserParameter">
        <xsl:value-of select="concat('(', ., ')')"/>
    </xsl:template>
    <xsl:template match="@sortUserParameter">
        <xsl:value-of select="concat('(', ., ')')"/>
    </xsl:template>

</xsl:stylesheet>

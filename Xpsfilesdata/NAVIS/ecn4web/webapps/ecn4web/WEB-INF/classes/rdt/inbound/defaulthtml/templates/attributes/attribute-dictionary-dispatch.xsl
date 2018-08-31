<?xml version='1.0' encoding='utf-8'?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:text="http://www.navis.com/ecn4web/functions"
                version="2.0" exclude-result-prefixes="xs text">
    <xsl:import href="/templates/functions.xsl"/>
    <xsl:output method="xhtml" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
                doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" indent="yes" omit-xml-declaration="yes"
                encoding="UTF-8"/>
    <!-- Container rendering -->
    <xsl:template match='job[child::container]'>
        <xsl:variable name="fromPos">
            <xsl:choose>
                <xsl:when test="position[@type= 'from']/@TRKL != ''">
                    <xsl:value-of select="position[@type = 'from']/@TRKL"/>
                </xsl:when>
                <xsl:when test="position[@type= 'from']/@TRNS != ''">
                    <xsl:value-of select="position[@type = 'from']/@TRNS"/>
                </xsl:when>
                <xsl:when test="position[@type = 'from']/@transport != ''">
                    <xsl:value-of select="position[@type = 'from']/@transport"/>
                </xsl:when>
                <xsl:when test="position[@type = 'from']/@AREA_TYPE = 'ITV'">
                    <xsl:value-of select="position[@type = 'from']/@PPOS"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="position[@type = 'from']/@PPOS"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="containerPositionExternalTruck">
            <xsl:choose>
                <xsl:when test="position[@type= 'to']/@TKPS != '' and position[@type= 'to']/@TRKL != ''">
                    <xsl:value-of select="concat(position[@type = 'to']/@TRKL,'&#x2329;', position[@type= 'to']/(@TKPS),'&#x232A;' )"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="position[@type= 'to']/@TRKL"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="containerPositionInternalTruck">
            <xsl:choose>
                <xsl:when test="position[@type= 'to']/@TKPS != '' and position[@type= 'to']/@transport != ''">
                    <xsl:value-of select="concat(position[@type = 'to']/@transport,'&#x2329;', position[@type= 'to']/(@TKPS),'&#x232A;' )"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="position[@type= 'to']/@transport"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="toPos">
            <xsl:choose>
                <xsl:when test="position[@type= 'to']/@TRKL != ''">
                    <xsl:value-of select="$containerPositionExternalTruck"/>
                </xsl:when>
                <xsl:when test="position[@type= 'to']/@TRNS != ''">
                    <xsl:value-of select="position[@type = 'to']/@TRNS"/>
                </xsl:when>
                <xsl:when test="position[@type = 'to']/@transport != ''">
                    <xsl:value-of select="$containerPositionInternalTruck"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="position[@type= 'to']/@PPOS"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="containerPositionToChassis">
            <xsl:if test="(position[@type= 'to']/(@TKPS)[1] != '' and position[@type= 'to']/@AREA_TYPE='YardRailTZ') and /message/che/work/job[1][@MVKD ='RDSC'] and position[@type= 'from']/@AREA_TYPE='Rail'">
                <xsl:value-of select="concat('&#x2329;', position[@type= 'to']/(@TKPS)[1],'&#x232A;' )"/>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="containerPositionFromTruck">
            <xsl:if test="count(position[@type = 'from']/@TKPS) eq 1 and (position[@type= 'from']/(@TKPS)[1] != '' and position[@type= 'from']/@AREA_TYPE='ITV') and /message/che/work/job[1][@MVKD !='DSCH'] ">
                <xsl:value-of select="concat('&#x2329;', position[@type= 'from']/(@TKPS)[1],'&#x232A;' )"/>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="containerPositionFromTruck">
            <xsl:choose>
                <xsl:when
                        test="count(position[@type = 'from']/@TKPS) eq 1 and (position[@type= 'from']/(@TKPS)[1] != '' and position[@type= 'from']/@AREA_TYPE='ITV') and /message/che/work/job[1][@MVKD !='DSCH'] ">
                    <xsl:value-of select="concat('&#x2329;', position[@type= 'from']/(@TKPS)[1],'&#x232A;' )"/>
                </xsl:when>
                <xsl:when test="position[@type= 'from']/@TKPS != '' and position[@type= 'to']/@AREA_TYPE[. = 'Rail'] and /message/che/work/job[1][@MVKD ='RLOD']
                        and position[@type= 'from']/@AREA_TYPE[. = 'YardRailTZ']">
                    <xsl:value-of select="concat('&#x2329;', position[@type= 'from']/(@TKPS),'&#x232A;' )"/>
                </xsl:when>
                <xsl:otherwise>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="positions" select="concat($fromPos, $containerPositionFromTruck, ' &#xbb; ', $toPos,$containerPositionToChassis)"/>
        <xsl:variable name="EQID" select="container/@EQID"/>
        <xsl:variable name="twinFlg">
            <xsl:if test="container/@JPOS = 'AFT' or container/@JPOS = 'FWD'">
                <xsl:value-of select='substring(container/@JPOS, 1, 1)'/>
            </xsl:if>
        </xsl:variable>
        <tr>
            <td class="label">
                <xsl:value-of select="text:format('label.ID')"/>
            </td>
            <td class="value" colspan="3">
                <xsl:value-of select='$EQID'/>
            </td>
        </tr>
        <tr>
            <td class="label">
                <xsl:value-of select="text:format('label.Pos')"/>
            </td>
            <td class="value">
                <xsl:value-of select="$positions"/>
            </td>
            <td class="label">
                <xsl:value-of select="text:format('label.Twin')"/>
            </td>
            <td class="value">
                <xsl:value-of select="$twinFlg"/>
            </td>
        </tr>
        <tr>
            <td class="label">
                <xsl:value-of select="text:format('label.Type')"/>
            </td>
            <td class="value">
                <xsl:value-of select='container/@EQTP'/>
            </td>
            <td class="label">
                <xsl:value-of select="text:format('label.Weight')"/>
            </td>
            <td class="value">
                <xsl:value-of select='container/@QWGT'/>
            </td>
        </tr>
        <xsl:choose>
            <xsl:when test="position() = 1">
                <input type="hidden" name="eqId" value="{container/@EQID}"/>
                <input type="hidden" name="pposTo" value="{$toPos}"/>
                <input type="hidden" name="transport" value="{position[@type = 'to']/@transport}"/>
                <input type="hidden" name="chassis" value="{position[@type = 'to']/@CHASSIS}"/>
                <input type="hidden" name="tkps" value="{position[@type = 'to']/@TKPS}"/>
            </xsl:when>
            <xsl:when test="position() = last()">
                <input type="hidden" name="eqId2" value="{container/@EQID}"/>
                <input type="hidden" name="pposTo2" value="{$toPos}"/>
                <input type="hidden" name="transport2" value="{position[@type = 'to']/@transport}"/>
                <input type="hidden" name="tkps2" value="{position[@type = 'to']/@TKPS}"/>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    <!-- TBDUnit rendering -->
    <xsl:template match="job[child::tbdunit]">
        <xsl:variable name="fromPos">
            <xsl:choose>
                <xsl:when test="position[@type= 'from']/@TRKL != ''">
                    <xsl:text>+</xsl:text>
                    <xsl:value-of select="position[@type = 'from']/@TRKL"/>
                    <xsl:text>+</xsl:text>
                </xsl:when>
                <xsl:when test="position[@type = 'from']/@transport != ''">
                    <xsl:text>*</xsl:text>
                    <xsl:value-of select="position[@type = 'from']/@transport"/>
                    <xsl:text>*</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="position[@type = 'from']/@PPOS"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="toPos">
            <xsl:choose>
                <xsl:when test="position[@type= 'to']/@TRKL != ''">
                    <xsl:text>+</xsl:text>
                    <xsl:value-of select="position[@type= 'to']/@TRKL"/>
                    <xsl:text>+</xsl:text>
                </xsl:when>
                <xsl:when test="position[@type = 'to']/@transport != ''">
                    <xsl:text>*</xsl:text>
                    <xsl:value-of select="position[@type = 'to']/@transport"/>
                    <xsl:text>*</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="position[@type= 'to']/@PPOS"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="positions" select="concat($fromPos, ' &#xbb; ', $toPos)"/>
        <xsl:variable name="EQID" select="tbdunit/@EQID"/>
        <tr>
            <td class="label">
                <xsl:value-of select="text:format('label.Line_Op')"/>
            </td>
            <td class="value">
                <xsl:value-of select='tbdunit/@LOPR'/>
            </td>
            <td class="label">
                <xsl:value-of select="text:format('label.Type')"/>
            </td>
            <td class="value">
                <xsl:apply-templates select="tbdunit" mode="hght-attr"/>
            </td>
        </tr>
        <tr>
            <td class="label">
                <xsl:value-of select="text:format('label.Pos')"/>
            </td>
            <td colspan="3" class="value">
                <xsl:value-of select="$positions"/>
            </td>
        </tr>
        <tr>
            <td class="label">
                <xsl:value-of select="text:format('label.Trk_Cmp')"/>
            </td>
            <td colspan="3" class="value">
                <xsl:value-of select='tbdunit/@TRKC'/>
            </td>
        </tr>
        <tr>
            <td class="label">
                <xsl:value-of select="text:format('label.Condition')"/>
            </td>
            <td class="value">
                <xsl:value-of select='tbdunit/@CCON'/>
            </td>
            <td class="label">
                <xsl:value-of select="text:format('label.Grade')"/>
            </td>
            <td class="value">
                <xsl:value-of select='tbdunit/@GRAD'/>
            </td>
        </tr>
        <tr>
            <td class="label">
                <xsl:value-of select="text:format('label.Max_Wt')"/>
            </td>
            <td colspan="3" class="value">
                <xsl:value-of select='tbdunit/@MGWT'/>
            </td>
        </tr>
        <tr>
            <td class="label">
                <xsl:value-of select="text:format('label.Remarks')"/>
            </td>
            <td colspan="3" class="value">
                <xsl:value-of select='tbdunit/@RMRK'/>
            </td>
        </tr>
        <xsl:choose>
            <xsl:when test="position() = 1">
                <input type="hidden" name="eqId" value="{tbdunit/@EQID}"/>
                <input type="hidden" name="unitType" value="container"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="job[child::container]" mode="twin">
        <fieldset class="command-legend">
            <legend>
                <span class="fixed">
                    <xsl:call-template name="legend-controls">
                        <xsl:with-param name="index" select="position()"/>
                        <!--TODO Hard coded mode, should be passed around-->
                        <xsl:with-param name="mode" select="'TWIN'"/>
                    </xsl:call-template>
                </span>
            </legend>
            <table class="unit-data">
                <caption>
                    <xsl:value-of select="text:format('label.Position_Unit_Details', container/@JPOS)"/>
                </caption>
                <tbody>
                    <xsl:variable name="fromPos">
                        <xsl:choose>
                            <xsl:when test="position[@type= 'from']/@TRKL != ''">
                                <xsl:value-of select="position[@type = 'from']/@TRKL"/>
                            </xsl:when>
                            <xsl:when test="position[@type= 'from']/@TRNS != ''">
                                <xsl:value-of select="position[@type = 'from']/@TRNS"/>
                            </xsl:when>
                            <xsl:when test="position[@type = 'from']/@transport != ''">
                                <xsl:value-of select="position[@type = 'from']/@transport"/>
                            </xsl:when>
                            <xsl:when test="position[@type = 'from']/@AREA_TYPE = 'ITV'">
                                <xsl:value-of select="position[@type = 'from']/@PPOS"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="position[@type = 'from']/@PPOS"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="toPos">
                        <xsl:choose>
                            <xsl:when test="position[@type= 'to']/@TRKL != ''">
                                <xsl:value-of select="position[@type= 'to']/@TRKL"/>
                            </xsl:when>
                            <xsl:when test="position[@type= 'to']/@TRNS != ''">
                                <xsl:value-of select="position[@type = 'to']/@TRNS"/>
                            </xsl:when>
                            <xsl:when test="position[@type = 'to']/@transport != ''">
                                <xsl:value-of select="position[@type = 'to']/@transport"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="position[@type= 'to']/@PPOS"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="positions" select="concat($fromPos, ' &#xbb; ', $toPos)"/>
                    <xsl:variable name="EQID" select="container/@EQID"/>
                    <xsl:variable name="twinFlg">
                        <xsl:choose>
                            <xsl:when test="position[@type = 'from']/@transport != ''">
                                <xsl:value-of select="position[@type= 'from']/@TKPS"/>
                            </xsl:when>
                            <xsl:when test="position[@type = 'to']/@transport != ''">
                                <xsl:value-of select="position[@type= 'to']/@TKPS"/>
                            </xsl:when>
                            <xsl:when test="container/@JPOS = 'AFT' or container/@JPOS = 'FWD'">
                                <xsl:value-of select='substring(container/@JPOS, 1, 1)'/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    <tr>
                        <td class="label">
                            <xsl:value-of select="text:format('label.ID')"/>
                        </td>
                        <td class="value" colspan="3">
                            <xsl:value-of select='$EQID'/>
                        </td>
                    </tr>
                    <tr>
                        <td class="label">
                            <xsl:value-of select="text:format('label.Pos')"/>
                        </td>
                        <td class="value">
                            <xsl:value-of select="$positions"/>
                        </td>
                        <td class="label">
                            <xsl:choose>
                                <xsl:when test="position[@type = 'from']/@transport != '' or position[@type = 'to']/@transport != '' ">
                                    <xsl:value-of select="text:format('label.Tkps')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="text:format('label.Twin')"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                        <td class="value">
                            <xsl:value-of select="$twinFlg"/>
                        </td>
                    </tr>
                    <tr>
                        <td class="label">
                            <xsl:value-of select="text:format('label.Type')"/>
                        </td>
                        <td class="value">
                            <xsl:value-of select='container/@EQTP'/>
                        </td>
                        <td class="label">
                            <xsl:value-of select="text:format('label.Weight')"/>
                        </td>
                        <td class="value">
                            <xsl:value-of select='container/@QWGT'/>
                        </td>
                    </tr>
                    <xsl:choose>
                        <xsl:when test="position() = 1">
                            <input type="hidden" name="eqId" value="{container/@EQID}"/>
                            <input type="hidden" name="pposTo" value="{$toPos}"/>
                            <input type="hidden" name="transport" value="{position[@type = 'to']/@transport}"/>
                            <input type="hidden" name="chassis" value="{position[@type = 'to']/@CHASSIS}"/>
                            <input type="hidden" name="tkps" value="{position[@type = 'to']/@TKPS}"/>
                        </xsl:when>
                        <xsl:when test="position() = last()">
                            <input type="hidden" name="eqId2" value="{container/@EQID}"/>
                            <input type="hidden" name="pposTo2" value="{$toPos}"/>
                            <input type="hidden" name="transport2" value="{position[@type = 'to']/@transport}"/>
                            <input type="hidden" name="tkps2" value="{position[@type = 'to']/@TKPS}"/>
                        </xsl:when>
                        <xsl:otherwise/>
                    </xsl:choose>
                </tbody>
            </table>
        </fieldset>
    </xsl:template>

    <xsl:template match="job[child::tbdunit]" mode="twin">
        <table class="unit-data">
            <caption>
                <xsl:value-of select="text:format('label.Position_Unit_Details', tbdunit/@JPOS)"/>
            </caption>
            <tbody>
                <xsl:variable name="fromPos">
                    <xsl:choose>
                        <xsl:when test="position[@type= 'from']/@TRKL != ''">
                            <xsl:text>+</xsl:text>
                            <xsl:value-of select="position[@type = 'from']/@TRKL"/>
                            <xsl:text>+</xsl:text>
                        </xsl:when>
                        <xsl:when test="position[@type = 'from']/@transport != ''">
                            <xsl:text>*</xsl:text>
                            <xsl:value-of select="position[@type = 'from']/@transport"/>
                            <xsl:text>*</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="position[@type = 'from']/@PPOS"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="toPos">
                    <xsl:choose>
                        <xsl:when test="position[@type= 'to']/@TRKL != ''">
                            <xsl:text>+</xsl:text>
                            <xsl:value-of select="position[@type= 'to']/@TRKL"/>
                            <xsl:text>+</xsl:text>
                        </xsl:when>
                        <xsl:when test="position[@type = 'to']/@transport != ''">
                            <xsl:text>*</xsl:text>
                            <xsl:value-of select="position[@type = 'to']/@transport"/>
                            <xsl:text>*</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="position[@type= 'to']/@PPOS"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="positions" select="concat($fromPos, ' &#xbb; ', $toPos)"/>
                <xsl:variable name="EQID" select="tbdunit/@EQID"/>
                <tr>
                    <td class="label">
                        <xsl:value-of select="text:format('label.Line_Op')"/>
                    </td>
                    <td class="value">
                        <xsl:value-of select='tbdunit/@LOPR'/>
                    </td>
                    <td class="label">
                        <xsl:value-of select="text:format('label.Type')"/>
                    </td>
                    <td class="value">
                        <xsl:apply-templates select="tbdunit" mode="hght-attr"/>
                    </td>
                </tr>
                <tr>
                    <td class="label">
                        <xsl:value-of select="text:format('label.Pos')"/>
                    </td>
                    <td colspan="3" class="value">
                        <xsl:value-of select="$positions"/>
                    </td>
                </tr>
                <tr>
                    <td class="label">
                        <xsl:value-of select="text:format('label.Trk_Cmp')"/>
                    </td>
                    <td colspan="3" class="value">
                        <xsl:value-of select='tbdunit/@TRKC'/>
                    </td>
                </tr>
                <tr>
                    <td class="label">
                        <xsl:value-of select="text:format('label.Condition')"/>
                    </td>
                    <td class="value">
                        <xsl:value-of select='tbdunit/@CCON'/>
                    </td>
                    <td class="label">
                        <xsl:value-of select="text:format('label.Grade')"/>
                    </td>
                    <td class="value">
                        <xsl:value-of select='tbdunit/@GRAD'/>
                    </td>
                </tr>
                <tr>
                    <td class="label">
                        <xsl:value-of select="text:format('label.Max_Wt')"/>
                    </td>
                    <td colspan="3" class="value">
                        <xsl:value-of select='tbdunit/@MGWT'/>
                    </td>
                </tr>
                <tr>
                    <td class="label">
                        <xsl:value-of select="text:format('label.Remarks')"/>
                    </td>
                    <td colspan="3" class="value">
                        <xsl:value-of select='tbdunit/@RMRK'/>
                    </td>
                </tr>
                <xsl:choose>
                    <xsl:when test="position() = 1">
                        <input type="hidden" name="eqId" value="{tbdunit/@EQID}"/>
                        <input type="hidden" name="unitType" value="container"/>
                    </xsl:when>
                    <xsl:when test="position() = last()">
                        <input type="hidden" name="eqId2" value="{tbdunit/@EQID}"/>
                        <input type="hidden" name="unitType" value="container"/>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
            </tbody>
        </table>
    </xsl:template>

</xsl:stylesheet>
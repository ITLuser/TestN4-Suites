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
                <xsl:when test="position[@type= 'from']/@TRNS != ''">
                    <xsl:apply-templates select="position[@type = 'from']/@TRNS"/>
                </xsl:when>
                <xsl:when test="position[@type= 'from']/@TRKL != ''">
                    <xsl:apply-templates select="position[@type = 'from']/@TRKL"/>
                </xsl:when>
                <xsl:when test="position[@type = 'from']/@transport != ''">
                    <xsl:apply-templates select="position[@type = 'from']/@transport"/>
                </xsl:when>
                <xsl:when test="position[@type = 'from']/@AREA_TYPE = 'ITV'">
                    <xsl:apply-templates select="position[@type = 'from']/@PPOS"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="position[@type = 'from']/@PPOS"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="toPos">
            <xsl:choose>
                <xsl:when test="position[@type= 'to']/@TRNS != ''">
                    <xsl:apply-templates select="position[@type = 'to']/@TRNS"/>
                </xsl:when>
                <xsl:when test="position[@type= 'to']/@TRKL != ''">
                    <xsl:apply-templates select="position[@type= 'to']/@TRKL"/>
                </xsl:when>
                <xsl:when test="position[@type = 'to']/@transport != ''">
                    <xsl:apply-templates select="position[@type = 'to']/@transport"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="position[@type= 'to']/@PPOS"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="positions" select="concat($fromPos, ' &#xbb; ', $toPos)"/>
        <xsl:variable name="EQID" select="container/@EQID"/>
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
            <td colspan="3" class="value">
                <xsl:value-of select="$fromPos"/>
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
        <tr>
            <td class="label">
                <xsl:value-of select="text:format('label.Target_ID')"/>
            </td>
            <td colspan="3" class="value">
                <xsl:apply-templates select="@target"/>
            </td>
        </tr>
        <xsl:choose>
            <xsl:when test="position() = 1">
                <input type="hidden" name="eqId" value="{container/@EQID}"/>
                <input type="hidden" name="pposTo" value="{$toPos}"/>
            </xsl:when>
            <xsl:when test="position() = last()">
                <input type="hidden" name="eqId2" value="{container/@EQID}"/>
                <input type="hidden" name="pposTo2" value="{$toPos}"/>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    <!-- TBDUnit rendering -->
    <xsl:template match="job[child::tbdunit]">
        <xsl:variable name="fromPos">
            <xsl:choose>
                <xsl:when test="position[@type= 'from']/@TRKL != ''">
                    <xsl:apply-templates select="position[@type= 'from']/@TRKL"/>
                </xsl:when>
                <xsl:when test="position[@type = 'from']/@transport != ''">
                    <xsl:apply-templates select="position[@type = 'from']/@transport"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="position[@type = 'from']/@PPOS"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="toPos">
            <xsl:choose>
                <xsl:when test="position[@type= 'to']/@TRKL != ''">
                    <xsl:apply-templates select="position[@type= 'to']/@TRKL"/>
                </xsl:when>
                <xsl:when test="position[@type = 'to']/@transport != ''">
                    <xsl:apply-templates select="position[@type = 'to']/@transport"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="position[@type= 'to']/@PPOS"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="EQID" select="tbdunit/@EQID"/>
        <tr>
            <td class="label">
                <xsl:value-of select="text:format('label.Line_Op')"/>
            </td>
            <td class="value">
                <xsl:apply-templates select='tbdunit/@LOPR'/>
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
                <xsl:value-of select="$fromPos"/>
            </td>
        </tr>

        <tr>
            <td class="label">
                <xsl:value-of select="text:format('label.Trk_Cmp')"/>
            </td>
            <td colspan="3" class="value">
                <xsl:apply-templates select='tbdunit/@TRKC'/>
            </td>
        </tr>
        <tr>
            <td class="label">
                <xsl:value-of select="text:format('label.Condition')"/>
            </td>
            <td class="value">
                <xsl:apply-templates select='tbdunit/@CCON'/>
            </td>
            <td class="label">
                <xsl:value-of select="text:format('label.Grade')"/>
            </td>
            <td class="value">
                <xsl:apply-templates select='tbdunit/@GRAD'/>
            </td>
        </tr>
        <tr>
            <td class="label">
                <xsl:value-of select="text:format('label.Max_Wt')"/>
            </td>
            <td colspan="3" class="value">
                <xsl:apply-templates select='tbdunit/@MGWT'/>
            </td>
        </tr>
        <tr>
            <td class="label">
                <xsl:value-of select="text:format('label.Remarks')"/>
            </td>
            <td colspan="3" class="value">
                <xsl:apply-templates select='tbdunit/@RMRK'/>
            </td>
        </tr>
        <xsl:choose>
            <xsl:when test="position() = 1">
                <input type="hidden" name="eqId" value="{tbdunit/@EQID}"/>
                <input type="hidden" name="unitType" value="container"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="position/@transport">
        <xsl:text>*</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>*</xsl:text>
    </xsl:template>
    <xsl:template match="position/@TRKL">
        <xsl:text>+</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>+</xsl:text>
    </xsl:template>

    <xsl:template match="job[child::container]" mode="twin">
        <table class="unit-data">
            <caption>
                <xsl:value-of select="text:format('label.Rehandle_Unit_Details')"/>
            </caption>
            <tbody>
                <xsl:variable name="fromPos">
                    <xsl:choose>
                        <xsl:when test="position[@type= 'from']/@TRNS != ''">
                            <xsl:apply-templates select="position[@type = 'from']/@TRNS"/>
                        </xsl:when>
                        <xsl:when test="position[@type= 'from']/@TRKL != ''">
                            <xsl:apply-templates select="position[@type = 'from']/@TRKL"/>
                        </xsl:when>
                        <xsl:when test="position[@type = 'from']/@transport != ''">
                            <xsl:apply-templates select="position[@type = 'from']/@transport"/>
                        </xsl:when>
                        <xsl:when test="position[@type = 'from']/@AREA_TYPE = 'ITV'">
                            <xsl:apply-templates select="position[@type = 'from']/@PPOS"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="position[@type = 'from']/@PPOS"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="toPos">
                    <xsl:choose>
                        <xsl:when test="position[@type= 'to']/@TRNS != ''">
                            <xsl:apply-templates select="position[@type = 'to']/@TRNS"/>
                        </xsl:when>
                        <xsl:when test="position[@type= 'to']/@TRKL != ''">
                            <xsl:apply-templates select="position[@type= 'to']/@TRKL"/>
                        </xsl:when>
                        <xsl:when test="position[@type = 'to']/@transport != ''">
                            <xsl:apply-templates select="position[@type = 'to']/@transport"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="position[@type= 'to']/@PPOS"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="positions" select="concat($fromPos, ' &#xbb; ', $toPos)"/>
                <xsl:variable name="EQID" select="container/@EQID"/>
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
                    <td colspan="3" class="value">
                        <xsl:value-of select="$fromPos"/>
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
                <tr>
                    <td class="label">
                        <xsl:value-of select="text:format('label.Target_ID')"/>
                    </td>
                    <td colspan="3" class="value">
                        <xsl:apply-templates select="@target"/>
                    </td>
                </tr>
                <xsl:choose>
                    <xsl:when test="position() = 1">
                        <input type="hidden" name="eqId" value="{container/@EQID}"/>
                        <input type="hidden" name="pposTo" value="{$toPos}"/>
                    </xsl:when>
                    <xsl:when test="position() = last()">
                        <input type="hidden" name="eqId2" value="{container/@EQID}"/>
                        <input type="hidden" name="pposTo2" value="{$toPos}"/>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
            </tbody>
        </table>
    </xsl:template>

    <xsl:template match="job[child::tbdunit]" mode="twin">
        <table class="unit-data">
            <caption>
                <xsl:value-of select="text:format('label.Rehandle_Unit_Details')"/>
            </caption>
            <tbody>
                <xsl:variable name="fromPos">
                    <xsl:choose>
                        <xsl:when test="position[@type= 'from']/@TRKL != ''">
                            <xsl:apply-templates select="position[@type= 'from']/@TRKL"/>
                        </xsl:when>
                        <xsl:when test="position[@type = 'from']/@transport != ''">
                            <xsl:apply-templates select="position[@type = 'from']/@transport"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="position[@type = 'from']/@PPOS"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="toPos">
                    <xsl:choose>
                        <xsl:when test="position[@type= 'to']/@TRKL != ''">
                            <xsl:apply-templates select="position[@type= 'to']/@TRKL"/>
                        </xsl:when>
                        <xsl:when test="position[@type = 'to']/@transport != ''">
                            <xsl:apply-templates select="position[@type = 'to']/@transport"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="position[@type= 'to']/@PPOS"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="EQID" select="tbdunit/@EQID"/>
                <tr>
                    <td class="label">
                        <xsl:value-of select="text:format('label.Line_Op')"/>
                    </td>
                    <td class="value">
                        <xsl:apply-templates select='tbdunit/@LOPR'/>
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
                        <xsl:value-of select="$fromPos"/>
                    </td>
                </tr>

                <tr>
                    <td class="label">
                        <xsl:value-of select="text:format('label.Trk_Cmp')"/>
                    </td>
                    <td colspan="3" class="value">
                        <xsl:apply-templates select='tbdunit/@TRKC'/>
                    </td>
                </tr>
                <tr>
                    <td class="label">
                        <xsl:value-of select="text:format('label.Condition')"/>
                    </td>
                    <td class="value">
                        <xsl:apply-templates select='tbdunit/@CCON'/>
                    </td>
                    <td class="label">
                        <xsl:value-of select="text:format('label.Grade')"/>
                    </td>
                    <td class="value">
                        <xsl:apply-templates select='tbdunit/@GRAD'/>
                    </td>
                </tr>
                <tr>
                    <td class="label">
                        <xsl:value-of select="text:format('label.Max_Wt')"/>
                    </td>
                    <td colspan="3" class="value">
                        <xsl:apply-templates select='tbdunit/@MGWT'/>
                    </td>
                </tr>
                <tr>
                    <td class="label">
                        <xsl:value-of select="text:format('label.Remarks')"/>
                    </td>
                    <td colspan="3" class="value">
                        <xsl:apply-templates select='tbdunit/@RMRK'/>
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
                </xsl:choose>
            </tbody>
        </table>
    </xsl:template>

</xsl:stylesheet>
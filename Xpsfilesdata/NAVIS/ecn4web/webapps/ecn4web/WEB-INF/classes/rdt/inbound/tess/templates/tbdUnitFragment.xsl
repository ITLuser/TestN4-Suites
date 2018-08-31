<?xml version='1.0' encoding="utf-8"?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
                xmlns:text="http://www.navis.com/ecn4web/functions"
                exclude-result-prefixes="text"
                version='2.0'>
    <xsl:import href="functions.xsl"/>
    <xsl:template match="tbdunit">
        <xsl:variable name="fromPos"
                      select="if(../position[@type= 'from']/@TRKL != '') then ../position[@type = 'from']/@TRKL else ../position[@type = 'from']/@PPOS"/>
        <xsl:variable name="toPos"
                      select="if (../position[@type= 'to']/@TRKL != '') then ../position[@type= 'to']/@TRKL else ../position[@type= 'to']/@PPOS"/>
        <xsl:variable name="positions" select="concat($fromPos, ' &#xbb; ', $toPos)"/>

        <tr>
            <td class="label">
                <xsl:value-of select="text:format('label.Line_Op')"/>
            </td>
            <td class="value">
                <xsl:value-of select='@LOPR'/>
            </td>
            <td class="label">
                <xsl:value-of select="text:format('label.Type')"/>
            </td>
            <td class="value">
                <xsl:apply-templates select="." mode="hght-attr"/>
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
                <xsl:value-of select='@TRKC'/>
            </td>
        </tr>
        <tr>
            <td class="label">
                <xsl:value-of select="text:format('label.Condition')"/>
            </td>
            <td class="value">
                <xsl:value-of select='@CCON'/>
            </td>
            <td class="label">
                <xsl:value-of select="text:format('label.Grade')"/>
            </td>
            <td class="value">
                <xsl:value-of select='@GRAD'/>
            </td>
        </tr>
        <tr>
            <td class="label">
                <xsl:value-of select="text:format('label.Max_Wt')"/>
            </td>
            <td colspan="3" class="value">
                <xsl:value-of select='@MGWT'/>
            </td>
        </tr>
        <tr>
            <td class="label">
                <xsl:value-of select="text:format('label.Prefix')"/>
            </td>
            <td colspan="3" class="value">
                <xsl:variable name="range-items" select="tokenize(@TBDR, ', ')"/>
                <xsl:for-each select="tokenize(@TBDR, ', ')">
                    <div class="line-item">
                        <xsl:value-of select="."/>
                    </div>
                </xsl:for-each>
            </td>
        </tr>
        <tr>
            <td class="label">
                <xsl:value-of select="text:format('label.Remarks')"/>
            </td>
            <td colspan="3" class="value">
                <xsl:value-of select='@RMRK'/>
            </td>
        </tr>
    </xsl:template>

</xsl:stylesheet>


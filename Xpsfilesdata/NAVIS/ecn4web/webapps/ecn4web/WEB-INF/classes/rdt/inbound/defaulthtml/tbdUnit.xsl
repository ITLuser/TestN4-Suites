<?xml version='1.0' encoding="utf-8"?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
                xmlns:text="http://www.navis.com/ecn4web/functions"
                exclude-result-prefixes="text"
                version='2.0'>
    <xsl:import href="templates/common.xsl"/>
    <xsl:import href="templates/attributes/attribute-dictionary.xsl"/>
    <xsl:output method="xhtml" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
                doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" indent="yes" omit-xml-declaration="yes"
                encoding="UTF-8"/>

    <xsl:variable name="fromPos"
                  select="if(message/che/work/job/position[@type= 'from']/@TRKL != '') then message/che/work/job/position[@type = 'from']/@TRKL else message/che/work/job/position[@type = 'from']/@PPOS"/>
    <xsl:variable name="toPos"
                  select="if (message/che/work/job/position[@type= 'to']/@TRKL != '') then message/che/work/job/position[@type= 'to']/@TRKL else message/che/work/job/position[@type= 'to']/@PPOS"/>
    <xsl:variable name="positions" select="concat($fromPos, ' &#xbb; ', $toPos)"/>
    <xsl:variable name="mode">
        <xsl:choose>
            <xsl:when test="(message/che/work/job[1]/position[@type = 'to']/@transport != '')">TRUCK</xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:variable>
    <xsl:template match='/'>

        <html>
            <head>
                <xsl:call-template name="header">
                    <xsl:with-param name="pageTitle" select="text:format('title.TBD_Unit')"/>
                    <xsl:with-param name="mode" select="$mode"/>
                </xsl:call-template>
            </head>
            <body>
                <form id="xmlrdtForm" name="xmlrdtForm" action='{$contextPath}/servlet/xmlrdt' method='post'
                      accept-charset="UTF-8">
                    <xsl:call-template name="message-fragment"/>
                    <table class="data">
                        <caption>
                            <xsl:value-of select="text:format('label.Unit_Details')"/>
                        </caption>
                        <tbody>
                            <tr>
                                <td class="label">
                                    <xsl:value-of select="text:format('label.Line_Op')"/>
                                </td>
                                <td class="value">
                                    <xsl:value-of select='message/che/work/job/tbdunit/@LOPR'/>
                                </td>
                                <td class="label">
                                    <xsl:value-of select="text:format('label.Type')"/>
                                </td>
                                <td class="value">
                                    <xsl:apply-templates select="message/che/work/job/tbdunit" mode="hght-attr"/>
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
                            <xsl:if test="$mode = 'TRUCK'">
                                <xsl:if test="message/che/work/job/position[@type = 'to']/@transport != ''">
                                    <tr>
                                        <td class="label">
                                            <xsl:value-of select="text:format('label.Dispatched')"/>
                                        </td>
                                        <td colspan="3" class="value">
                                            <xsl:value-of
                                                    select="message/che/work/job/position[@type = 'to']/@transport"/>
                                        </td>
                                    </tr>
                                </xsl:if>
                                <xsl:if test="message/che/work/job/transport/che">
                                    <tr>
                                        <td class="label">
                                            <xsl:value-of select="text:format('label.Trucks')"/>
                                        </td>
                                        <td colspan="3" class="value">
                                            <xsl:value-of
                                                    select="string-join(message/che/work/job/transport/che/@CHID, ', ')"/>
                                        </td>
                                    </tr>
                                </xsl:if>
                            </xsl:if>
                            <!--
                            <tr>
                                <td class="label">
                                    <xsl:value-of select="text:format('label.Prefix')"/>
                                </td>
                                <td colspan="3" class="value">
                                    <xsl:variable name="range-items"
                                                  select="tokenize(message/che/work/job/tbdunit/@TBDR, ', ')"/>
                                    <xsl:for-each select="tokenize(message/che/work/job/tbdunit/@TBDR, ', ')">
                                        <div class="line-item">
                                            <xsl:value-of select="."/>
                                        </div>
                                    </xsl:for-each>
                                </td>
                            </tr>
                            -->
                        </tbody>
                    </table>
                    <xsl:call-template name="command-menu">
                        <xsl:with-param name="mode" select="$mode"/>
                    </xsl:call-template>
                    <xsl:call-template name="hidden-fields">
                        <xsl:with-param name="mode" select="$mode"/>
                    </xsl:call-template>
                    <input type="hidden" name="eqId" value="{/message/che/work/job/tbdunit/@EQID}"/>
                    <input type="hidden" name="unitType" value="container"/>
                    <input type="hidden" name="transport"
                           value="{/message/che/work/job/position[@type = 'to']/@transport}"/>
                </form>
                <xsl:call-template name="footer"/>
            </body>
        </html>

    </xsl:template>
</xsl:stylesheet>

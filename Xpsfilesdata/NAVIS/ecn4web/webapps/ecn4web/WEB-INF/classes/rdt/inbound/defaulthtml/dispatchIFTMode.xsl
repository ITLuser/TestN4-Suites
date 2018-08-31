<?xml version='1.0' encoding="utf-8"?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform' xmlns="http://www.w3.org/1999/xhtml"
                xmlns:text="http://www.navis.com/ecn4web/functions"
                exclude-result-prefixes="text"
                version='2.0'>
    <xsl:import href="templates/common.xsl"/>
    <xsl:output method="xhtml" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
                doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" indent="yes" omit-xml-declaration="yes"
                encoding="UTF-8"/>

    <xsl:variable name="fromPos"
                  select="if (message/che/work/job/position[@type= 'from']/@TRKL != '') then message/che/work/job/position[@type = 'from']/@TRKL else message/che/work/job/position[@type = 'from']/@PPOS"/>
    <xsl:variable name="toPos"
                  select="if (message/che/work/job/position[@type= 'to']/@TRKL != '') then message/che/work/job/position[@type= 'to']/@TRKL else message/che/work/job/position[@type= 'to']/@PPOS"/>
    <xsl:variable name="positions" select="concat($fromPos, ' &#xbb; ', $toPos)"/>
    <xsl:variable name="mode" select="'IFT'"/>

    <xsl:template match='/'>

        <html>
            <head>
                <xsl:call-template name="header">
                    <xsl:with-param name="pageTitle" select="'Dispatch Job'"/>
                </xsl:call-template>
            </head>
            <body>
                <form id="xmlrdtForm" name="xmlrdtForm" action='{$contextPath}/servlet/xmlrdt' method='post'
                      accept-charset="UTF-8">
                    <xsl:call-template name="message-fragment">
                        <xsl:with-param name="mode" select="$mode"/>
                    </xsl:call-template>
                    <table class="data">
                        <caption>
                            <xsl:value-of select="text:format('label.Unit_Details')"/>
                        </caption>
                        <tbody>
                            <tr>
                                <td class="label">
                                    <xsl:value-of select="text:format('label.ID')"/>
                                </td>
                                <td class="value">
                                    <xsl:value-of select='message/che/work/job/container/@EQID'/>
                                </td>
                                <td class="label">
                                    <xsl:value-of select="text:format('label.Type')"/>
                                </td>
                                <td class="value">
                                    <xsl:value-of select='message/che/work/job/container/@EQTP'/>
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
                                    <xsl:value-of select="text:format('label.Line_Op')"/>
                                </td>
                                <td class="value">
                                    <xsl:value-of select='message/che/work/job/container/@LOPR'/>
                                </td>
                                <td class="label">
                                    <xsl:value-of select="text:format('label.DEPT_CAR')"/>
                                </td>
                                <td class="value">
                                    <xsl:value-of select='message/che/work/job/container/@DCRR'/>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">
                                    <xsl:value-of select="text:format('label.Trk_Cmp')"/>
                                </td>
                                <td colspan="3" class="value">
                                    <xsl:value-of select='message/che/work/job/container/@TRKC'/>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">
                                    <xsl:value-of select="text:format('label.Length')"/>
                                </td>
                                <td class="value">
                                    <xsl:value-of select='message/che/work/job/container/@LNTH'/>
                                </td>
                                <td class="label">
                                    <xsl:value-of select="text:format('label.Weight')"/>
                                </td>
                                <td class="value">
                                    <xsl:value-of select='message/che/work/job/container/@QWGT'/>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">
                                    <xsl:value-of select="text:format('label.Condition')"/>
                                </td>
                                <td class="value">
                                    <xsl:value-of select="message/che/work/job/container/@CCON"/>
                                </td>
                                <td class="label">
                                    <xsl:value-of select="text:format('label.Hold')"/>
                                </td>
                                <td class="value">
                                    <xsl:value-of select="message/che/work/job/container/@RLSE"/>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">
                                    <xsl:value-of select="text:format('label.Hazard')"/>
                                </td>
                                <td class="value">
                                    <xsl:value-of select="message/che/work/job/container/@ISHZ"/>
                                </td>
                                <td class="label">
                                    <xsl:value-of select="text:format('label.Reef_Temp')"/>
                                </td>
                                <td class="value">
                                    <xsl:value-of select="message/che/work/job/container/@RFRT"/>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">
                                    <xsl:value-of select="text:format('label.Dwell_Time')"/>
                                </td>
                                <td class="value">
                                    <xsl:value-of select="message/che/work/job/container/@DWTS"/>
                                </td>
                                <td class="label">
                                    <xsl:value-of select="text:format('label.M&amp;R_Stat')"/>
                                </td>
                                <td class="value">
                                    <xsl:value-of select="message/che/work/job/container/@MNRS"/>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                    <xsl:call-template name="command-menu">
                        <xsl:with-param name="mode" select="$mode"/>
                    </xsl:call-template>
                    <input type="hidden" name="eqId" value="{message/che/work/job/container/@EQID}"/>
                    <input type="hidden" name="pposTo" value="{message/che/work/job/position[@type = 'to']/@PPOS}"/>
                </form>
                <xsl:call-template name="footer"/>
            </body>
        </html>

    </xsl:template>
</xsl:stylesheet>

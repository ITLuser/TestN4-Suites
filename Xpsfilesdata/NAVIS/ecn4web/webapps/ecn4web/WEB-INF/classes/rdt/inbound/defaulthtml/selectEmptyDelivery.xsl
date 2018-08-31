<?xml version='1.0' encoding='utf-8'?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:text="http://www.navis.com/ecn4web/functions"
                exclude-result-prefixes="xs text"
                version="2.0">
    <xsl:import href="templates/common.xsl"/>
    <xsl:output method="xhtml" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
                doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" indent="yes" omit-xml-declaration="yes"
                encoding="UTF-8"/>

    <xsl:template match='/'>
        <html>
            <head>
                <xsl:call-template name="header">
                    <xsl:with-param name="pageTitle" select="text:format('title.Select_Delivery_Container')"/>
                </xsl:call-template>
            </head>
            <body>
                <form id="xmlrdtForm" name="xmlrdtForm" action='{$contextPath}/servlet/xmlrdt' method='post'
                      accept-charset="UTF-8">
                    <xsl:call-template name="message-fragment"/>
                    <table class="data">
                        <caption>
                            <xsl:value-of select="text:format('label.Empty_Delivery_Details')"/>
                        </caption>
                        <tbody>
                            <tr>
                                <td class="label">
                                    <xsl:value-of select="text:format('label.ID')"/>
                                </td>
                                <td class="value">
                                    <xsl:value-of select='//container/@EQID'/>
                                </td>
                                <td class="label">
                                    <xsl:value-of select="text:format('label.Line_Op')"/>
                                </td>
                                <td class="value">
                                    <xsl:value-of select='//container/@LOPR'/>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">
                                    <xsl:value-of select="text:format('label.Type')"/>
                                </td>
                                <td class="value">
                                    <xsl:value-of select='//container/@EQTP'/>
                                </td>
                                <td class="label">
                                    <xsl:value-of select="text:format('label.Condition')"/>
                                </td>
                                <td class="value">
                                    <xsl:value-of select='//container/@CCON'/>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">
                                    <xsl:value-of select="text:format('label.Grade')"/>
                                </td>
                                <td class="value">
                                    <xsl:value-of select='//container/@GRAD'/>
                                </td>
                                <td class="label">
                                    <xsl:value-of select="text:format('label.ISOgroup')"/>
                                </td>
                                <td class="value">
                                    <xsl:value-of select='//container/@ISGP'/>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">
                                    <xsl:value-of select="text:format('label.Weight')"/>
                                </td>
                                <td class="value">
                                    <xsl:value-of select='//container/@QWGT'/>
                                </td>
                                <td class="label">
                                    <xsl:value-of select="text:format('label.Release')"/>
                                </td>
                                <td class="value">
                                    <xsl:value-of select='//container/@RLSE'/>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">
                                    <xsl:value-of select="text:format('label.Trucking_Co.')"/>
                                </td>
                                <td class="value">
                                    <xsl:value-of select='//container/@TRKC'/>
                                </td>
                                <td class="label">
                                    <xsl:value-of select="text:format('label.Reefer_Type')"/>
                                </td>
                                <td class="value">
                                    <xsl:value-of select='//container/@RFRT'/>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">
                                    <xsl:value-of select="text:format('label.Length')"/>
                                </td>
                                <td class="value">
                                    <xsl:value-of select='//container/@LNTH'/>
                                </td>
                                <td class="label">
                                    <xsl:value-of select="text:format('label.MNR_Status')"/>
                                </td>
                                <td class="value">
                                    <xsl:value-of select='//container/@MNRS'/>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">
                                    <xsl:value-of select="text:format('label.Remarks')"/>
                                </td>
                                <td colspan="3" class="value">
                                    <xsl:value-of select='//container/@RMRK'/>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                    <xsl:call-template name="command-menu"/>
                    <xsl:call-template name="hidden-fields"/>
                </form>
                <xsl:call-template name="footer"/>
            </body>

        </html>
    </xsl:template>
</xsl:stylesheet>

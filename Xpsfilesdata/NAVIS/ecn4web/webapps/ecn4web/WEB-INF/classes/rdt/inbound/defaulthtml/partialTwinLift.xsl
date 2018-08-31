<?xml version='1.0' encoding="utf-8"?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform' version='2.0'
                xmlns:text="http://www.navis.com/ecn4web/functions"
                exclude-result-prefixes="text">
    <xsl:import href="templates/common.xsl"/>
    <xsl:import href="templates/attributes/attribute-dictionary.xsl"/>
    <xsl:import href="templates/attributes/straddle/attribute-dictionary-partial-twin-lift.xsl"/>

    <xsl:output method="xhtml" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
                doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" indent="yes" omit-xml-declaration="yes"
                encoding="UTF-8"/>
    <xsl:preserve-space elements="td"/>
    <xsl:variable name="mode">
        <xsl:if test="message/che/work/@count = 2">TWIN</xsl:if>
    </xsl:variable>

    <xsl:template match='/'>

        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <xsl:call-template name="header">
                    <xsl:with-param name="pageTitle"
                                    select="text:format('title.Partial_Twin_Lift', if (contains($formId, 'TRUCK')) then text:format('title.TRK') else text:format('title.STR'))"/>
                    <xsl:with-param name="mode" select="$mode"/>
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
                            <xsl:value-of select="text:format('label.Job.plural')"/>
                        </caption>
                        <tbody>
                            <tr>
                                <td class="label"/>
                                <td colspan="3" class="value">
                                    <xsl:for-each select="/message/che/work/job">
                                        <div class="line-item">
                                            <xsl:apply-templates select="."/>
                                            <xsl:text> </xsl:text>
                                            <xsl:if test="not(@MVKD = 'DSCH' and ancestor::work[@moveStage = 'PLANNED'])">
                                                <xsl:value-of select="container/@EQID"/><xsl:text> </xsl:text>
                                                <xsl:apply-templates select="position[@type = 'from']/@AREA_TYPE"/>
                                                <xsl:text> </xsl:text>
                                                <xsl:value-of select="position[@type = 'from']/@PPOS"/>
                                            </xsl:if>
                                            <xsl:apply-templates select="." mode="line-one-variable"/>
                                            <br/>
                                            <xsl:apply-templates select="@MVKD"/>
                                            <xsl:text> </xsl:text>
                                            <xsl:apply-templates select="container/@QWGT"/>
                                            <xsl:text> </xsl:text>
                                            <xsl:apply-templates select="container/@LNTH"/>
                                            <xsl:apply-templates select="." mode="line-two-variable"/>
                                        </div>
                                    </xsl:for-each>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                    <xsl:call-template name="command-menu">
                        <xsl:with-param name="mode" select="$mode"/>
                    </xsl:call-template>
                    <xsl:call-template name="hidden-fields">
                        <xsl:with-param name="mode" select="$mode"/>
                    </xsl:call-template>
                    <xsl:variable name="index">
                        <xsl:apply-templates select="message/che/work/job" mode="index"/>
                    </xsl:variable>
                    <input type="hidden" name="index" value="{$index}"/>
                    <input type="hidden" name="eqId" value="{message/che/work/job[1]/container/@EQID}"/>
                    <input type="hidden" name="pposTo"
                           value="{message/che/work/job[1]/position[@type = 'from']/@PPOS}"/>
                </form>
                <xsl:call-template name="footer"/>
            </body>

        </html>

    </xsl:template>

</xsl:stylesheet>

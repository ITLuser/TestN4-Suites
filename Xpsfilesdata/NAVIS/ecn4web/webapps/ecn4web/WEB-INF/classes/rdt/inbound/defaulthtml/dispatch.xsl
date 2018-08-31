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
    <xsl:import href="templates/attributes/attribute-dictionary-dispatch.xsl"/>
    <xsl:import href="templates/attributes/attribute-dictionary.xsl"/>
    <xsl:output method="xhtml" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
                doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" indent="yes" omit-xml-declaration="yes"
                encoding="UTF-8"/>

    <xsl:variable name="mode">
        <xsl:choose>
            <xsl:when test="(message/che/work/job/position[@type = 'to']/@transport != '') and (message/che/work/@count = 2)">TWIN_TRUCK</xsl:when>
            <xsl:when test="message/che/work/@count = 2">TWIN</xsl:when>
            <xsl:when test="message/che/work/job[1]/@ift = 'Y'">IFT</xsl:when>
            <xsl:when test="(message/che/work/job[1]/position[@type = 'to']/@transport != '')">TRUCK</xsl:when>
            <xsl:when test="(message/che/work/job/position[@type = 'to']/@AREA_TYPE = 'YardRailTZ') and (message/che/work/job[1]/@MVKD = 'RDSC')
            and (message/che/work/job/position[@type = 'from']/@AREA_TYPE='Rail')">CHASSIS</xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="jobs" select="/message/che/work/*"/>

    <xsl:template match='/'>

        <html>
            <head>
                <xsl:call-template name="header">
                    <xsl:with-param name="pageTitle" select="text:format('title.Dispatch_Job')"/>
                    <xsl:with-param name="mode" select="$mode"/>
                </xsl:call-template>
            </head>
            <body>
                <form id="xmlrdtForm" name="xmlrdtForm" action='{$contextPath}/servlet/xmlrdt' method='post'
                      accept-charset="UTF-8">
                    <xsl:call-template name="message-fragment">
                        <xsl:with-param name="mode" select="$mode"/>
                    </xsl:call-template>
                    <xsl:apply-templates select="/message/che/work"/>
                    <xsl:choose>
                        <xsl:when test="$mode = 'TWIN_TRUCK' or $mode = 'TWIN'">
                              <xsl:apply-templates select="$jobs" mode="twin"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <table class="data">
                                <caption>
                                    <xsl:value-of select="text:format('label.Unit_Details')"/>
                                </caption>
                                <tbody>
                                    <xsl:apply-templates select="$jobs"/>
                                </tbody>
                            </table>
                        </xsl:otherwise>
                    </xsl:choose>

                    <xsl:call-template name="command-menu">
                        <xsl:with-param name="mode" select="$mode"/>
                    </xsl:call-template>
                    <xsl:call-template name="hidden-fields">
                        <xsl:with-param name="mode" select="$mode"/>
                    </xsl:call-template>
                </form>
                <xsl:call-template name="footer"/>
            </body>
        </html>

    </xsl:template>

</xsl:stylesheet>

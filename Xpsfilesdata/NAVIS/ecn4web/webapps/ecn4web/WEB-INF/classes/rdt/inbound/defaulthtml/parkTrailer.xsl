<?xml version='1.0' encoding="utf-8"?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
                xmlns:text="http://www.navis.com/ecn4web/functions"
                exclude-result-prefixes="text"
                xmlns="http://www.w3.org/1999/xhtml" version='2.0'>
    <xsl:import href="templates/attributes/truck/attribute-dictionary.xsl"/>
    <xsl:import href="templates/attributes/attribute-dictionary.xsl"/>

    <xsl:import href="templates/common.xsl"/>

    <xsl:output method="xhtml" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
                doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" indent="yes" omit-xml-declaration="yes"
                encoding="UTF-8"/>
    <xsl:preserve-space elements="td"/>

    <xsl:variable name="mode"/>

    <xsl:template match='/'>
        <html>
            <head>
                <xsl:call-template name="header">
                    <xsl:with-param name="pageTitle"
                                    select="text:format('title.Park_trailer')"/>
                    <xsl:with-param name="mode" select="$mode"/>
                </xsl:call-template>
            </head>
            <body>
                <form id="xmlrdtForm" name="xmlrdtForm" action='{$contextPath}/servlet/xmlrdt' method='post'
                      accept-charset="UTF-8">
                    <xsl:call-template name="message-fragment">
                        <xsl:with-param name="mode" select="$mode"/>
                    </xsl:call-template>
                    <div class="data">
                        <div class="line-item">
                            <xsl:apply-templates select="/message/che"/>
                        </div>
                        <xsl:for-each select="/message/che/work/job">
                            <div class="line-item">
                                <xsl:apply-templates select="." mode="instruction"/>
                                <xsl:text> </xsl:text>
                                <xsl:apply-templates select="position[@type = 'from']/@AREA_TYPE"/>
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="position[@type = 'from']/@AREA"/>
                                <xsl:apply-templates select="." mode="line-one-variable"/>
                            </div>
                        </xsl:for-each>
                    </div>
                    <xsl:call-template name="command-menu">
                        <xsl:with-param name="mode" select="$mode"/>
                    </xsl:call-template>
                    <xsl:call-template name="hidden-fields"/>
                    <xsl:variable name="index">
                        <xsl:apply-templates select="message/che/work/job" mode="indexLaden"/>
                    </xsl:variable>
                    <input type="hidden" name="index" value="{$index}"/>
                </form>
                <xsl:call-template name="footer"/>
            </body>

        </html>

    </xsl:template>

    <xsl:template match="che[@CHASSIS = 'BOMBCART']">
        <xsl:value-of select="text:format('message.Park_Existing')"/>
    </xsl:template>

    <xsl:template match="che[@CHASSIS != 'BOMBCART']">
        <xsl:value-of select="text:format('message.Park_then', string(/message/che/@CHASSIS))"/>
    </xsl:template>

    <xsl:template match="job[@moveStage != 'CARRY_UNDERWAY' and container]" mode="instruction">
        <xsl:apply-templates select="position[@type='from']"/>
    </xsl:template>

    <xsl:template match="position">
        <xsl:value-of select="concat(text:format('message.Pull'), ' ', ../container/@EQID, ' ', text:format('message.from'))"/>
    </xsl:template>

    <xsl:template match="@AREA_TYPE[. = 'YardRow']">
        <xsl:value-of select="text:format('message.Row')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'YardRowWheeled']">
        <xsl:value-of select="text:format('message.Wheeled')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'YardBlock']">
        <xsl:value-of select="text:format('message.Block')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'YardLSTZ']">
        <xsl:value-of select="text:format('message.LSTZ')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'YardWSTZ']">
        <xsl:value-of select="text:format('message.WSTZ')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'YardRailTZ']">
        <xsl:value-of select="text:format('message.RAILTZ')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'YardVesselTZ']">
        <xsl:value-of select="text:format('message.VESSELTZ')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'Vessel']">
        <xsl:value-of select="text:format('message.Crane')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'Rail']">
        <xsl:value-of select="text:format('message.POW')"/>
    </xsl:template>
    <xsl:template match="@AREA_TYPE[. = 'Grid']">
        <xsl:value-of select="text:format('message.Grid')"/>
    </xsl:template>

</xsl:stylesheet>

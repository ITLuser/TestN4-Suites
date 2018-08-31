<?xml version='1.0' encoding="utf-8"?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:text="http://www.navis.com/ecn4web/functions"
                exclude-result-prefixes="text"
                version='2.0'>
    <xsl:import href="templates/common.xsl"/>
    <xsl:import href="templates/attributes/attribute-dictionary.xsl"/>

    <xsl:output method="xhtml" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
                doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" indent="yes" omit-xml-declaration="yes"
                encoding="UTF-8"/>
    <xsl:preserve-space elements="td"/>

    <xsl:variable name="mode">
        <xsl:choose>
            <xsl:when
                    test="contains($formId, 'TRUCK') and count(distinct-values(/message/che/work/job/position[@type = 'from']/@AREA)) &gt; 1">
                <xsl:text>MULTIPLE</xsl:text>
            </xsl:when>
            <xsl:when test="not(contains($formId, 'TRUCK')) and message/che/work/@count = 2">
                <xsl:text>TWIN</xsl:text>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="chassis">
        <xsl:apply-templates select="/message/che/@CHASSIS"/>
    </xsl:variable>

    <xsl:template match='/'>

        <html>
            <head>
                <xsl:call-template name="header">
                    <xsl:with-param name="pageTitle"
                                    select="text:format('title.Empty_to_origin', (/message/che/work/job[1]/position[@type = 'from']/@AREA_TYPE))"/>
                    <xsl:with-param name="mode" select="$mode"/>
                    <xsl:with-param name="chassis" select="$chassis" tunnel="yes"/>
                </xsl:call-template>
            </head>
            <body>
                <form id="xmlrdtForm" name="xmlrdtForm" action='{$contextPath}/servlet/xmlrdt' method='post'
                      accept-charset="UTF-8">
                    <xsl:call-template name="message-fragment">
                        <xsl:with-param name="mode" select="$mode"/>
                    </xsl:call-template>
                    <xsl:apply-templates select="/message/che/work" mode="position-type">
                        <xsl:with-param name="position-type" select="'from'"/>
                    </xsl:apply-templates>
                    <div class="data">
                        <xsl:for-each select="/message/che/work/job">
                            <div class="line-item">
                                <xsl:apply-templates select="." mode="instruction"/>
                                <xsl:text> </xsl:text>
                                <xsl:apply-templates select="position[@type = 'from']/@AREA_TYPE"/>
                                <xsl:text> </xsl:text>
                                <xsl:apply-templates select="position[@type = 'from']/@AREA"/>
                                <xsl:apply-templates select="." mode="line-one-variable"/>
                                <xsl:apply-templates select="@MVKD[. = 'LOAD' or . = 'DSCH']" mode="driveDirection"/>
                                <br/>
                                <xsl:apply-templates select="@MVKD"/>
                                <xsl:text> </xsl:text>
                                <xsl:apply-templates select="tbdunit" mode="first"/>
                                <xsl:apply-templates select="container/@QWGT"/>
                                <xsl:text> </xsl:text>
                                <xsl:apply-templates select="container/@LNTH"/>
                                <xsl:text> </xsl:text>
                                <xsl:apply-templates select="." mode="line-two-variable"/>
                                <xsl:apply-templates select="container"/>
                            </div>
                        </xsl:for-each>
                        <xsl:variable name="line-three-variable">
                            <xsl:apply-templates select="/message/che/@CHASSIS" mode="line-three-variable-two"/>
                        </xsl:variable>
                        <xsl:if test="normalize-space($line-three-variable)">
                            <div class="line-item">
                                <xsl:value-of select="$line-three-variable" disable-output-escaping="yes"/>
                            </div>
                        </xsl:if>
                    </div>
                    <xsl:call-template name="command-menu">
                        <xsl:with-param name="mode" select="$mode"/>
                    </xsl:call-template>
                    <xsl:call-template name="hidden-fields">
                        <xsl:with-param name="mode" select="$mode"/>
                    </xsl:call-template>
                    <xsl:variable name="index">
                        <xsl:apply-templates select="message/che/work/job" mode="indexEmpty"/>
                    </xsl:variable>
                    <input type="hidden" name="index" value="{$index}"/>
                    <input type="hidden" name="eqId" value="{message/che/work/job[1]/*/@EQID}"/>
                    <input type="hidden" name="eqId2" value="{message/che/work/job[2]/*/@EQID}"/>
                    <input type="hidden" name="pposFrom"
                           value="{message/che/work/job[1]/position[@type = 'from']/@AREA}"/>
                </form>
                <xsl:call-template name="footer"/>
            </body>

        </html>

    </xsl:template>

</xsl:stylesheet>

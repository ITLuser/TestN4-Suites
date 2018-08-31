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
                    test="contains($formId, 'TRUCK') and count(distinct-values(/message/che/work/job/position[@type = 'to']/@AREA)) &gt; 1">
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
                                    select="text:format('title.Empty_at_origin', string(/message/che/work/job[1]/position[@type = 'from']/@AREA_TYPE))"/>
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
                        <xsl:with-param name="che-in-transferZone" select="true()"/>
                    </xsl:apply-templates>
                    <div class="data">
                        <xsl:for-each select="/message/che/work/job">
                            <div class="line-item">
                                <xsl:apply-templates select="." mode="instruction"/>
                                <xsl:text> </xsl:text>
                                <xsl:if test="not(@MVKD = 'DSCH' and ancestor::work[@moveStage = 'PLANNED'] and child::position[@type = 'from'][@AREA_TYPE = 'Vessel' or @AREA_TYPE = 'Rail'])">
                                    <xsl:apply-templates select="container"/>
                                    <xsl:text> </xsl:text>
                                    <xsl:apply-templates select="position[@type = 'from']/@AREA_TYPE"/>
                                    <xsl:text></xsl:text>
                                    <xsl:call-template name="rail-track-dsch-pos"/>
                                </xsl:if>
                                <xsl:apply-templates select="." mode="line-one-variable"/>
                                <br/>
                                <xsl:apply-templates select="@MVKD"/>
                                <xsl:text> </xsl:text>
                                <xsl:apply-templates select="tbdunit" mode="first"/>
                                <xsl:apply-templates select="container/@QWGT"/>
                                <xsl:text> </xsl:text>
                                <xsl:apply-templates select="container/@LNTH"/>
                                <xsl:text> </xsl:text>
                                <xsl:apply-templates select="." mode="line-two-variable"/>
                                <xsl:if test="@MVKD = 'DSCH' and ancestor::work[@moveStage = 'PLANNED'] and child::position[@type = 'from'][@AREA_TYPE = 'Vessel' or @AREA_TYPE = 'Rail']">
                                    <xsl:apply-templates select="container"/>
                                </xsl:if>
                                <xsl:if test="@MVKD = 'SHFT' and (@target!='')">
                                    <br/>
                                    <xsl:value-of select="text:format('label.Target_ID')"/>
                                    <xsl:text> </xsl:text>
                                    <xsl:value-of select="@target"/>
                                    <br/>
                                    <xsl:value-of select="text:format('label.Position')"/>
                                    <xsl:text> </xsl:text>
                                    <xsl:value-of select="@targetPosition"/>
                                </xsl:if>
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
                    <input type="hidden" name="pposTo"
                           value="{message/che/work/job[1]/position[@type = 'from']/@PPOS}"/>
                </form>
                <xsl:call-template name="footer"/>
            </body>

        </html>

    </xsl:template>

</xsl:stylesheet>

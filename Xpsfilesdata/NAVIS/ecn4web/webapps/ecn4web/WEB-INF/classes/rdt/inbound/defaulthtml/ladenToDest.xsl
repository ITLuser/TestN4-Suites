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
            <xsl:when test="not(contains($formId, 'TRUCK')) and message/che/work/@count = 2">
                <xsl:text>TWIN</xsl:text>
            </xsl:when>
            <xsl:when
                    test="contains($formId, 'TRUCK') and (count(distinct-values(/message/che/work/job/position[@type = 'to']/@AREA)) &gt; 1) and not(exists(/message/che/work/job/position[@type = 'to']/transferZone))">
                <xsl:text>MULTIPLE</xsl:text>
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
                                    select="text:format('title.Laden_to_dest', string(/message/che/work/job[1]/position[@type = 'to']/@AREA_TYPE))"/>
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
                        <xsl:with-param name="position-type" select="'to'"/>
                    </xsl:apply-templates>
                    <div class="data">
                        <xsl:for-each select="/message/che/work/job">
                            <div class="line-item">
                                <xsl:apply-templates select="." mode="instruction"/>
                                <xsl:text> </xsl:text>
                                <xsl:apply-templates select="." mode="position"/>
                                <xsl:text> </xsl:text>

                                <xsl:choose>
                                    <xsl:when test="container">
                                        <xsl:value-of select="container/@EQID"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="text:format('message.TBD_Generic_EQID')"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:text> </xsl:text>
                                <xsl:apply-templates select="position[@type = 'to']/@AREA_TYPE"/>
                                <xsl:apply-templates select="." mode="line-one-variable"/>
                                <xsl:text> </xsl:text>
                                <xsl:apply-templates select="position[@type='to']/@AREA"/>
                                <xsl:apply-templates select="@MVKD[. = 'LOAD' or . = 'DSCH']" mode="driveDirection"/>
                                <br/>
                                <xsl:apply-templates select="@MVKD"/>
                                <xsl:text> </xsl:text>
                                <xsl:apply-templates select="tbdunit"/>
                                <xsl:apply-templates select="container/@QWGT"/>
                                <xsl:text> </xsl:text>
                                <xsl:apply-templates select="container/@LNTH"/>
                                <xsl:text> </xsl:text>
                                <xsl:apply-templates select="." mode="line-two-variable"/>
                                <br/>
                                <xsl:variable name="line3Variable1">
                                    <xsl:apply-templates select="." mode="line-three-variable-1"/>
                                </xsl:variable>
                                <xsl:variable name="line3Variable2">
                                    <xsl:apply-templates select="." mode="line-three-variable-2"/>
                                </xsl:variable>
                                <xsl:copy-of select="$line3Variable1"/>
                                <xsl:if test="string-length($line3Variable1) != 0 and string-length($line3Variable2) != 0">
                                    <xsl:text>, </xsl:text>
                                </xsl:if>
                                <xsl:copy-of select="$line3Variable2"/>
                            </div>
                        </xsl:for-each>
                    </div>
                    <xsl:call-template name="command-menu">
                        <xsl:with-param name="mode" select="$mode"/>
                    </xsl:call-template>
                    <xsl:call-template name="hidden-fields">
                        <xsl:with-param name="mode" select="$mode"/>
                    </xsl:call-template>
                    <xsl:variable name="index">
                        <xsl:apply-templates select="message/che/work/job" mode="indexLaden"/>
                    </xsl:variable>
                    <input type="hidden" name="index" value="{$index}"/>
                    <input type="hidden" name="eqId" value="{message/che/work/job[1]/*/@EQID}"/>
                    <input type="hidden" name="pposTo" value="{message/che/work/job[1]/position[@type = 'to']/@AREA}"/>
                </form>
                <xsl:call-template name="footer"/>
            </body>

        </html>

    </xsl:template>

</xsl:stylesheet>

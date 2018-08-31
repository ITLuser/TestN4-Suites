<?xml version='1.0' encoding="utf-8"?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform' version='2.0'
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:text="http://www.navis.com/ecn4web/functions"
                exclude-result-prefixes="text">
    <xsl:import href="templates/common.xsl"/>
    <xsl:output method="xhtml" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
                doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
                indent="yes" omit-xml-declaration="yes" encoding="UTF-8"/>
    <xsl:preserve-space elements="td"/>
    <xsl:variable name="mode">
        <xsl:if test="message/che/container[2]/@EQID">TWIN</xsl:if>
    </xsl:variable>
    <xsl:variable name="items" select="message/che/container"/>

    <xsl:template match='/'>
        <html>
            <head>
                <xsl:call-template name="header">
                    <xsl:with-param name="pageTitle">
                        <xsl:choose>
                            <xsl:when test="$mode = 'TWIN'">
                                <xsl:value-of select="text:format('title.Confirm_Container.plural')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="text:format('title.Confirm_Container')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="mode" select="$mode"/>
                </xsl:call-template>
            </head>
            <body>
                <form id="xmlrdtForm" name="xmlrdtForm" action='{$contextPath}/servlet/xmlrdt' method='post'
                      accept-charset="UTF-8">
                    <xsl:call-template name="message-fragment">
                        <xsl:with-param name="mode" select="$mode"/>
                    </xsl:call-template>
                    <p>
                        <xsl:choose>
                            <xsl:when test="$mode = 'TWIN'">
                                <xsl:value-of select="text:format('message.Please_confirm_container_lifted.plural')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="text:format('message.Please_confirm_container_lifted')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </p>
                    <xsl:call-template name="command-menu">
                        <xsl:with-param name="mode" select="$mode"/>
                    </xsl:call-template>

                    <xsl:call-template name="hidden-fields">
                        <xsl:with-param name="mode" select="$mode"/>
                    </xsl:call-template>
                    <xsl:variable name="index">
                        <xsl:apply-templates select="$items" mode="index"/>
                    </xsl:variable>
                    <input type="hidden" name="index" value="{$index}"/>
                    <input type="hidden" name="eqId" value="{message/che/container[1]/@EQID}"/>
                    <input type="hidden" name="pposTo"
                           value="{/message/che/container[1]/position[@type = 'from']/@PPOS}"/>
                </form>
                <xsl:call-template name="footer"/>
            </body>

        </html>

    </xsl:template>

    <!-- This index serializes all container items to string form: 1:TEST0000001, ...
    This field will be processed by the outbound message to ECN4 -->
    <xsl:template match="container" mode="index">
        <xsl:value-of select="concat(position(),':', @EQID, ':', @JPOS)"/>
        <xsl:if test="position() != last()">,</xsl:if>
    </xsl:template>

</xsl:stylesheet>

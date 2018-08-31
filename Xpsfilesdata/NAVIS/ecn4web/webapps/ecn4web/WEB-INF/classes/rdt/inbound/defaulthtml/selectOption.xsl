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
    <xsl:import href="templates/pagination.xsl"/>
    <xsl:import href="templates/attributes/attribute-dictionary-optionlist.xsl"/>
    <xsl:output method="xhtml" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
                doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" indent="yes" omit-xml-declaration="yes"
                encoding="UTF-8"/>

    <xsl:variable name="maxPerPage" as="xs:integer">
        <xsl:choose>
            <xsl:when test="/message/che/option-list/@maxAllowed != ''">
                <xsl:value-of select="/message/che/option-list/@maxAllowed"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="6"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="item-name" select="/message/che/option-list/@name"/>
    <xsl:variable name="mode" as="xs:string">
        <xsl:choose>
            <xsl:when test="$item-name != 'Container'">
                <xsl:value-of select="''"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="/message/che/option-list/@type = 'TWIN'">SELECTOPTION_TWIN</xsl:when>
                    <xsl:otherwise>SELECTOPTION</xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="totalCount" select="/message/che/option-list/@count" as="xs:integer"/>
    <xsl:variable name="items" select="/message/che/option-list/*"/>
    <xsl:variable name="item-name-arg" select="text:format(concat('label.', $item-name))"/>
    <xsl:variable name="item-area-type"
                  select="string(/message/che/option-list/unit[1]/position[@type = 'from']/@AREA_TYPE)"/>
    <xsl:variable name="title-name-resource">
        <xsl:call-template name="form-title-resource">
            <xsl:with-param name="mode" select="$mode"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="title-name">
        <xsl:value-of select="text:format(normalize-space($title-name-resource), ($item-name, $item-area-type))"/>
    </xsl:variable>
    <xsl:variable name="cssSytle" select="if ($totalCount != 0) then 'pagination' else 'pagination-no-border'"/>

    <xsl:template match='/'>
        <html>
            <head>
                <xsl:call-template name="header">
                    <xsl:with-param name="pageTitle" select="$title-name"/>
                    <xsl:with-param name="mode" select="$mode"/>
                </xsl:call-template>
            </head>
            <body>
                <form id="xmlrdtForm" name="xmlrdtForm" action='{$contextPath}/servlet/xmlrdt' method='post'
                      accept-charset="UTF-8">
                    <xsl:call-template name="message-fragment">
                        <xsl:with-param name="mode" select="$mode"/>
                    </xsl:call-template>
                    <fieldset class="{$cssSytle}">
                        <legend>
                            <span class="header">
                                <!-- noinspection XsltTemplateInvocation -->
                                <xsl:call-template name="pagination-controls">
                                    <xsl:with-param name="pagination-title">
                                        <xsl:call-template name="paginationTitle">
                                            <xsl:with-param name="items" select="$items"/>
                                            <xsl:with-param name="item-name" select="$item-name"/>
                                        </xsl:call-template>
                                    </xsl:with-param>
                                    <xsl:with-param name="mode" select="$mode"/>
                                </xsl:call-template>
                                <xsl:if test="matches($mode, 'SELECTOPTION|SELECTOPTION_TWIN')">
                                    <xsl:call-template name="toggle-single-twin-options">
                                        <xsl:with-param name="mode" select="$mode"/>
                                    </xsl:call-template>
                                </xsl:if>
                            </span>
                        </legend>

                        <xsl:if test="$totalCount != 0">
                            <table class="data">
                                <tbody>
                                    <xsl:choose>
                                        <xsl:when test="$item-name != 'Container'">
                                            <xsl:apply-templates select="$items"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:apply-templates select="/message/che/option-list">
                                                <xsl:with-param name="items" select="$items"/>
                                            </xsl:apply-templates>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </tbody>
                            </table>
                        </xsl:if>
                    </fieldset>

                    <xsl:call-template name="command-menu">
                        <xsl:with-param name="mode" select="$mode"/>
                    </xsl:call-template>
                    <xsl:call-template name="pagination-fields">
                        <xsl:with-param name="items" select="$items"/>
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

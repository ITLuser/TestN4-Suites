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
                    <xsl:when test="/message/che/option-list/unit/container[1]/@JPOS != 'CTR'">SELECTOPTION_TWIN
                    </xsl:when>
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
    <xsl:variable name="cssSytle" select="if ($totalCount != 0) then 'pagination' else 'pagination-no-border'"/>

    <xsl:template match='/'>
        <html>
            <head>
                <xsl:call-template name="header">
                    <xsl:with-param name="pageTitle" select="Container"/>
                    <xsl:with-param name="mode" select="''"/>
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

    <!-- Option rendering -->
    <xsl:template match="option[ancestor::option-list[not(matches(@name, 'Container'))]]">
        <tr>
            <td class="label">
                <xsl:apply-templates select="@index"/>
            </td>
            <td class="value">
                <xsl:apply-templates select="if(@label) then @label else @name"/>
            </td>
        </tr>
        <xsl:choose>
            <xsl:when test="position() = 1">
                <!-- This value will be used for pagination -->
                <input type="hidden" name="start" value="{@name}"/>
            </xsl:when>
            <xsl:when test="position() = last()">
                <!-- This value will be used for pagination -->
                <input type="hidden" name="pivot" value="{@name}"/>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>

    </xsl:template>

    <xsl:template match="@LNTH">
        <xsl:text>"</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>"</xsl:text>
    </xsl:template>
    <xsl:template match="position/@TRNS">
        <xsl:text>+</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>+</xsl:text>
    </xsl:template>
    <xsl:template match="position/@TRKL">
        <xsl:text>+</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>+</xsl:text>
    </xsl:template>
    <xsl:template match="position/@transport">
        <xsl:text>*</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>*</xsl:text>
    </xsl:template>
    <xsl:template match="position/@PPOS">
        <xsl:value-of select="."/>
    </xsl:template>

    <!-- This is common renderer for Container and tbdUnit -->
    <xsl:template match="option-list[matches(@name, 'Container')]">
        <xsl:for-each-group select="$items" group-by="@index">
            <tr class="button" id="{@index}">
                <td class="line-index"/>

                <xsl:for-each select="current-group()">
                    <td class="line-index">
                        <a href="#">
                            <xsl:value-of select="@index"/>
                        </a>
                    </td>
                    <td>
                        <xsl:apply-templates select="tbdunit/@EQID | container/@EQID"/>
                    </td>
                    <td class="attr-left">
                        <xsl:apply-templates
                                select="position[@type= 'from']/(@TRNS[. != ''], @TRKL[. != ''], @transport[. != ''], @PPOS)[1]"/>
                    </td>
                    <td class="attr-op">&#xbb;</td>
                    <td class="attr-right">
                        <xsl:apply-templates
                                select="position[@type= 'to']/(@TRNS[. != ''], @TRKL[. != ''], @transport[. != ''], @PPOS)[1]"/>
                    </td>
                    <td>
                        <xsl:apply-templates select="container/@LNTH"/>
                    </td>

                    <xsl:if test="position() != last()">
                        <xsl:text>, </xsl:text>
                    </xsl:if>

                </xsl:for-each>

            </tr>
            <xsl:if test="position() = last()">
                <xsl:for-each select="current-group()">
                    <xsl:if test="position() = last()">
                        <!-- This value will be used for pagination -->
                        <input type="hidden" name="pivot" value="{tbdunit/@EQID | container/@EQID}"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
        </xsl:for-each-group>
    </xsl:template>

    <!-- This index serializes all option items to string form: 1:Item1:asc, ... -->
    <xsl:template match="option" mode="index">
        <xsl:value-of select="concat(@index,':', normalize-unicode(@name))"/>
        <xsl:if test="position() != last()">,</xsl:if>
    </xsl:template>
    <!-- This index serializes all container/tbdunit items to string form: 1:TEST0000001:container, ...
        This field will be processed by the outbound message to ECN4, mapping index to ID and
        getting unit type to determine outgoing message -->
    <xsl:template match="unit" mode="index">
        <xsl:variable name="unit-id" select="tbdunit/@EQID | container/@EQID"/>
        <xsl:variable name="unit-jpos" select="tbdunit/@JPOS | container/@JPOS"/>
        <xsl:variable name="unit-type">
            <xsl:choose>
                <xsl:when test="name(container) and not(@swappableDelivery = 'Y')">c</xsl:when>
                <!-- empty delivery job -->
                <xsl:when test="name(container) and @swappableDelivery = 'Y'">e</xsl:when>
                <xsl:otherwise>t</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="unit-from-pos">
            <xsl:choose>
                <xsl:when test="position[@type= 'from']/@TRNS != ''">
                    <xsl:value-of select="position[@type = 'from']/@TRNS"/>
                </xsl:when>
                <xsl:when test="position[@type= 'from']/@TRKL != ''">
                    <xsl:value-of select="position[@type = 'from']/@TRKL"/>
                </xsl:when>
                <xsl:when test="position[@type = 'from']/@transport != ''">
                    <xsl:value-of select="position[@type = 'from']/@transport"/>
                </xsl:when>
                <xsl:when test="position[@type = 'from']/@AREA_TYPE = 'ITV'">
                    <xsl:value-of select="position[@type = 'from']/@PPOS"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="position[@type = 'from']/@PPOS"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="concat(@index,':',$unit-id,':',$unit-type,':',$unit-jpos,':',$unit-from-pos)"/>
        <xsl:if test="position() != last()">,</xsl:if>
    </xsl:template>

</xsl:stylesheet>

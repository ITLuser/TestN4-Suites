<?xml version='1.0' encoding='utf-8'?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
                version="2.0" exclude-result-prefixes="xs">
    <xsl:output method="xhtml" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
                doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" indent="yes" omit-xml-declaration="yes" encoding="UTF-8"/>

    <!-- Option rendering -->
    <xsl:template match="option[ancestor::option-list[not(matches(@name, 'Container'))]]">
        <tr class="button" id="{@name}">
            <td class="index">
                <xsl:apply-templates select="@index"/>
            </td>
            <td>
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

    <!-- This is common renderer for Container and tbdUnit -->
    <xsl:template match="option-list[matches(@name, 'Container')]">
        <xsl:param name="items"/>
        <xsl:for-each-group select="$items" group-by="@index">
            <tr class="button" id="{@index}">
                <td class="line-index">
                    <a href="#">
                        <xsl:value-of select="@index"/>
                    </a>
                </td>
                <td>
                    <xsl:for-each select="current-group()">
                        <xsl:apply-templates select="tbdunit/@EQID | container/@EQID"/>
                        <xsl:if test="position() != last()">
                            <xsl:text>, </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </td>
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

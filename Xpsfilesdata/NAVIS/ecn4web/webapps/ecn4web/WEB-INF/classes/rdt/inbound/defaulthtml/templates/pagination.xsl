<?xml version='1.0' encoding="utf-8"?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:text="http://www.navis.com/ecn4web/functions"
                exclude-result-prefixes="xs text"
                version="2.0">
    <xsl:import href="functions.xsl"/>
    <xsl:output method="xhtml" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
                doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" indent="yes" omit-xml-declaration="yes"
                encoding="UTF-8"/>

    <xsl:template name="paginationTitle" as="xs:string">
        <xsl:param name="items" required="yes"/>
        <xsl:param name="item-name" required="yes"/>
        <xsl:variable name="item-index" select="$items[1]/@index"/>
        <xsl:variable name="page" as="xs:integer">
            <xsl:choose>
                <xsl:when test="$totalCount != 0">
                    <xsl:value-of select="round(number($items[1]/@index) div $maxPerPage + 1)"/>
                </xsl:when>
                <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="pages" as="xs:integer">
            <xsl:choose>
                <xsl:when test="$totalCount != 0">
                    <xsl:value-of select="ceiling($totalCount div $maxPerPage)"/>
                </xsl:when>
                <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="item-name-arg" select="text:format(concat('label.', $item-name))"/>
        <xsl:variable name="item-name-arg-plural" select="text:format(concat('label.', $item-name, '.plural'))"/>
        <xsl:choose>
            <xsl:when test="$totalCount = 0">
                <xsl:message select="'no items'"/>
                <xsl:value-of select="text:format('message.No_items', $item-name-arg-plural)"/>
            </xsl:when>
            <xsl:when test="$totalCount = 1">
                <xsl:message select="'items on page'"/>
                <xsl:value-of select="text:format('message.1_item', $item-name-arg)"/>
            </xsl:when>
            <xsl:when test="$totalCount &lt;= $maxPerPage">
                <xsl:value-of
                        select="text:format('message.x_items_on_page', (string($totalCount), $item-name-arg-plural))"/>
            </xsl:when>
            <xsl:when test="$maxPerPage eq 1">
                <xsl:choose>
                    <xsl:when test="$item-index &lt; 4">
                        <xsl:value-of
                                select="text:format(concat('message.', $item-index, '_of_items'), (string($totalCount), $item-name-arg-plural))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of
                                select="text:format('message.nth_of_items', ($item-index, string($totalCount), $item-name-arg-plural))"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of
                        select="text:format('message.first_to_last_of_x_items', ($items[1]/@index, $items[last()]/@index, string($totalCount), $item-name-arg-plural))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="pagination-fields">
        <xsl:param name="items"/>
        <xsl:variable name="index">
            <xsl:apply-templates select="$items" mode="index"/>
        </xsl:variable>
        <input type="hidden" name="totalCount" value="{$totalCount}"/>
        <input type="hidden" name="index" value="{$index}"/>
        <input type="hidden" name="maxPageItems" value="6"/>
    </xsl:template>
</xsl:stylesheet>
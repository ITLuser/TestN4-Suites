<?xml version='1.0' encoding='utf-8'?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <!-- This template is never called directly, only by forward or backward pagination actions -->

    <xsl:template name="main">

        <xsl:param name="cheId" required="yes"/>
        <xsl:param name="pivotEqId" required="yes"/>
        <xsl:param name="maxPageItems" required="yes"/>
        <xsl:param name="paginationOperator" select="''" required="no"/>
        <xsl:param name="formId" required="yes"/>
        <xsl:param name="msid" required="yes"/>
        <xsl:param name="filterType" required="no"/>
        <xsl:param name="filterUserParameter" required="no"/>
        <xsl:param name="sortType" required="no"/>
        <xsl:param name="sortUserParameter" required="no"/>

        <xsl:variable name="size">
            <xsl:choose>
                <xsl:when test="$paginationOperator = '-'">
                    <xsl:value-of select="-number($maxPageItems)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$maxPageItems"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <message type="2724" MSID="{$msid}" formId="{$formId}">
            <che CHID="{$cheId}">
                <joblist fromEQID="{$pivotEqId}" size="{$size}">
                    <!-- can only set either filter or sorter attributes at a time -->
                    <xsl:choose>
                        <xsl:when test="$filterType">
                            <xsl:attribute name="filterType" select="$filterType"/>
                            <xsl:attribute name="filterUserParameter" select="$filterUserParameter"/>
                        </xsl:when>
                        <xsl:when test="$sortType">
                            <xsl:attribute name="sortType" select="$sortType"/>
                            <xsl:attribute name="sortUserParameter" select="$sortUserParameter"/>
                        </xsl:when>
                    </xsl:choose>
                </joblist>
            </che>
        </message>

    </xsl:template>

</xsl:stylesheet>

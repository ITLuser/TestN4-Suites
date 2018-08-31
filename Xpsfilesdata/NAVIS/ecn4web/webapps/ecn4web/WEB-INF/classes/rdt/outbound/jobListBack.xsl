<?xml version='1.0' encoding='utf-8'?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="xs">
    <!-- This template is a pre-processort for the show job list request to include pagination attributes -->
    <xsl:import href="showJobList.xsl"/>
    <xsl:param name="cheId" required="yes"/>
    <xsl:param name="msid" required="yes"/>
    <xsl:param name="formId" required="yes"/>
    <xsl:param name="startEqId" required="yes"/>
    <xsl:param name="maxPageItems" select="6" required="no"/>
    <xsl:param name="filterType" required="no" select="''"/>
    <xsl:param name="sortType" required="no" select="''"/>
    <xsl:template match="/">
        <!-- ECN4 expects the pagination instruction as: -6 or 6 for paginating 6 items back or forward respectively -->
        <xsl:variable name="paginationOperator" select="'-'"/>

        <xsl:call-template name="main">
            <!-- Override the normal forward pivot. When paginating back, the start index is the pagination pivot -->
            <xsl:with-param name="pivotEqId" select="$startEqId"/>
            <xsl:with-param name="formId" select="$formId"/>
            <xsl:with-param name="cheId" select="$cheId"/>
            <xsl:with-param name="msid" select="$msid"/>
            <xsl:with-param name="maxPageItems" select="$maxPageItems"/>
            <xsl:with-param name="paginationOperator" select="$paginationOperator"/>
            <xsl:with-param name="filterType" select="$filterType"/>
            <xsl:with-param name="sortType" select="$sortType"/>
        </xsl:call-template>
    </xsl:template>
</xsl:stylesheet>

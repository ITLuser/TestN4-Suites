<?xml version='1.0' encoding='utf-8'?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href="driveToSingleOrigin.xsl"/>
    <xsl:param name="cheId" required="yes"/>
    <xsl:param name="msid" required="yes"/>
    <xsl:param name="formId" required="yes"/>
    <xsl:param name="index" required="yes"/>

    <xsl:template match="/">
        <!-- Deserialize unit/container info passed from form, to enable index lookup.
          The format expected is: 1:AA23, ... -->
        <xsl:variable name="unit-nodes" as="node()*">
            <xsl:call-template name="get-unit-nodes"/>
        </xsl:variable>
        <xsl:call-template name="main">
            <xsl:with-param name="cheId" select="$cheId"/>
            <xsl:with-param name="formId" select="$formId"/>
            <xsl:with-param name="msid" select="$msid"/>
            <xsl:with-param name="pposTo" select="$unit-nodes[@index = '1']/@tzBlock"/>
        </xsl:call-template>

    </xsl:template>

    <!-- Deserialize to abstract xml unit elements, so they can be queried using XPath -->
    <xsl:template name="get-unit-nodes" as="node()*">
        <xsl:for-each select="tokenize($index, ',')">
            <xsl:variable name="unit-attributes" select="tokenize(.,':')"/>
            <unit index="{$unit-attributes[1]}" tzBlock="{$unit-attributes[7]}"/>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>

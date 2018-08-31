<?xml version='1.0' encoding='utf-8'?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
    <xsl:import href="doConfirmContainer.xsl"/>

    <xsl:param name="cheId" required="yes"/>
    <xsl:param name="msid" required="yes"/>
    <xsl:param name="formId" required="yes"/>
    <xsl:param name="pposTo" required="no"/>
    <xsl:param name="mode" required="yes"/>
    <xsl:param name="index" required="yes"/>
    <xsl:param name="inputValue"/>
    <xsl:param name="inputValue2" required="no"/>

    <xsl:variable name="unit-nodes" as="node()*">
        <xsl:call-template name="get-unit-nodes">
            <xsl:with-param name="unitindex" select="$index"/>
        </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="eqId" as="xs:string">
        <xsl:choose>
            <!-- Use as index if less than 5 characters and within the range of unit indices on page. Letter characters will fail -->
            <xsl:when test="string-length(string($inputValue)) &lt; 5 and
                    (number($inputValue) &gt;= number($unit-nodes[position() = 1]/@index) and
                     number($inputValue) &lt;= number($unit-nodes[position() = last()]/@index))">
                <xsl:value-of select="$unit-nodes[@index=$inputValue][1]/@id"/>
            </xsl:when>
            <!-- If not an index, send the input to ECN4 whether its partial or not -->
            <xsl:otherwise>
                <xsl:value-of select="$inputValue"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="eqId2" as="xs:string">
        <xsl:choose>
            <!-- Use as index if less than 5 characters and within the range of unit indices on page. Letter characters will fail -->
            <xsl:when test="string-length(string($inputValue)) &lt; 5 and
                    (number($inputValue) &gt;= number($unit-nodes[position() = 1]/@index) and
                     number($inputValue) &lt;= number($unit-nodes[position() = last()]/@index))">
                <xsl:value-of select="$unit-nodes[@index=$inputValue][2]/@id"/>
            </xsl:when>
            <!-- If not an index, send the input to ECN4 whether its partial or not -->
            <xsl:otherwise>
                <xsl:value-of select="$inputValue2"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:template match="/">
        <xsl:call-template name="main">
            <xsl:with-param name="cheId" select="$cheId"/>
            <xsl:with-param name="msid" select="$msid"/>
            <xsl:with-param name="formId" select="$formId"/>
            <xsl:with-param name="eqId" select="$eqId"/>
            <xsl:with-param name="eqId2" select="$eqId2"/>
            <xsl:with-param name="mode" select="$mode"/>
            <xsl:with-param name="pposTo" select="''"/>
        </xsl:call-template>
    </xsl:template>

    <!-- DeSerialize index -->
    <xsl:template name="get-unit-nodes" as="node()*">
        <xsl:param name="unitindex" as="xs:string"/>
        <xsl:for-each select="tokenize($index, ',')">
            <xsl:variable name="unit-attributes" select="tokenize(.,':')"/>
            <unit index="{$unit-attributes[1]}" id="{$unit-attributes[2]}" type="{$unit-attributes[3]}" jpos="{$unit-attributes[4]}"/>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>

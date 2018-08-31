<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="xs">
    <xsl:import href="showJobList.xsl"/>

    <xsl:param name="cheId" required="yes"/>
    <xsl:param name="msid" required="yes"/>
    <xsl:param name="formId" required="yes"/>
    <xsl:param name="inputValue"/>
    <xsl:param name="inputValue2" required="no" select="''"/>
    <xsl:param name="index" as="xs:string" required="yes"/>
    <xsl:param name="pivotEqId" required="no" select="''"/>
    <xsl:param name="maxPageItems" select="6" required="no"/>

    <xsl:template match="/">
        <!-- Deserialize unit/filterType info passed from form, to enable index lookup.
            The format expected is: 1:ascendingFilter, ... -->
        <xsl:variable name="unit-nodes" as="node()*">
            <xsl:call-template name="get-unit-nodes"/>
        </xsl:variable>
        <xsl:variable name="filterType" as="xs:string">
            <xsl:choose>
                <xsl:when test="string-length(string($inputValue)) &lt; 5 and (number($inputValue) &gt;= number($unit-nodes[position() =1]/@index) and
                               number($inputValue) &lt;= number($unit-nodes[position() = last()]/@index))">
                    <xsl:value-of select="$unit-nodes[@index = $inputValue]/@name"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$inputValue"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="paginationOperator" select="''"/>

        <xsl:call-template name="main">
            <!-- Override the normal forward pivot. When paginating forward, the pivot index
                passed from the form (end index) is the pagination pivot -->
            <xsl:with-param name="pivotEqId" select="$pivotEqId"/>
            <xsl:with-param name="formId" select="$formId"/>
            <xsl:with-param name="msid" select="$msid"/>
            <xsl:with-param name="cheId" select="$cheId"/>
            <xsl:with-param name="maxPageItems" select="$maxPageItems"/>
            <xsl:with-param name="paginationOperator" select="$paginationOperator"/>
            <xsl:with-param name="filterType" select="$filterType"/>
            <xsl:with-param name="filterUserParameter" select="$inputValue2"/>
        </xsl:call-template>

    </xsl:template>

    <!-- Deserialize to abstract xml unit elements, so they can be queried using XPath -->
    <xsl:template name="get-unit-nodes" as="node()*">
        <xsl:for-each select="tokenize($index, ',')">
            <xsl:variable name="unit-attributes" select="tokenize(.,':')"/>
            <unit index="{$unit-attributes[1]}" name="{$unit-attributes[2]}"/>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
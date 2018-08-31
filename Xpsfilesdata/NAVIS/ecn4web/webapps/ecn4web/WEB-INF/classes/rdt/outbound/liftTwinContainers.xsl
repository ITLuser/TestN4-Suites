<?xml version='1.0' encoding='utf-8'?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:param name="cheId" required="yes"/>
    <xsl:param name="msid" required="yes"/>
    <xsl:param name="formId" required="yes"/>
    <xsl:param name="index" required="yes"/>

    <xsl:template match="/">
        <!-- Deserialize unit/container info passed from form, to enable index lookup.
          The format expected is: 1:TEST0000001:FWD:AA23, ... -->
        <xsl:variable name="unit-nodes" as="node()*">
            <xsl:call-template name="get-unit-nodes"/>
        </xsl:variable>

        <message type="2630" MSID="{$msid}" formId="{$formId}">
            <che CHID="{$cheId}" action="L" SPOS="T">
                <container EQID="{$unit-nodes[@index = '1']/@id}" JPOS="{$unit-nodes[@index = '1']/@jpos}">
                    <position PPOS="{$unit-nodes[@index = '1']/@pposTo}"/>
                </container>
                <container EQID="{$unit-nodes[@index = '2']/@id}" JPOS="{$unit-nodes[@index = '2']/@jpos}">
                    <position PPOS="{$unit-nodes[@index = '2']/@pposTo}"/>
                </container>
            </che>
        </message>

    </xsl:template>

    <!-- Deserialize to abstract xml unit elements, so they can be queried using XPath -->
    <xsl:template name="get-unit-nodes" as="node()*">
        <xsl:for-each select="tokenize($index, ',')">
            <xsl:variable name="unit-attributes" select="tokenize(.,':')"/>
            <unit index="{$unit-attributes[1]}" id="{$unit-attributes[2]}" jpos="{$unit-attributes[3]}" pposTo="{$unit-attributes[4]}"/>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>

<?xml version='1.0' encoding='utf-8'?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <!-- This template is a pre-processort for the show job list request to include pagination attributes -->
    <xsl:param name="cheId" required="yes"/>
    <xsl:param name="msid" required="yes"/>
    <xsl:param name="formId" required="yes"/>
    <xsl:param name="pposTo" required="no"/>
    <xsl:param name="index" required="yes"/>

    <xsl:template match='/'>
        <!-- Deserialize unit/container info passed from form, to enable index lookup.
          The format expected is: 1:TEST0000001:AA23:Yard, ... -->
        <xsl:variable name="unit-nodes" as="node()*">
            <xsl:call-template name="get-unit-nodes"/>
        </xsl:variable>

        <message type="2630" formId="{$formId}" MSID="{$msid}">
            <xsl:choose>
                <xsl:when test="$unit-nodes[@index = '1']/@pullable != ''">
                    <che CHID="{$cheId}" action="Pull">
                        <xsl:for-each select="$unit-nodes">
                            <container EQID="{@id}">
                                <xsl:if test="upper-case(@pullable)= 'Y'">
                                    <position PPOS="{@pposTo}"/>
                                </xsl:if>
                            </container>
                        </xsl:for-each>
                    </che>
                </xsl:when>
                <xsl:otherwise>
                    <che CHID="{$cheId}" action="B"/>
                </xsl:otherwise>
            </xsl:choose>
        </message>

    </xsl:template>

    <!-- Deserialize to abstract xml unit elements, so they can be queried using XPath -->
    <xsl:template name="get-unit-nodes" as="node()*">
        <xsl:for-each select="tokenize($index, ',')">
            <xsl:variable name="unit-attributes" select="tokenize(.,':')"/>
            <unit index="{$unit-attributes[1]}" id="{$unit-attributes[2]}" jpos="{$unit-attributes[3]}" pposTo="{$unit-attributes[4]}"
                  pullable="{$unit-attributes[5]}"/>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>

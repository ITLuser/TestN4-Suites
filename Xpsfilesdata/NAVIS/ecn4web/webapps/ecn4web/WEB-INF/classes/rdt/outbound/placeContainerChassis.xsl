<?xml version='1.0' encoding="utf-8"?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:param name="cheId" required="yes"/>
    <xsl:param name="msid" required="yes"/>
    <xsl:param name="formId" required="yes"/>
    <xsl:param name="mode" required="no"/>
    <xsl:param name="inputValue" required="no"/>
    <xsl:param name="inputValue2" required="no"/>
    <xsl:param name="eqId" required="no"/>
    <xsl:param name="chassis" select="$inputValue"/>
    <xsl:param name="eqId2" required="no"/>
    <xsl:param name="pposTo" select="$inputValue2"/>
    <xsl:param name="labelValueIndex"/>

    <xsl:template name="main">
        <xsl:param name="eqIdParam"/>
        <xsl:param name="pposToParam"/>
        <xsl:param name="chassisParam"/>
        <container EQID="{$eqIdParam}">
            <xsl:choose>
                <xsl:when test="$chassisParam != ''">
                    <position PPOS="{$pposToParam}" CHASSIS="{$chassisParam}"/>
                </xsl:when>
                <xsl:otherwise>
                    <position PPOS="{$pposToParam}"/>
                </xsl:otherwise>
            </xsl:choose>
        </container>
    </xsl:template>

    <xsl:template match="/">
        <xsl:variable name="unit-nodes">
            <xsl:choose>
                <xsl:when test="$labelValueIndex">
                    <xsl:call-template name="get-unit-nodes">
                        <xsl:with-param name="index" select="$labelValueIndex"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <message type="2630" MSID="{$msid}" formId="{$formId}">
            <che CHID="{$cheId}" action="C">
                <xsl:choose>
                    <xsl:when test="$inputValue2">
                        <!-- Used for re-handle, single container at a time -->
                        <xsl:call-template name="main">
                            <xsl:with-param name="eqIdParam" select="$eqId"/>
                            <xsl:with-param name="pposToParam" select="$inputValue2"/>
                            <xsl:with-param name="chassisParam" select="$chassis"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:for-each select="$unit-nodes/unit">
                            <xsl:call-template name="main">
                                <xsl:with-param name="eqIdParam" select="@eqId"/>
                                <xsl:with-param name="pposToParam" select="@pposTo"/>
                                <xsl:with-param name="chassisParam" select="$chassis"/>
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>
            </che>
        </message>
    </xsl:template>

    <!-- Deserialize to abstract xml unit elements, so they can be queried using XPath -->
    <xsl:template name="get-unit-nodes">
        <xsl:param name="index"/>
        <xsl:for-each select="tokenize($index, ',')">
            <xsl:variable name="unit-attributes" select="tokenize(.,':')"/>
            <unit eqId="{$unit-attributes[1]}" pposTo="{$unit-attributes[2]}"/>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>

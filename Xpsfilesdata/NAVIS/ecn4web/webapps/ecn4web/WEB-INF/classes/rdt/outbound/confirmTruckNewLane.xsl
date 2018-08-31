<?xml version='1.0' encoding='utf-8'?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href="doConfirmTruckLane.xsl"/>

    <xsl:param name="cheId" required="yes"/>
    <xsl:param name="msid" required="yes"/>
    <xsl:param name="formId" required="yes"/>
    <xsl:param name="mode" required="no"/>
    <xsl:param name="ppos" required="yes"/>
    <xsl:param name="truckId" required="yes"/>
    <xsl:param name="truckLane" required="no"/>
    <xsl:param name="inputValue" select="$truckLane" required="no"/>

    <xsl:template match="/">

        <xsl:call-template name="main">
            <xsl:with-param name="cheId" select="$cheId"/>
            <xsl:with-param name="msid" select="$msid"/>
            <xsl:with-param name="formId" select="$formId"/>
            <xsl:with-param name="ppos" select="$ppos"/>
            <xsl:with-param name="truckId" select="$truckId"/>
            <xsl:with-param name="truckLane" select="$inputValue"/>
            <xsl:with-param name="mode" select="$mode"/>
        </xsl:call-template>

    </xsl:template>
</xsl:stylesheet>

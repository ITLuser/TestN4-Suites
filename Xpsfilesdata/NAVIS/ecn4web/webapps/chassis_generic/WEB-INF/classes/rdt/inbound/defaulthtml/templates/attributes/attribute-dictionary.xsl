<?xml version='1.0' encoding="utf-8"?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
                xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="xs"
                version='2.0'>
    <xsl:import href="ecn4web:attribute-dictionary.xsl"/>

    <xsl:output method="xhtml" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
    doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" indent="yes" omit-xml-declaration="yes" encoding="UTF-8"/>

    <!-- This index serializes all container items to string form: 1:TEST0000001:FWD:AA21:Yard, ...
       This field will be processed by the outbound message to ECN4 -->
    <xsl:template match="job" mode="indexEmpty">
        <xsl:value-of select="position()"/>
        <xsl:text>:</xsl:text><xsl:value-of select="container/@EQID|tbdunit/@EQID"/>
        <xsl:text>:</xsl:text><xsl:value-of select="container/@JPOS|tbdunit/@JPOS"/>
        <xsl:text>:</xsl:text><xsl:value-of select="position[@type = 'from']/@PPOS"/>
        <xsl:text>:</xsl:text><xsl:value-of select="position[@type = 'from']/@pullable"/>
        <xsl:text>:</xsl:text>
        <xsl:choose>
            <xsl:when test="container[@swappableDelivery = 'Y']">e</xsl:when>
            <!--x below represents a trailer unit like chassis, bombcart or cassette.-->
            <xsl:when test="container[@isTrailer = 'Y']">x</xsl:when>
            <xsl:when test="container">c</xsl:when>
            <xsl:when test="tbdunit">t</xsl:when>
        </xsl:choose>
        <xsl:text>:</xsl:text><xsl:value-of select="position[@type = 'from']/transferZone[1]/@BLOCK"/>
        <xsl:text>:</xsl:text><xsl:value-of select="position[@type = 'from']/transferZone[2]/@BLOCK"/>
        <xsl:if test="position() != last()">,</xsl:if>
    </xsl:template>

</xsl:stylesheet>

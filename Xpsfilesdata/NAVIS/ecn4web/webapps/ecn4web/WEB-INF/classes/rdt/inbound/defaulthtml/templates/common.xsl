<?xml version='1.0' encoding="utf-8"?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href="functions.xsl"/>
    <xsl:import href="header.xsl"/>
    <xsl:import href="messageFragment.xsl"/>
    <xsl:import href="formCommands.xsl"/>
    <xsl:import href="hiddenFields.xsl"/>
    <xsl:import href="footer.xsl"/>

    <xsl:variable name="formId" select="/message/@formId"/>
    <xsl:variable name="cheId" select="/message/che/@CHID"/>
    <xsl:variable name="aCheId" select="/message/che/@ACHE"/>
    <xsl:variable name="sCheId" select="/message/che/@SCHE"/>
</xsl:stylesheet>

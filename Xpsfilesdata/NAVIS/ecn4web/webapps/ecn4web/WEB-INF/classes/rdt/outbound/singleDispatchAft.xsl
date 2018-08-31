<?xml version='1.0' encoding='utf-8'?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <!-- This template is a pre-processort for the show job list request to include pagination attributes -->
    <xsl:import href="selectJob.xsl"/>

    <xsl:param name="cheId" required="yes"/>
    <xsl:param name="formId" required="yes"/>
    <xsl:param name="msid" required="yes"/>
    <xsl:param name="eqId2" required="yes"/>
    <xsl:param name="index" required="no" select="''"/>
    <xsl:param name="totalCount" select="1" required="no"/>
    <xsl:template match="/">

        <xsl:call-template name="main">
            <!-- Override the normal forward pivot. When paginating forward, the pivot index
                passed from the form (end index) is the pagination pivot -->
            <xsl:with-param name="formId" select="$formId"/>
            <xsl:with-param name="msid" select="$msid"/>
            <xsl:with-param name="cheId" select="$cheId"/>
            <xsl:with-param name="inputValue" select="$eqId2"/>
            <xsl:with-param name="index" select="$index"/>
            <xsl:with-param name="totalCount" select="$totalCount"/>
            <xsl:with-param name="selectTarget" select="'dispatch'"/>
        </xsl:call-template>
    </xsl:template>
</xsl:stylesheet>
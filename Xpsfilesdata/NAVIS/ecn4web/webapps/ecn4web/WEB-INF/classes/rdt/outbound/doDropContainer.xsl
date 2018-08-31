<?xml version='1.0' encoding='utf-8'?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <!-- This template is a pre-processort for the show job list request to include pagination attributes -->
    <xsl:template name="main">
        <xsl:param name="cheId" required="yes"/>
        <xsl:param name="msid" required="yes"/>
        <xsl:param name="formId" required="yes"/>
        <xsl:param name="pposTo1" required="yes"/>
        <xsl:param name="pposTo2" required="no"/>
        <xsl:param name="jpos1" required="yes"/>
        <xsl:param name="jpos2" select="''" required="no"/>
        <xsl:param name="trkl" required="no" />

        <message type="2630" MSID="{$msid}" formId="{$formId}">
            <che CHID="{$cheId}" action="D">
                <position PPOS="{$pposTo1}" JPOS="{$jpos1}" TRKL="{$trkl}"/>
                <xsl:if test="$pposTo2 != ''">
                    <position PPOS="{$pposTo2}" JPOS='{$jpos2}'/>
                </xsl:if>
            </che>
        </message>

    </xsl:template>
</xsl:stylesheet>

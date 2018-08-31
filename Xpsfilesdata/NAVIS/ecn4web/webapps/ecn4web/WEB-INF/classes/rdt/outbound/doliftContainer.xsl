<?xml version='1.0' encoding='utf-8'?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:template name="main">
        <xsl:param name="cheId" required="yes"/>
        <xsl:param name="msid" required="yes"/>
        <xsl:param name="formId" required="yes"/>
        <xsl:param name="pposTo" required="no"/>
        <xsl:param name="pposTo2" required="no"/>
        <xsl:param name="mode" required="no"/>
        <xsl:param name="eqId" required="yes"/>
        <xsl:param name="eqId2" required="no"/>
        <xsl:param name="lnth" required="no" select="'20'"/>
        <xsl:param name="spos" required="no">
            <xsl:choose>
                <xsl:when test="$lnth = '20'">2</xsl:when>
                <xsl:when test="$lnth = '40'">4</xsl:when>
                <xsl:otherwise>Unknown</xsl:otherwise>
            </xsl:choose>
        </xsl:param>

        <message type="2630" formId="{$formId}" MSID="{$msid}">
            <xsl:choose>
                <xsl:when test="$mode = 'TWIN' or $mode = 'SELECTOPTION_TWIN'">
                    <che CHID="{$cheId}" action="L" SPOS="T">
                        <container EQID="{$eqId}" JPOS="FWD">
                            <position PPOS="{$pposTo}"/>
                        </container>
                        <container EQID="{$eqId2}" JPOS="AFT">
                            <position PPOS="{$pposTo2}"/>
                        </container>
                    </che>
                </xsl:when>
                <xsl:otherwise>
                    <che CHID="{$cheId}" action="L" SPOS="{$spos}">
                        <container EQID="{$eqId}" JPOS="CTR"/>
                        <position PPOS="{$pposTo}" JPOS="CTR"/>
                    </che>
                </xsl:otherwise>
            </xsl:choose>
        </message>

    </xsl:template>
</xsl:stylesheet>

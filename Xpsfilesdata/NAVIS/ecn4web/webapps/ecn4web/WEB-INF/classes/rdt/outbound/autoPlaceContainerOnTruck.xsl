<?xml version='1.0' encoding='utf-8'?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:param name="cheId" required="yes"/>
    <xsl:param name="msid" required="yes"/>
    <xsl:param name="formId" required="yes"/>
    <xsl:param name="eqId" required="yes"/>
    <xsl:param name="eqId2" required="no"/>
    <xsl:param name="transport" required="yes"/>
    <xsl:param name="tkps" required="no"/>
    <xsl:param name="tkps2" required="no"/>
    <xsl:param name="mode" required="no"/>
    <xsl:template match="/">
        <message type="2630" MSID="{$msid}" formId="{$formId}">
            <che CHID="{$cheId}" action="C">
                <container EQID='{$eqId}'>
                    <position PPOS="NO_SLOT" TKPS="{$tkps}" CHID="{$transport}"/>
                </container>
                <xsl:choose>
                    <xsl:when test="$mode = 'TWIN_TRUCK'">
                        <container EQID='{$eqId2}'>
                            <position PPOS="NO_SLOT" TKPS="{$tkps2}" CHID="{$transport}"/>
                        </container>
                    </xsl:when>
                </xsl:choose>
            </che>
        </message>

    </xsl:template>
</xsl:stylesheet>

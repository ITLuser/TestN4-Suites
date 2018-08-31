<?xml version='1.0' encoding='utf-8'?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:param name="cheId" required="yes"/>
    <xsl:param name="msid" required="yes"/>
    <xsl:param name="formId" required="yes"/>
    <xsl:param name="mode" required="no"/>

    <xsl:template match="/">
        <message type="2630" formId="{$formId}" MSID="{$msid}">
            <che CHID="{$cheId}" action="L" SPOS="Unknown">
                <xsl:choose>
                    <xsl:when test="$mode = 'TWIN' or $mode = 'SELECTOPTION_TWIN'">
                        <position PPOS="NO_SLOT" JPOS="FWD"/>
                        <position PPOS="NO_SLOT" JPOS="AFT"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <position PPOS="NO_SLOT" JPOS="CTR"/>
                    </xsl:otherwise>
                </xsl:choose>
            </che>
        </message>
    </xsl:template>

</xsl:stylesheet>

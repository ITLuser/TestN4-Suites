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
        <xsl:param name="mode" required="no"/>
        <xsl:param name="eqId" required="yes"/>
        <xsl:param name="eqId2" required="no"/>

        <message type="2631" formId="{$formId}" MSID="{$msid}">
            <che CHID="{$cheId}">
                <xsl:choose>
                    <xsl:when test="$mode = 'TWIN' or $mode = 'SELECTOPTION_TWIN'">
                        <container EQID="{$eqId}" JPOS="FWD"/>
                        <container EQID="{$eqId2}" JPOS="AFT"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <container EQID="{$eqId}" JPOS="CTR"/>
                    </xsl:otherwise>
                </xsl:choose>
            </che>
        </message>

    </xsl:template>
</xsl:stylesheet>

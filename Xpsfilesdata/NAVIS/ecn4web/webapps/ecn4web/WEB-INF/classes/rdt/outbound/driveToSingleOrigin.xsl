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
        <xsl:param name="pposTo" required="yes"/>

        <message type="2630" MSID="{$msid}" formId="{$formId}">
            <che CHID="{$cheId}" action="B">
                <position PPOS="{$pposTo}"/>
            </che>
        </message>

    </xsl:template>
</xsl:stylesheet>

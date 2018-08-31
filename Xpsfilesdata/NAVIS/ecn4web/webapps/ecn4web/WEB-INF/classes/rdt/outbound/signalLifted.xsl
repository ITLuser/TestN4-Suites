<?xml version='1.0' encoding="utf-8"?>
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
    <xsl:param name="mode" required="no"/>

    <xsl:template match="/">
        <message MSID="{$msid}" type="2630" formId="{$formId}">
            <che CHID="{$cheId}" action="ecn4web:signalLifted">
                <container EQID="{$eqId}"/>
                <xsl:if test="$eqId2">
                    <container EQID="{$eqId2}"/>
                </xsl:if>
            </che>
        </message>
    </xsl:template>
</xsl:stylesheet>

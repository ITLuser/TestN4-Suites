<?xml version='1.0' encoding="utf-8"?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:param name="inputValue"/>
    <xsl:param name="cheId" required="no"/>
    <xsl:param name="locale" required="no"/>
    <xsl:param name="msid" required="yes"/>
    <xsl:template match="/">
        <message type="2609" MSID="{$msid}">
            <che CHID="{$cheId}">
                <xsl:if test="$locale">
                    <xsl:attribute name="locale" select="$locale"/>
                </xsl:if>
            </che>
        </message>

    </xsl:template>
</xsl:stylesheet>

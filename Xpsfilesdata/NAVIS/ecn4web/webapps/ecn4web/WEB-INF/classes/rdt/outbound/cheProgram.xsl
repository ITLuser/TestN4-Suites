<?xml version='1.0' encoding="utf-8"?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:param name="cheId" required="yes"/>
    <xsl:param name="msid" required="yes"/>
    <xsl:param name="formId" required="yes"/>
    <xsl:param name="inputValue"/>
    <xsl:param name="com.navis.ecn4web.login.passwordInput" required="no" select="false()"/>
    <xsl:param name="chePassword" required="no"/>
    <xsl:param name="locale" required="no"/>

    <xsl:template match="/">

        <message type="2632" MSID="{$msid}" formId="{$formId}">
            <che CHID="{$cheId}">
                <xsl:if test="$locale">
                    <xsl:attribute name="locale" select="$locale"/>
                </xsl:if>
                <user AVAL="L" LOGN="{$inputValue}" PGRM="CHE">
                    <xsl:if test="$com.navis.ecn4web.login.passwordInput = true()">
                        <xsl:attribute name="PASS">
                            <xsl:value-of select="$chePassword"/>
                        </xsl:attribute>
                    </xsl:if>
                </user>
            </che>
        </message>

    </xsl:template>
</xsl:stylesheet>

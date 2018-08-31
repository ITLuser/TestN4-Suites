<?xml version='1.0' encoding="utf-8"?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:text="http://www.navis.com/ecn4web/functions"
                exclude-result-prefixes="xs text"
                version="2.0">
    <xsl:import href="templates/common.xsl"/>
    <xsl:output method="xhtml" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
                doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" indent="yes" omit-xml-declaration="yes"
                encoding="UTF-8"/>

    <xsl:template match='/'>
        <html>
            <head>
                <xsl:call-template name="header">
                    <xsl:with-param name="pageTitle" select="text:format('title.Select_CHE')"/>
                </xsl:call-template>
            </head>
            <body>
                <form id="xmlrdtForm" name="xmlrdtForm" action='{$contextPath}/servlet/xmlrdt' method='post'
                      accept-charset="UTF-8">
                    <xsl:call-template name="message-fragment"/>
                    <div class="info-message">
                        <xsl:call-template name="instruction-message"/>
                    </div>
                    <xsl:call-template name="command-menu"/>
                    <input type="hidden" name="formId" value="{$formId}"/>
                </form>
                <xsl:call-template name="footer"/>
            </body>
        </html>
    </xsl:template>

    <xsl:template name="title">
        <xsl:param name="pageTitle"/>
        <xsl:param name="mode"/>
        <xsl:value-of
                select="concat($pageTitle, if($mode ne '') then concat(' ', text:format(concat('mode.', $mode))) else '', ' ')"/>
        <xsl:if test="$ecn4web.version">
            <xsl:value-of select="concat(' - ECN4Web ', $ecn4web.version)"/>
        </xsl:if>
        <xsl:value-of select="concat(' ', format-dateTime(xs:dateTime($timestamp), '[H01]:[m01]:[s01]'))"/>
    </xsl:template>

    <xsl:template name="instruction-message">
        <xsl:value-of select="text:format('message.Please_enter_CHE_ID')"/>
    </xsl:template>

</xsl:stylesheet>

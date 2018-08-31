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
    <!-- This template receives CHE ID from either an inbound message or set by the
        logout message handler so that the user can log in again to the same CHE.
         Initially, this parameter is passed in a query string to the start page -->
    <xsl:param name="com.navis.ecn4web.login.cheIdInput"/>
    <xsl:param name="com.navis.ecn4web.login.passwordInput" as="xs:boolean" select="true()"/>
    <xsl:variable name="mode"
                  select="if($com.navis.ecn4web.login.passwordInput eq false()) then 'NO_PASSWORD' else ''"/>

    <xsl:template match='/'>

        <html>
            <head>
                <xsl:call-template name="header">
                    <xsl:with-param name="pageTitle" select="text:format('title.Login')"/>
                </xsl:call-template>

                <script type="text/javascript">
                    window.cheId = '<xsl:value-of select="$cheId"/>';
                    window.contextPath = '<xsl:value-of select="$contextPath"/>';
                </script>
            </head>
            <body>
                <form id="xmlrdtForm" name="xmlrdtForm" action='{$contextPath}/servlet/xmlrdt' method='post'
                      accept-charset="UTF-8">
                    <xsl:call-template name="message-fragment">
                        <xsl:with-param name="mode" select="$mode"/>
                    </xsl:call-template>
                    <xsl:call-template name="app-logo"/>
                    <xsl:call-template name="command-menu">
                        <xsl:with-param name="mode" select="$mode"/>
                    </xsl:call-template>
                    <xsl:call-template name="hidden-fields"/>
                </form>
                <xsl:call-template name="footer"/>
            </body>
        </html>
    </xsl:template>

    <xsl:template name="app-logo">
        <xsl:choose>
            <xsl:when test="contains($User-Agent, 'Windows CE')">
                <img src="{$contextPath}/image/logo.jpg" alt="ECN4 Logo" class="splash-screen" width="480" height="300"/>
            </xsl:when>
            <xsl:otherwise>
                <img src="{$contextPath}/image/logo.png" alt="ECN4 Logo" class="splash-screen" width="480" height="300"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>

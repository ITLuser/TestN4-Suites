<?xml version='1.0' encoding="utf-8"?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
                xmlns:text="http://www.navis.com/ecn4web/functions"
                exclude-result-prefixes="text"
                version='2.0'>
    <xsl:import href="templates/common.xsl"/>
    <xsl:output method="xhtml" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
                doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" indent="yes" omit-xml-declaration="yes"
                encoding="UTF-8"/>
    <xsl:param name="cheId" select="/message/che/@CHID"/>

    <xsl:template match='/'>
        <html>
            <head>
                <xsl:call-template name="header">
                    <xsl:with-param name="pageTitle" select="text:format('title.REFRESH')"/>
                </xsl:call-template>
            </head>
            <body>
                <form id="xmlrdtForm" name="xmlrdtForm" action='{$contextPath}/servlet/xmlrdt' method='post'
                      accept-charset="UTF-8">
                    <xsl:call-template name="message-fragment">
                        <xsl:with-param name="formId" select="'SYSTEM_REFRESH'"/>
                    </xsl:call-template>
                    <!--<h3>
                        <xsl:value-of
                                select="text:format('message.An_error_has_occurred._Please_click_[REFRESH]._If_this_fails_continuously,_please_contact_support.')"/>
                    </h3>-->
                    <xsl:call-template name="command-menu">
                        <xsl:with-param name="formId" select="'SYSTEM_REFRESH'"/>
                        <xsl:with-param name="cheId" select="$cheId"/>
                    </xsl:call-template>
                    <input type="hidden" name="cheId" value="{$cheId}"/>
                    <input type="hidden" name="formId" value="SYSTEM_REFRESH"/>
                </form>
                <xsl:call-template name="footer"/>
            </body>
        </html>

    </xsl:template>
</xsl:stylesheet>

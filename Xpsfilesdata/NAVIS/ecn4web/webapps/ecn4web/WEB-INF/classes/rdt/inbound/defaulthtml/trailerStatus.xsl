<?xml version='1.0' encoding="utf-8"?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
                xmlns:text="http://www.navis.com/ecn4web/functions"
                exclude-result-prefixes="text"
                version='2.0'>
    <xsl:import href="templates/attributes/truck/attribute-dictionary.xsl"/>
    <xsl:import href="templates/common.xsl"/>
    <xsl:output method="xhtml" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
                doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" indent="yes" omit-xml-declaration="yes"
                encoding="UTF-8"/>

    <xsl:variable name="chassis">
        <xsl:apply-templates select="/message/che/@CHASSIS"/>
    </xsl:variable>

    <xsl:template match='/'>

        <html>
            <head>
                <xsl:call-template name="header">
                    <xsl:with-param name="pageTitle" select="text:format('title.Select_Trailer')"/>
                    <xsl:with-param name="chassis" select="$chassis" tunnel="yes"/>
                </xsl:call-template>
            </head>
            <body>
                <form id="xmlrdtForm" name="xmlrdtForm" action='{$contextPath}/servlet/xmlrdt' method='post'
                      accept-charset="UTF-8">
                    <xsl:call-template name="message-fragment"/>
                    <div class="info-message">
                        <xsl:call-template name="info-message"/>
                    </div>
                    <xsl:call-template name="command-menu"/>
                    <xsl:call-template name="hidden-fields"/>
                    <xsl:choose>
                        <xsl:when test="message/che/@dftChassis!=''">
                            <input type="hidden" name="defaultChassis" value="{message/che/@dftChassis}"/>

                         </xsl:when>
                    </xsl:choose>
                </form>
                <xsl:call-template name="footer"/>
            </body>
        </html>

    </xsl:template>

    <xsl:template name="info-message">
        <xsl:value-of select="text:format('message.Enter_trailer_status')"/>
    </xsl:template>

</xsl:stylesheet>

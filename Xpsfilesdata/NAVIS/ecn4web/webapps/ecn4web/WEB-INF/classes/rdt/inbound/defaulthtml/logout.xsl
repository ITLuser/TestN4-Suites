<?xml version='1.0' encoding="utf-8"?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl='http://www.w3.org/1999/XSL/Transform' version='2.0'>
    <!-- This screen is not in use. The logout process redirects to the login screen -->
    <xsl:output method="xhtml" indent="yes" omit-xml-declaration="yes" encoding="UTF-8"/>
    <xsl:param name="userMessage"/>
    <xsl:param name="debugInfo"/>
    <xsl:param name="xslt.device.prefix"/>
    <xsl:param name="contextPath"/>
    <xsl:variable name="cheId" select="/message/che/@CHID"/>

    <xsl:template match='/'/>

</xsl:stylesheet>

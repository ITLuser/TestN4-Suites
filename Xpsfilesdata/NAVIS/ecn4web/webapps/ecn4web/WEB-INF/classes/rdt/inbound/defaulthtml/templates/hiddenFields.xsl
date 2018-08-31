<?xml version='1.0' encoding="utf-8"?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl='http://www.w3.org/1999/XSL/Transform' version='2.0'>
    <xsl:output method="xhtml" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
                doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" indent="yes" omit-xml-declaration="yes" encoding="UTF-8"/>
    <xsl:variable name="formId" select="/message/@formId"/>
    <xsl:variable name="cheId" select="/message/che/@CHID"/>

    <xsl:template name="hidden-fields">
        <xsl:param name="mode" required="no" select="''"/>
        <input type="hidden" name="cheId" value="{$cheId}"/>
        <input type="hidden" name="formId" value="{$formId}"/>
        <input type="hidden" name="mode" value="{$mode}"/>
        <input type="hidden" name="pdsToken" value=""/>
    </xsl:template>

</xsl:stylesheet>

<?xml version='1.0' encoding="utf-8"?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
                xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:text="http://www.navis.com/ecn4web/functions"
                version='2.0'>
    <xsl:param name="locale" as="class:java.util.Locale" xmlns:class="http://saxon.sf.net/java-type"/>
    <xsl:param name="formatter" as="class:com.navis.ecn4web.util.Formatter" xmlns:class="http://saxon.sf.net/java-type"/>
    <xsl:function name="text:format" as="xs:string" exclude-result-prefixes="text Formatter"
                  xmlns:Formatter="java:com.navis.ecn4web.util.Formatter">
        <xsl:param name="key" as="xs:string"/>
        <xsl:param name="args" as="xs:string+"/>
        <xsl:value-of select="Formatter:format($formatter, $locale, $key, $args)" exclude-result-prefixes="text"/>
    </xsl:function>
    <xsl:function name="text:format" as="xs:string" exclude-result-prefixes="text Formatter"
                  xmlns:Formatter="java:com.navis.ecn4web.util.Formatter">
        <xsl:param name="key" as="xs:string"/>
        <xsl:value-of select="Formatter:format($formatter, $locale, $key)" exclude-result-prefixes="text"/>
    </xsl:function>
</xsl:stylesheet>

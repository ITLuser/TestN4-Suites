<?xml version='1.0' encoding="utf-8"?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:param name="cheId" required="yes"/>
    <xsl:param name="msid" required="yes"/>
    <xsl:param name="pdsToken" required="yes"/>

    <xsl:template match="/">
        <!--xmlrdt for serial pds messages-->
        <message MSID="{$msid}" type="2630">
            <che CHID="{$cheId}" action="Pds">
                <pds token="{$pdsToken}"/>
            </che>
        </message>

    </xsl:template>

</xsl:stylesheet>

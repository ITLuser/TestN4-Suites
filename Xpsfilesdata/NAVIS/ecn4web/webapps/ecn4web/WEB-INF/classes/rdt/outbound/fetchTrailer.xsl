<?xml version='1.0' encoding='utf-8'?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform' version='2.0'>
    <xsl:param name="cheId" required="yes"/>
    <xsl:param name="formId" required="yes"/>
    <xsl:param name="msid" required="yes"/>

    <xsl:template match='/'>

        <message type="2630" formId="{$formId}" MSID="{$msid}">
            <che CHID="{$cheId}" action="Pull"/>
        </message>

    </xsl:template>

</xsl:stylesheet>

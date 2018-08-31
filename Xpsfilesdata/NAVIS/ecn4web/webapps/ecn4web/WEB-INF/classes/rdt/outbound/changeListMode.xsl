<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="xs">
    <xsl:param name="cheId" required="yes"/>
    <xsl:param name="formId" required="yes"/>
    <xsl:param name="msid" required="yes"/>

    <xsl:template match="/">
        <message type="2727" MSID="{$msid}" formId="{$formId}">
            <che CHID="{$cheId}" action='changeListMode'/>
        </message>
    </xsl:template>

</xsl:stylesheet>

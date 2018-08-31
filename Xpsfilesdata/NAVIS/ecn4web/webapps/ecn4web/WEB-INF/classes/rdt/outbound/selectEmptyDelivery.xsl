<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="xs">

    <xsl:template match="/">
        <xsl:param name="cheId" required="yes"/>
        <xsl:param name="msid" required="yes"/>
        <xsl:param name="formId" required="yes"/>
        <xsl:param name="inputValue"/>

        <message MSID="{$msid}" type="2630" formId="{$formId}">
            <che CHID="{$cheId}" action="G">
                <container EQID="{$inputValue}"/>
            </che>
        </message>

    </xsl:template>
</xsl:stylesheet>
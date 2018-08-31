<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <!-- The logout messages is never transformed by XSLT. A logout redirects to the login template -->
    <xsl:param name="cheId" required="yes"/>
    <xsl:param name="msid" required="yes"/>
    <xsl:param name="formId" required="yes"/>
    <xsl:template match="/">

        <message MSID="{$msid}" type="2632" formId="{$formId}">
            <che CHID="{$cheId}">
                <user AVAL="X"/>
            </che>
        </message>

    </xsl:template>
</xsl:stylesheet>

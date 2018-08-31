<?xml version='1.0' encoding='utf-8'?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:template name="main">
        <xsl:param name="cheId" required="yes"/>
        <xsl:param name="msid" required="yes"/>
        <xsl:param name="formId" required="yes"/>
        <xsl:param name="mode" required="no"/>
        <xsl:param name="truckId" required="yes"/>

        <message type="2633" formId="{$formId}" MSID="{$msid}">
            <che CHID="{$cheId}">
                <position PPOS='NO_SLOT' CHID="{$truckId}" JPOS='CTR'/>
            </che>
        </message>

    </xsl:template>
</xsl:stylesheet>

<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <!-- This template is never called directly, only by forward or backward pagination actions -->

    <xsl:template name="main">

        <xsl:param name="cheId" required="yes"/>
        <xsl:param name="pivot" required="yes"/>
        <xsl:param name="maxPageItems" required="yes"/>
        <xsl:param name="paginationOperator" select="''" required="no"/>
        <xsl:param name="formId" required="yes"/>
        <xsl:param name="msid" required="yes"/>
        <xsl:param name="optionListName" required="yes"/>

        <xsl:variable name="size">
            <xsl:choose>
                <xsl:when test="$paginationOperator = '-'">
                    <xsl:value-of select="-number($maxPageItems)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$maxPageItems"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <message type="2727" MSID="{$msid}" formId="{$formId}">
            <che CHID="{$cheId}">
                <option-list name="{$optionListName}" pivot="{$pivot}" size="{$size}"/>
            </che>
        </message>

    </xsl:template>

</xsl:stylesheet>

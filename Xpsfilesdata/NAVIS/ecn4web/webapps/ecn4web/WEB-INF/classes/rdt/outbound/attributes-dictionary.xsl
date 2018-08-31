<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template name="tier-index-format">
        <xsl:param name="pposTo"/>
        <xsl:param name="tier-index-number"/>
        <xsl:variable name="ppos-value">
            <xsl:choose>
                <xsl:when test="contains($pposTo, '.')">
                    <xsl:value-of select="substring-before($pposTo, '.')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$pposTo"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="concat($ppos-value, '.', translate(string($tier-index-number), '12', 'AB'))"/>
    </xsl:template>
</xsl:stylesheet>

<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href="doDropContainer.xsl"/>
    <xsl:import href="attributes-dictionary.xsl"/>

    <xsl:param name="cheId" required="yes"/>
    <xsl:param name="formId" required="yes"/>
    <xsl:param name="msid" required="yes"/>
    <xsl:param name="pposTo1" required="yes"/>
    <xsl:param name="pposTo2" required="no"/>
    <xsl:param name="jpos1" required="no"/>
    <xsl:param name="jpos2" required="no"/>
    <xsl:param name="tier" required="yes"/>

    <xsl:template match="/">
        <xsl:call-template name="main">
            <xsl:with-param name="cheId" select="$cheId"/>
            <xsl:with-param name="formId" select="$formId"/>
            <xsl:with-param name="msid" select="$msid"/>
            <xsl:with-param name="jpos1" select="$jpos1"/>
            <xsl:with-param name="jpos2" select="$jpos2"/>
            <xsl:with-param name="pposTo1">
                <xsl:call-template name="tier-index-format">
                    <xsl:with-param name="tier-index-number" select="$tier"/>
                    <xsl:with-param name="pposTo" select="$pposTo1"/>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="pposTo2">
                <xsl:choose>
                    <xsl:when test="$pposTo2">
                        <xsl:call-template name="tier-index-format">
                            <xsl:with-param name="tier-index-number" select="$tier"/>
                            <xsl:with-param name="pposTo" select="$pposTo2"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>

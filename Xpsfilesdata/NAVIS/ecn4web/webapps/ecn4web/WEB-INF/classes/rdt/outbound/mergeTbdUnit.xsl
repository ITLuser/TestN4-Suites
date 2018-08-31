<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:param name="cheId" required="yes"/>
    <xsl:param name="formId" required="yes"/>
    <xsl:param name="msid" required="yes"/>
    <xsl:param name="inputValue" required="no"/>
    <xsl:param name="inputValue2" required="no"/>
    <xsl:param name="eqId" required="yes"/>
    <xsl:param name="eqId2" required="no"/>

    <xsl:template match="/">

        <message MSID="{$msid}" type="2630" formId="{$formId}">
            <che CHID="{$cheId}" action="G">
                <xsl:choose>
                    <xsl:when test="$inputValue and $inputValue2">
                        <container EQID="{$inputValue}">
                            <tbdunit EQID="{$eqId}"/>
                        </container>
                        <container EQID="{$inputValue2}">
                            <tbdunit EQID="{$eqId2}"/>
                        </container>
                    </xsl:when>
                    <xsl:when test="$inputValue2 and not($inputValue)">
                        <container EQID="{$inputValue2}"/>
                        <tbdunit EQID="{$eqId2}"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <container EQID="{$inputValue}"/>
                        <tbdunit EQID="{$eqId}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </che>
        </message>

    </xsl:template>

</xsl:stylesheet>

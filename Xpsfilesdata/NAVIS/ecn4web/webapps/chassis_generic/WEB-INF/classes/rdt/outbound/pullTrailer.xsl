<?xml version='1.0' encoding='utf-8'?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform' version='2.0' xmlns:xs="http://www.w3.org/2001/XMLSchema">
    <xsl:param name="cheId" required="yes"/>
    <xsl:param name="formId" required="yes"/>
    <xsl:param name="msid" required="yes"/>
    <xsl:param name="index" required="yes"/>
    <xsl:param name="inputValue" required="no"/>

    <xsl:template match='/'>
        <!-- Deserialize unit/container info passed from form, to enable index lookup.
          The format expected is: 1:TEST0000001:AA23:Yard, ... -->
        <xsl:variable name="unit-nodes" as="node()*">
            <xsl:call-template name="get-unit-nodes"/>
        </xsl:variable>

        <message type="2630" formId="{$formId}" MSID="{$msid}">
            <che CHID="{$cheId}" action="Pull">
                <xsl:for-each select="$unit-nodes">

                    <xsl:if test="@pullable!= ''">
                        <xsl:variable name="elementName" as="xs:string">
                            <xsl:choose>
                                <xsl:when test="contains(@unit-type, 't')">tbdunit</xsl:when>
                                <xsl:when test="contains(@unit-type, 'x')">position</xsl:when>
                                <xsl:otherwise>container</xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="contains(@unit-type, 'x')">
                                <xsl:variable name="EqId" select="if($inputValue) then $inputValue else @id"/>
                                <xsl:element name="{$elementName}">
                                    <xsl:attribute name="CHASSIS">
                                        <xsl:value-of select="$EqId"/>
                                    </xsl:attribute>
                                    <xsl:if test="upper-case(@pullable) = 'Y'">
                                        <xsl:attribute name="PPOS">
                                            <xsl:value-of select="@pposTo"/>
                                        </xsl:attribute>
                                    </xsl:if>
                                </xsl:element>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:element name="{$elementName}">
                                    <xsl:attribute name="EQID">
                                        <xsl:value-of select="@id"/>
                                    </xsl:attribute>
                                    <xsl:if test="upper-case(@pullable) = 'Y'">
                                        <position PPOS="{@pposTo}"/>
                                    </xsl:if>
                                </xsl:element>
                            </xsl:otherwise>
                        </xsl:choose>

                    </xsl:if>
                </xsl:for-each>
            </che>
        </message>

    </xsl:template>

    <!-- Deserialize to abstract xml unit elements, so they can be queried using XPath -->
    <xsl:template name="get-unit-nodes" as="node()*">
        <xsl:for-each select="tokenize($index, ',')">
            <xsl:variable name="unit-attributes" select="tokenize(.,':')"/>
            <unit index="{$unit-attributes[1]}" id="{$unit-attributes[2]}" jpos="{$unit-attributes[3]}" pposTo="{$unit-attributes[4]}"
                  pullable="{$unit-attributes[5]}" unit-type="{$unit-attributes[6]}"/>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>


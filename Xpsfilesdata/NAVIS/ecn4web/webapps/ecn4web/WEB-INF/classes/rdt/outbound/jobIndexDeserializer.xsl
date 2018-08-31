<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:param name="cheId" required="yes"/>
    <xsl:param name="formId" required="yes"/>
    <xsl:param name="msid" required="yes"/>
    <xsl:param name="inputValue" required="no"/>
    <xsl:param name="index" required="no"/>
    <xsl:param name="totalCount" select="1" required="no"/>
    <xsl:param name="unitType" required="no"/>
    <xsl:param name="tbdEqId" required="no"/>

    <xsl:template match="/">
        <!-- Deserialize unit/container info passed from form, to enable index lookup.
            The format expected is: 1:TEST0000001:container, ... -->
        <xsl:variable name="unit-nodes">
            <xsl:call-template name="get-unit-nodes"/>
        </xsl:variable>
        <xsl:variable name="unit-element">
            <xsl:choose>
                <!-- No index lookup when dispatching from Idle, no index is passed in -->
                <xsl:when test="not($index)">
                    <che CHID="{$cheId}" action="A">
                        <container EQID="{$inputValue}"/>
                    </che>
                </xsl:when>
                <!-- Use as index if less than 5 characters and within the range of unit indices on page.
                     Letter characters will fail -->
                <xsl:when test="string-length(string($inputValue)) &lt; 5 and
                    ($inputValue &gt;= number(xalan:nodeset($unit-nodes)/unit[position() = 1]/@index) and $inputValue &lt;= number(xalan:nodeset($unit-nodes)/unit[position() = last()]/@index))">
                    <xsl:variable name="action">
                        <xsl:choose>
                            <xsl:when test="xalan:nodeset($unit-nodes)/unit[@index = $inputValue and @type = 'container']">A</xsl:when>
                            <xsl:otherwise>P</xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <che CHID="{$cheId}" action="{$action}">
                        <xsl:element name="{xalan:nodeset($unit-nodes)/unit[@index = $inputValue]/@type}">
                            <xsl:attribute name="EQID">
                                <xsl:value-of select="xalan:nodeset($unit-nodes)/unit[@index = $inputValue]/@id"/>
                            </xsl:attribute>
                        </xsl:element>
                    </che>
                </xsl:when>
                <!-- If not an index, send the input to ECN4 whether its partial or not -->
                <xsl:otherwise>
                    <che CHID="{$cheId}" action="A">
                        <container EQID="{$inputValue}"/>
                    </che>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <message MSID="{$msid}" type="2630" formId="{$formId}">
            <xsl:copy-of select="$unit-element"/>
        </message>

    </xsl:template>

    <!-- Deserialize to abstract xml unit elements, so they can be queried using XPath -->
    <xsl:template name="get-unit-nodes">
        <xsl:for-each select="tokenize($index, ',')">
            <xsl:variable name="unit-attributes" select="tokenize(.,':')"/>
            <unit index="{$unit-attributes[1]}" id="{$unit-attributes[2]}" type="{$unit-attributes[3]}"/>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>

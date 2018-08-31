<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="xs">

    <xsl:template name="main">

        <xsl:param name="cheId" required="yes"/>
        <xsl:param name="msid" required="yes"/>
        <xsl:param name="formId" required="yes"/>
        <xsl:param name="mode" required="no"/>
        <xsl:param name="inputValue"/>
        <xsl:param name="inputValue2" required="no"/>
        <xsl:param name="index" as="xs:string" required="yes"/>
        <xsl:param name="totalCount" select="1" required="no"/>
        <xsl:param name="selectTarget" required="no"/>

        <!-- Deserialize unit/container info passed from form, to enable index lookup.
            The format expected is: 1:TEST0000001:container, ... -->
        <xsl:variable name="unit-nodes" as="node()*">
            <xsl:call-template name="get-unit-nodes">
                <xsl:with-param name="index" select="$index"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="unit-element" as="node()*">
            <xsl:choose>
                <!-- No index lookup when dispatching from Idle, no index is passed in -->
                <xsl:when test="not($index)">
                    <xsl:variable name="rdtAction" as="xs:string">
                        <xsl:choose>
                            <xsl:when test="$selectTarget = 'inventory'">M</xsl:when>
                            <xsl:otherwise>A</xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <che CHID="{$cheId}" action="{$rdtAction}">
                        <xsl:choose>
                            <xsl:when test="$mode = 'TWIN' or $mode = 'SELECTOPTION_TWIN' or $mode = 'TWIN_TRUCK'">
                                <container EQID="{$inputValue}"/>
                                <container EQID="{$inputValue2}"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <container EQID="{$inputValue}"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </che>
                </xsl:when>
                <!-- Use as index if less than 5 characters and within the range of unit indices on page. Letter characters will fail -->
                <xsl:when test="string-length(string($inputValue)) &lt; 5 and
                    (number($inputValue) &gt;= number($unit-nodes[position() = 1]/@index) and number($inputValue) &lt;= number($unit-nodes[position() = last()]/@index))">
                    <xsl:variable name="rdtAction" as="xs:string">
                        <xsl:choose>
                            <xsl:when test="$selectTarget = 'inventory'">M</xsl:when>
                            <xsl:when test="$unit-nodes[@index = $inputValue and @type = 'c']">A</xsl:when>
                            <xsl:when test="$unit-nodes[@index = $inputValue and @type = 't']">A</xsl:when>
                            <xsl:when test="$unit-nodes[@index = $inputValue and @type = 'e']">SelectEmptyDeliveryJob</xsl:when>
                            <xsl:otherwise>P</xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="elementName" as="xs:string">
                        <xsl:choose>
                            <xsl:when test="$unit-nodes[@index = $inputValue]/@type = 't'">tbdunit</xsl:when>
                            <xsl:otherwise>container</xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="eqId" select="$unit-nodes[@index = $inputValue]/@id" as="xs:string"/>
                    <che CHID="{$cheId}" action="{$rdtAction}">

                        <xsl:choose>
                            <xsl:when test="$mode = 'TWIN' or $mode = 'SELECTOPTION_TWIN'">
                                <xsl:element name="{$elementName}">
                                    <xsl:attribute name="EQID">
                                        <xsl:value-of select="$unit-nodes[@index = $inputValue]/@id"/>
                                    </xsl:attribute>
                                </xsl:element>
                                <xsl:element name="{$elementName}">
                                    <xsl:attribute name="EQID">
                                        <xsl:value-of select="$unit-nodes[@index = $inputValue2]/@id"/>
                                    </xsl:attribute>
                                </xsl:element>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:element name="{$elementName}">
                                    <xsl:attribute name="EQID">
                                        <xsl:value-of select="$unit-nodes[@index = $inputValue]/@id"/>
                                    </xsl:attribute>
                                </xsl:element>
                            </xsl:otherwise>
                        </xsl:choose>
                    </che>
                </xsl:when>
                <!-- If not an index, send the input to ECN4 whether its partial or not -->
                <xsl:otherwise>
                    <xsl:variable name="rdtAction" as="xs:string">
                        <xsl:choose>
                            <xsl:when test="$selectTarget = 'inventory'">M</xsl:when>
                            <xsl:when test="$unit-nodes[@id = $inputValue and @type = 'e']">SelectEmptyDeliveryJob</xsl:when>
                            <xsl:otherwise>A</xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="elementName" as="xs:string">
                        <xsl:choose>
                            <xsl:when test="$unit-nodes[@id = $inputValue]/@type = 't'">tbdunit</xsl:when>
                            <xsl:otherwise>container</xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <che CHID="{$cheId}" action="{$rdtAction}">
                        <xsl:choose>
                            <xsl:when test="$mode = 'TWIN' or $mode = 'SELECTOPTION_TWIN' or $mode = 'TWIN_TRUCK'">
                                <xsl:element name="{$elementName}">
                                    <xsl:attribute name="EQID">
                                        <xsl:value-of select="$inputValue"/>
                                    </xsl:attribute>
                                </xsl:element>
                                <xsl:if test="$inputValue2">
                                    <xsl:element name="{$elementName}">
                                        <xsl:attribute name="EQID">
                                            <xsl:value-of select="$inputValue2"/>
                                        </xsl:attribute>
                                    </xsl:element>
                                </xsl:if>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:element name="{$elementName}">
                                    <xsl:attribute name="EQID">
                                        <xsl:value-of select="$inputValue"/>
                                    </xsl:attribute>
                                </xsl:element>
                            </xsl:otherwise>
                        </xsl:choose>
                    </che>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <message MSID="{$msid}" type="2630" formId="{$formId}">
            <xsl:copy-of select="$unit-element"/>
        </message>

    </xsl:template>

    <!-- Deserialize to abstract xml unit elements, so they can be queried using XPath 1:TBD_000001:t-->
    <xsl:template name="get-unit-nodes" as="node()*">
        <xsl:param name="index" as="xs:string"/>
        <xsl:for-each select="tokenize($index, ',')">
            <xsl:variable name="unit-attributes" select="tokenize(.,':')"/>
            <unit index="{$unit-attributes[1]}" id="{$unit-attributes[2]}" type="{$unit-attributes[3]}"/>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text"/>

    <xsl:template match="/">
        <xsl:apply-templates select="/form-list/form"/>
        <xsl:value-of select="'FORM.PDS=pdsMessage'"/>
    </xsl:template>

    <xsl:template match="form[@enabled != 'false' or empty(@enabled)]">
        <xsl:variable name="id" select="@id"/>
        <xsl:variable name="qualifiedFormName">
            <xsl:value-of select="replace(@id, '([: ])', '\\$1')"/>
            <xsl:if test="@mode != ''">
                <xsl:value-of select="concat('.', @mode)"/>
            </xsl:if>
        </xsl:variable>

        <xsl:if test="not(@async) or @async = 'true'">
            <xsl:value-of select="concat(string-join(($qualifiedFormName, 'async=async'), '.'), '&#x0a;')"/>
        </xsl:if>
        <xsl:if test="@default">
            <xsl:value-of select="concat(string-join(($qualifiedFormName,  'default'), '.'), '=', @default, '&#x0a;')"/>
        </xsl:if>
        <xsl:for-each select="command">
            <xsl:value-of select="concat(string-join(($qualifiedFormName, @index), '.'), '=', @template, '&#x0a;')"/>
        </xsl:for-each>
        <xsl:choose>
            <!--if this is true, it means the current form inherits some commands from the parent form-->
            <xsl:when test="@inheritFrom">
                <!--Create a list of the command indexes in the child form like 1:2:3-->
                <xsl:variable name="childFormCommandIndexList">
                    <xsl:apply-templates select="command"/>
                </xsl:variable>
                <xsl:variable name="parentForm" select="parent::form-list/form[@id = $id and @mode = '']" as="node()*"/>
                <xsl:for-each select="$parentForm/command">
                    <xsl:choose>
                        <xsl:when test="contains($childFormCommandIndexList, @index)">
                            <!--Do nothing, command already overridden in child form so we don't need parent form command-->
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat(string-join(($qualifiedFormName, @index), '.'), '=', @template, '&#x0a;')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
                <xsl:text/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="command">
        <xsl:value-of select="concat(@index,':')"/>
    </xsl:template>
</xsl:stylesheet>

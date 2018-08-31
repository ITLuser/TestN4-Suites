<?xml version='1.0' encoding='utf-8'?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<!--Second level transformation for Wince (IE 6.0) devices. This transformation targets slow device like LXE (VX6, VX7).-->
<xsl:stylesheet xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="xs xhtml"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xml:space="default"
                version="2.0">
    <xsl:output method="html" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
                doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" indent="yes" omit-xml-declaration="yes" encoding="UTF-8"/>

    <xsl:variable name="longest-command" as="xs:integer">
        <xsl:call-template name="get-longest-command"/>
    </xsl:variable>
    <xsl:variable name="inputfield-count-per-command" as="xs:integer">
        <xsl:call-template name="inputfield-count"/>
    </xsl:variable>
    <xsl:variable name="left-offset">
        <xsl:choose>
            <xsl:when test="$inputfield-count-per-command >= 2">180px</xsl:when>
            <xsl:when test="$longest-command > 14">310px</xsl:when>
            <xsl:otherwise>250px</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="input-field-ids">
        <xsl:call-template name="get-input-field-ids"/>
    </xsl:variable>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="xhtml:ul[ancestor::xhtml:fieldset[contains(@class,'button enabled')]]">
        <ul style="position: relative; left: {$left-offset}; top: 0px;">
            <xsl:apply-templates select="xhtml:li"/>
        </ul>
    </xsl:template>

    <xsl:template match="xhtml:fieldset[@class='button enabled' or @class = 'command-legend' or @class='button enabled long-button']">
        <xsl:variable name="fieldset" select="."/>
        <xsl:variable name="actionId" select="$fieldset/descendant::xhtml:a/@id"/>
        <fieldset class="{$fieldset/@class}" onclick="submitCommand('{$actionId}')">
            <xsl:apply-templates select="./@*|node()"/>
        </fieldset>
    </xsl:template>

    <xsl:template match="xhtml:a[contains(@class, 'button enabled message-fragment')]">
        <a class='{@class}' id='{@id}' onclick="submitCommand('{@id}')">
            <xsl:apply-templates select="./@*|node()"/>
        </a>
    </xsl:template>

    <xsl:template match="xhtml:div[contains(@class, 'button enabled message-fragment')]">
        <div class='{@class}' id='{@id}' onclick="submitCommand('{@id}')">
            <xsl:apply-templates select="./@*|node()"/>
        </div>
    </xsl:template>

    <xsl:template match="xhtml:input[@type='text' or @type='password']">
        <xsl:variable name="anchorId" select="ancestor::xhtml:fieldset/descendant::xhtml:a/@id"/>
        <xsl:variable name="label" select="parent::xhtml:li/xhtml:label/xhtml:span" as="xs:string"/>
        <xsl:variable name="value" as="xs:string">
            <xsl:choose>
                <xsl:when test="@value">
                    <xsl:value-of select="@value"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$label"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="class">
            <xsl:choose>
                <xsl:when test="$value = $label">
                    <xsl:value-of select="'field labeled'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'field'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <input name="{@name}"
               id="{@id}"
               maxlength="{@maxlength}"
               size="{@size}"
               class="{$class}"
               type="{@type}"
               value="{$value}"
               title="{$anchorId}" onblur="blurInputValue('{@id}','{$label}')" onfocus="focusInputValue('{@id}','{$label}')"
               onkeypress="submitInputField('{$anchorId}')" onclick="doNothing()" onmousedown="stopEventPropagation()"/>
    </xsl:template>

    <xsl:template match="xhtml:form">
        <form>
            <xsl:apply-templates select="@*|node()"/>
        </form>
        <xsl:call-template name="set-focus"/>
    </xsl:template>

    <xsl:template match="xhtml:a[@class = 'button enabled' and ancestor::xhtml:fieldset[@class = 'pagination'  or @class = 'pagination-no-border']]">
        <a href='{@href}' class='{@class}' id='{@id}' onclick="submitCommand('{@id}')">
            <xsl:value-of select="."/>
        </a>
    </xsl:template>

    <xsl:template match="xhtml:a[@class = 'button enabled' and ancestor::xhtml:div[@class = 'footer']]">
        <a href='{@href}' class='{@class}' id='{@id}' onclick="submitCommand('{@id}')">
            <xsl:value-of select="."/>
        </a>
    </xsl:template>

    <xsl:template match="xhtml:tr[@class ='button']">
        <xsl:variable name="actionId" select="//xhtml:input[@name='action']/@value"/>
        <xsl:variable name="target">
            <xsl:call-template name="find-target">
                <xsl:with-param name="actionId" select="$actionId"/>
            </xsl:call-template>
        </xsl:variable>
        <tr class="{@class}" id="{@id}" onclick="submitJob('{@id}','{$target}')">
            <xsl:apply-templates select="./@*|node()"/>
        </tr>
    </xsl:template>

    <xsl:template name="get-input-field-ids">
        <xsl:variable name="apos" select='"&apos;"'/>
        <xsl:for-each select="//xhtml:input[@type = 'text']">
            <xsl:if test="position() = 1">
                <xsl:value-of select="'['"/>
            </xsl:if>
            <xsl:value-of select="concat($apos , @id, $apos)"/>
            <xsl:if test="position() != last()">
                <xsl:value-of select="', '"/>
            </xsl:if>
            <xsl:if test="position() = last()">
                <xsl:value-of select="']'"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="set-focus">
        <xsl:variable name="actionId" select="//xhtml:input[@name='action']/@value"/>
        <xsl:comment>
            <xsl:value-of select="$actionId"/>
        </xsl:comment>
        <xsl:variable name="target">
            <xsl:call-template name="find-target">
                <xsl:with-param name="actionId" select="$actionId"/>
            </xsl:call-template>
        </xsl:variable>
        <script type="text/javascript">
            var inputFieldIds = <xsl:value-of select="if($input-field-ids != '') then $input-field-ids else '[]'"/>;
            var id = '<xsl:value-of select="if ($target != '') then $target else '1'"/>';
            var element = document.getElementById(id);
            if (element.nodeName.toLowerCase() === 'input') {
            if (element.type === 'text'){
            element.value = '';
            element.className = "field";
            }
            }
            element.focus();
        </script>
    </xsl:template>

    <xsl:template name="find-target">
        <xsl:param name="actionId" required="yes"/>
        <xsl:variable name="anchor" select="//xhtml:a[@id = $actionId]"/>
        <xsl:variable name="inputId" select="$anchor/ancestor::xhtml:fieldset/descendant::xhtml:input[1]/@id"/>
        <xsl:variable name="value">
            <xsl:choose>
                <xsl:when test="$inputId">
                    <xsl:value-of select="$inputId"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$anchor/@id"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="$value"/>
    </xsl:template>

    <xsl:template name="get-longest-command">
        <xsl:for-each select="//xhtml:fieldset[@class = 'button enabled']/descendant::xhtml:a">
            <xsl:sort select="string-length(.)" order="descending"/>
            <xsl:if test="position() = 1">
                <xsl:value-of select="string-length(.)"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="inputfield-count">
        <xsl:variable name="commands" select="//xhtml:div[@class = 'commands']"/>
        <xsl:for-each select="$commands/descendant::xhtml:ul">
            <xsl:sort select="count(xhtml:li)" order="descending"/>
            <xsl:if test="position() = 1">
                <xsl:value-of select="count(xhtml:li)"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="xhtml:meta">
    </xsl:template>

</xsl:stylesheet>

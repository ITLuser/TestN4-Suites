<?xml version='1.0' encoding='utf-8'?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<!--This is an adapter template used as a second level transformation for narrow-band devices.
The initial xhtml output is transformed to a simpler html that can be rendered by narrow-band (TESS) devices-->
<!DOCTYPE xsl:stylesheet [<!ENTITY nbsp '&#160;'>]>
<xsl:stylesheet xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns="http://www.w3.org/1999/html"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="xs xhtml xsl"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xml:space="default"
                version="2.0">

    <xsl:output method="xhtml" encoding="utf-8" omit-xml-declaration="yes" indent="yes"/>

    <!--Entry point to adapter template-->
    <xsl:template match="xhtml:html">
        <xsl:copy>
            <xsl:apply-templates select="xhtml:head"/>
            <xsl:apply-templates select="xhtml:body"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="xhtml:head">
        <xsl:copy>
            <!--copy title and comment. Java script variables and css links ignored (TESS doesn't support JS and CSS)-->
            <xsl:apply-templates select="xhtml:title|comment()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="xhtml:body">
        <xsl:copy>
            <xsl:apply-templates select="xhtml:form"/>
        </xsl:copy>
    </xsl:template>

    <!--Copy the form and extract all the required information from the form.-->
    <xsl:template match="xhtml:form">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <!--Generating command fields-->
            <xsl:call-template name="command-fields"/>
            <!--Error or User message-->
            <xsl:apply-templates select="xhtml:div"/>
            <!--Pagination form commands-->
            <xsl:apply-templates select="xhtml:fieldset" mode="pagination"/>
            <!--Job list and Unit detail-->
            <xsl:apply-templates select="//xhtml:table"/>
            <!--Reroute complete to command-->
            <xsl:apply-templates select="xhtml:fieldset/xhtml:div[@class='pad']"/>
            <!--form commands-->
            <xsl:apply-templates select="xhtml:div[@class='commands']/xhtml:fieldset" mode="command"/>
            <br xmlns="http://www.w3.org/1999/xhtml"/>
            <!--footer form commands-->
            <xsl:apply-templates select="xhtml:div[@class='footer']/descendant::xhtml:a"/>
            <!--Clear command-->
            <xsl:apply-templates select="xhtml:div" mode="command"/>
            <!--Hidden fields-->
            <xsl:apply-templates select="//xhtml:input[@type='hidden']"/>

        </xsl:copy>
    </xsl:template>

    <!--Copy all the hidden fields except 'async'.-->
    <xsl:template match="xhtml:input[@type='hidden']">
        <xsl:choose>
            <!--Please remove the value 'async' from the condition below if and when TESS starts supporting push functionality (can happen in 2020)-->
            <xsl:when test="@name != 'async'">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                </xsl:copy>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!--Creating input fields-->
    <xsl:template match="xhtml:input[@type='text' or @type='password']">
        <input name="{@name}"
               maxlength="{@maxlength}"
               size="{@size}"
               type="{@type}"
               value="{@value}"
               xmlns="http://www.w3.org/1999/xhtml"
                />
    </xsl:template>

    <!--copy page title. Only Form name and CHE id is copied. This is done to save some space as TESS devices have limited screen size-->
    <xsl:template match="xhtml:title">
        <xsl:copy>
            <xsl:value-of select="normalize-space(substring-before(.,'- ECN4Web'))"/>
        </xsl:copy>
    </xsl:template>

    <!--Copy comment, useful to copy message id for debugging purposes-->
    <xsl:template match="comment()">
        <xsl:comment>
            <xsl:value-of select="."/>
        </xsl:comment>
    </xsl:template>

    <!--A template to create the command fields.An example of command with one input-field looks like this:
    CMD:__ ________[SUBMIT]-->
    <xsl:template name="command-fields">
        CMD:
        <input id="action" name="action" size="2" maxlength="2" value="" type="text"
               TEKFLAGS="CA" xmlns="http://www.w3.org/1999/xhtml"/>
        <xsl:call-template name="generate-input-fields"/>
        <input xmlns="http://www.w3.org/1999/xhtml" id="submit" name="generic" value="SUBMIT" class="submit" FKEY="0" type="submit"/>
        <br xmlns="http://www.w3.org/1999/xhtml"/>
    </xsl:template>

    <xsl:template match="xhtml:fieldset" mode="input">
        <xsl:apply-templates select="descendant::xhtml:input"/>
    </xsl:template>

    <xsl:template match="xhtml:fieldset" mode="command">
        <xsl:apply-templates select="descendant::xhtml:a" mode="command"/>
        <xsl:apply-templates select="descendant::xhtml:label"/>
        <br xmlns="http://www.w3.org/1999/xhtml"/>
    </xsl:template>

    <!--This template is used to create "complete to" command in reroute page.
     The reroute form has unique design thus the template below is used to generate (copy) the commands.-->
    <xsl:template match="xhtml:fieldset[@class='command-legend']" mode="pagination">
        <xsl:value-of select="concat(descendant::xhtml:a/@id,':',substring(descendant::xhtml:a/.,1,12))"/>
        <xsl:apply-templates select="descendant::xhtml:label"/>
        <xsl:for-each select="xhtml:div['pad']">
            <br xmlns="http://www.w3.org/1999/xhtml"/>
            <xsl:value-of select="'-'"/>
            <xsl:apply-templates select="descendant::xhtml:span"/>
            <xsl:apply-templates select="descendant::xhtml:input"/>
        </xsl:for-each>
        <br xmlns="http://www.w3.org/1999/xhtml"/>
    </xsl:template>

    <xsl:template match="xhtml:span[@class='inline']">
        <xsl:value-of select="concat(' ', ., ':')"/>
    </xsl:template>

    <!--A template to generate pagination buttons.-->
    <xsl:template match="xhtml:fieldset" mode="pagination">
        <br xmlns="http://www.w3.org/1999/xhtml"/>
        <u xmlns="http://www.w3.org/1999/xhtml">
            <xsl:value-of select="concat(descendant::xhtml:a[1]/@id, ':', descendant::xhtml:a[1]/xhtml:abbr/@title)"/>
        </u>
        <b xmlns="http://www.w3.org/1999/xhtml">
            <xsl:value-of select="concat(' ',descendant::xhtml:em, ' ')"/>
        </b>
        <u xmlns="http://www.w3.org/1999/xhtml">
            <xsl:value-of select="concat(descendant::xhtml:a[2]/@id, ':', descendant::xhtml:a[2]/xhtml:abbr/@title, ' ')"/>
            <br xmlns="http://www.w3.org/1999/xhtml"/>
            <xsl:if test="descendant::xhtml:a[3]">
                <xsl:apply-templates select="descendant::xhtml:a[3]" mode="command"/>
                <xsl:apply-templates select="descendant::xhtml:a[4]" mode="command"/>
            </xsl:if>
        </u>
        <br xmlns="http://www.w3.org/1999/xhtml"/>
    </xsl:template>

    <xsl:template match="xhtml:label">
        <xsl:value-of select="concat('[',.,']')"/>
    </xsl:template>

    <!--copy enabled button-->
    <xsl:template match="xhtml:a[@class='button enabled']" mode="command">
        <xsl:value-of select="concat(@id , ':',.,' ')"/>
    </xsl:template>

    <!--copy disabled button-->
    <xsl:template match="xhtml:a[@class='button disabled']" mode="command">
        <!--Mark disabled button with '_' to indicate it is disabled.-->
        <xsl:value-of select="concat('_:',.,' ')"/>
    </xsl:template>

    <xsl:template match="xhtml:a">
        <xsl:apply-templates select="." mode="command"/>
        <xsl:value-of select="' '"/>
    </xsl:template>

    <!--Copy user message. Note that only a substring of 116 characters is copied to save space.-->
    <xsl:template match="xhtml:div[@class='button enabled message-fragment message' or @class='button enabled message-fragment cheMessage']">
        <xsl:variable name="userMessage" select="."/>
        <b xmlns="http://www.w3.org/1999/xhtml">
            <xsl:value-of select="substring($userMessage, 1, 116)"/>
            <xsl:if test="string-length($userMessage) &gt; 116">...</xsl:if>
        </b>
        <br xmlns="http://www.w3.org/1999/xhtml"/>
    </xsl:template>
    <!--Add 'Clear message' command if there is an error message, the command is used to clear the error message-->
    <xsl:template match="xhtml:div[@class='button enabled message-fragment message' or @class='button enabled message-fragment cheMessage']"
                  mode="command">
        <xsl:if test="@id != ''">
            <xsl:value-of select="concat(' ',@id,':Clear message')"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="xhtml:div[@class='data']">
        <xsl:apply-templates select="descendant::xhtml:div"/>
        <br xmlns="http://www.w3.org/1999/xhtml"/>
    </xsl:template>

    <xsl:template match="xhtml:div[@class='info-message']">
        <xsl:value-of select="."/>
        <br xmlns="http://www.w3.org/1999/xhtml"/>
        <br xmlns="http://www.w3.org/1999/xhtml"/>
    </xsl:template>

    <xsl:template match="xhtml:div[@class='line-item']">
        <xsl:apply-templates select="node()"/>
        <br xmlns="http://www.w3.org/1999/xhtml"/>
    </xsl:template>

    <xsl:template match="xhtml:br">
        <xsl:if test="position() != last()">
            <xsl:copy/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="xhtml:table[contains(@class, 'data')]">
        <xsl:apply-templates select="descendant::xhtml:tr"/>
    </xsl:template>
    <!--copy table rows, remove rows which contain label names but no value associated to them (again this is done to save some space).-->
    <xsl:template match="xhtml:tr">
        <xsl:variable name="labels" as="xs:string">
            <xsl:value-of select="descendant::xhtml:td[@class='label']/."/>
        </xsl:variable>
        <xsl:variable name="values" as="xs:string">
            <xsl:value-of select="descendant::xhtml:td[@class='value']/."/>
        </xsl:variable>
        <xsl:if test="not(contains(descendant::xhtml:td[@class='label'][1],'Prefix:'))">
            <xsl:if test="$labels = '' or ($labels != '' and ($values != '' and $values != ' '))">
                <xsl:value-of select="'- '"/>
            </xsl:if>
            <xsl:apply-templates select="descendant::xhtml:td"/>
            <xsl:if test="@class='button promotedJob'">
                <xsl:value-of select="'*'"/>
            </xsl:if>
            <xsl:if test="$labels = '' or ($labels != '' and ($values != '' and $values != ' '))">
                <br xmlns="http://www.w3.org/1999/xhtml"/>
            </xsl:if>
        </xsl:if>
        <xsl:if test="position() eq last()">
            <br xmlns="http://www.w3.org/1999/xhtml"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="xhtml:td">
        <xsl:choose>
            <xsl:when test="contains(.,'&#xbb;')">
                <xsl:value-of select="translate(.,'&#xbb;','&gt;')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="if (normalize-space(.) != '') then normalize-space(.) else ''"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="(position() ne last()) and (normalize-space(.) != '') and ( following-sibling::xhtml:td[. != ''])">
            <xsl:value-of select="' '"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="xhtml:td[@class='label']">
        <xsl:if test="following-sibling::xhtml:td[@class='value']/. != ''">
            <xsl:value-of select="."/>
            <xsl:if test="not(ends-with(.,':'))">
                <xsl:value-of select="' '"/>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <!--A template to find the command with the most number of input fields and use that command to generate the required number of input fields.-->
    <xsl:template name="generate-input-fields">
        <xsl:variable name="commands" select="//xhtml:div[@class = 'commands']"/>
        <xsl:for-each select="$commands/descendant::xhtml:ul">
            <xsl:sort select="count(xhtml:li)" order="descending"/>
            <xsl:if test="position() = 1">
                <xsl:apply-templates select="ancestor::xhtml:fieldset" mode="input"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <!--Overriding the default templates-->
    <xsl:template match="xhtml:div"/>
    <xsl:template match="xhtml:div" mode="command"/>
    <xsl:template match="xhtml:fieldset"/>
    <xsl:template match="xhtml:table"/>
    <xsl:template match="xhtml:span"/>

</xsl:stylesheet>
<?xml version='1.0' encoding="utf-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:text="http://www.navis.com/ecn4web/functions"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                exclude-result-prefixes="saxon text xs fn"
                version='2.0'>
    <xsl:import href="functions.xsl"/>
    <xsl:output method="xhtml" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
                doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" indent="yes" omit-xml-declaration="yes"
                encoding="UTF-8"/>

    <xsl:template name="command-menu">
        <xsl:param name="formCommands" select="'formCommands.xml'" required="no"/>
        <xsl:param name="mode" select="''" required="no"/>
        <xsl:param name="formId" select="/message/@formId" required="no"/>
        <xsl:param name="cheId" select="/message/che/@CHID"/>

        <xsl:variable name="context-node" select="."/>
        <xsl:variable name="form" as="node()*">
            <xsl:apply-templates select="(document($formCommands)/form-list[form[@id = $formId][@mode = $mode]])[1]" mode="formMerge">
                <xsl:with-param name="formId" select="$formId"/>
                <xsl:with-param name="mode" select="$mode"/>
            </xsl:apply-templates>
        </xsl:variable>
        <xsl:apply-templates
                select="$form/command[not(@fixed) and @usePrefix = 'true']">
            <xsl:with-param name="context-node" select="$context-node"/>
        </xsl:apply-templates>
        <div id="clock" class="clock"/>
        <div class="commands">
            <xsl:apply-templates
                    select="$form/command[not(@fixed) and not(@usePrefix)]">
                <xsl:with-param name="context-node" select="$context-node"/>
            </xsl:apply-templates>
        </div>
        <div class="footer">
            <span class="segmented">
                <xsl:apply-templates select="$form/command[@fixed = 'footer']">
                    <xsl:with-param name="context-node" select="$context-node"/>
                    <xsl:with-param name="form" select="$form"/>
                </xsl:apply-templates>
            </span>
        </div>
        <input id="action" name="action" type="hidden" value="{$form/command[@template eq $form/@default]/@index}"/>
        <input name="async" value="{if ($form/@async eq 'false') then 'false' else 'true'}" id="async" type="hidden"/>
    </xsl:template>

    <xsl:template match="form-list" mode="formMerge">
        <xsl:param name="formId" required="yes"/>
        <xsl:param name="mode" required="yes"/>
        <!--select the current form-->
        <xsl:variable name="childForm" select="form[@id = $formId and @mode = $mode]"/>
        <xsl:choose>
            <xsl:when test="not($childForm/@inheritFrom)">
                <xsl:copy-of select="$childForm"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="parentForm" select="form[@id = $formId and @mode = '']"/>
                <xsl:apply-templates select="$childForm">
                    <xsl:with-param name="parent" select="$parentForm"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template match="form">
        <xsl:param name="parent" required="yes"/>

        <xsl:copy>
            <xsl:apply-templates select="$parent/command" mode="formMerge">
                <xsl:with-param name="child" select="."/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="command" mode="formMerge">
        <xsl:param name="child" required="yes"/>
        <xsl:variable name="index" select="@index"/>
        <xsl:variable name="childCommand" select="$child/command[@index = $index]"/>
        <xsl:choose>
            <xsl:when test="$childCommand">
                <xsl:copy-of select="$childCommand"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="command[@fixed = 'footer']">
        <xsl:param name="context-node"/>
        <xsl:param name="form"/>
        <xsl:variable name="enabled-status-bool"
                      select="empty(@enabled) or (saxon:evaluate(concat('$p1[', @enabled, ']'), $context-node))"
                      as="xs:boolean"/>
        <xsl:variable name="enabled-status"
                      select="if(empty(@enabled) or (saxon:evaluate(concat('$p1[', @enabled, ']'), $context-node))) then 'enabled' else 'disabled'"/>
        <xsl:variable name="command" select="text:format(@pattern)"/>
        <xsl:variable name="accesskey">
            <xsl:call-template name="find-accesskey">
                <xsl:with-param name="command-name" select="$command"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$form/@id = 'SYSTEM_REFRESH'">
                <a href="#" id="{@index}" class="{concat('button', ' ', $enabled-status)}"
                   onclick="submitCommand('{@index}')"
                   accesskey="{lower-case($accesskey)}">
                    <xsl:call-template name="anchor-content">
                        <xsl:with-param name="command" select="$command"/>
                        <xsl:with-param name="accesskey" select="$accesskey"/>
                    </xsl:call-template>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <a href="#" id="{@index}" class="{concat('button', ' ', $enabled-status)}" accesskey="{lower-case($accesskey)}">
                    <xsl:call-template name="anchor-content">
                        <xsl:with-param name="command" select="$command"/>
                        <xsl:with-param name="accesskey" select="$accesskey"/>
                    </xsl:call-template>
                </a>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="command[not(@fixed) and @usePrefix = 'true']">
        <xsl:param name="context-node"/>
        <xsl:param name="items" tunnel="yes" required="yes" as="node()*"/>
        <xsl:variable name="label" select="text:format(field/@pattern)"/>
        <xsl:variable name="indexPrefix" select="'index-'"/>
        <xsl:variable name="command" select="."/>
        <fieldset class="button">
            <legend>
                <span class="header">
                    <a href="#" class="button enabled" id="{@index}">
                        <xsl:value-of
                                select="if(@abbrev-pattern) then text:format(@abbrev-pattern) else text:format(@pattern)"
                                disable-output-escaping="yes"/> &#xbb;
                    </a>
                </span>
            </legend>
            <table class="data">
                <caption>
                    <xsl:value-of select="text:format('label.Unit_Details')"/>
                </caption>
                <tbody>
                    <xsl:for-each select="$items">
                        <tr>
                            <td class="label">
                                <xsl:value-of select="@name"/>
                            </td>
                            <td class="value">
                                <xsl:value-of select="@id"/>
                                <xsl:variable name="name" select="concat($indexPrefix, @id)"/>
                                <xsl:variable name="inputId"
                                              select="concat($command/@pattern, '.', $command/field/@pattern, '.', position())"/>
                                <label for="{$inputId}">
                                    <span class="label">
                                        <xsl:value-of select="$label"/>
                                    </span>
                                </label>
                                <input type="text"
                                       name="{$name}"
                                       id="{$inputId}"
                                       value="" size="12">
                                </input>
                            </td>
                        </tr>
                    </xsl:for-each>
                </tbody>
            </table>
            <input name="indexPrefix" type="hidden" value="{$indexPrefix}"/>
        </fieldset>
    </xsl:template>

    <xsl:template name="command-button">
        <xsl:param name="context-node"/>
        <xsl:variable name="enabled-status-bool"
                      select="empty(@enabled) or (saxon:evaluate(concat('$p1[', @enabled, ']'), $context-node))"
                      as="xs:boolean"/>
        <xsl:variable name="enabled-status"
                      select="if(empty(@enabled) or (saxon:evaluate(concat('$p1[', @enabled, ']'), $context-node))) then 'enabled' else 'disabled'"/>
        <xsl:variable name="formatted-content">
            <xsl:choose>
                <xsl:when test="count(@params) = 1">
                    <xsl:variable name="sequenced-params" select="concat('(', @params, ')')"/>
                    <xsl:variable name="evaluated-params">
                        <xsl:analyze-string select="$sequenced-params" regex="\{{([^\}}]+)\}}">
                            <xsl:matching-substring>
                                '<xsl:value-of select="saxon:evaluate(concat('$p1',regex-group(1)), $context-node)"/>'
                            </xsl:matching-substring>
                            <xsl:non-matching-substring>
                                <xsl:value-of select="."/>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </xsl:variable>
                    <xsl:value-of select="text:format(@pattern, saxon:evaluate(normalize-space($evaluated-params)))"/>
                </xsl:when>
                <xsl:when test="count(@params)= 2">
                    <xsl:variable name="sequenced-params" select="concat('(', @params, ')')"/>
                    <xsl:variable name="evaluated-params">
                        <xsl:analyze-string select="$sequenced-params" regex="\{{([^\}}]+)\}}">
                            <xsl:matching-substring>
                                '<xsl:value-of select="saxon:evaluate(concat('$p1',regex-group(1),regex-group(2)), $context-node)"/>'
                            </xsl:matching-substring>
                            <xsl:non-matching-substring>
                                <xsl:value-of select="."/>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </xsl:variable>
                    <xsl:value-of select="text:format(@pattern, saxon:evaluate(normalize-space($evaluated-params)))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="text:format(@pattern)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="accesskey">
            <xsl:call-template name="find-accesskey">
                <xsl:with-param name="command-name" select="$formatted-content"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="cssSytle"
                      select="if (count(field) gt 2) then concat('button', ' ', $enabled-status,' ', 'long-button') else concat('button', ' ', $enabled-status)"/>

        <fieldset class="{$cssSytle}">
            <legend class="command">
                <span class="inline">
                    <xsl:choose>
                        <xsl:when test="field">
                            <a href="#" class="{concat('button', ' ', $enabled-status)}" id="{@index}">
                                <xsl:call-template name="anchor-content">
                                    <xsl:with-param name="command" select="$formatted-content"/>
                                    <xsl:with-param name="accesskey" select="$accesskey"/>
                                </xsl:call-template>
                                <xsl:apply-templates select="@abbrev20">
                                    <xsl:with-param name="context-node" select="$context-node"/>
                                </xsl:apply-templates>
                                <xsl:apply-templates select="@abbrev40">
                                    <xsl:with-param name="context-node" select="$context-node"/>
                                </xsl:apply-templates>
                            </a>
                        </xsl:when>
                        <xsl:otherwise>
                            <a href="#" class="{concat('button', ' ', $enabled-status)}" id="{@index}" accesskey="{lower-case($accesskey)}">
                                <xsl:call-template name="anchor-content">
                                    <xsl:with-param name="command" select="$formatted-content"/>
                                    <xsl:with-param name="accesskey" select="$accesskey"/>
                                </xsl:call-template>
                                <xsl:apply-templates select="@abbrev20">
                                    <xsl:with-param name="context-node" select="$context-node"/>
                                </xsl:apply-templates>
                                <xsl:apply-templates select="@abbrev40">
                                    <xsl:with-param name="context-node" select="$context-node"/>
                                </xsl:apply-templates>
                            </a>
                        </xsl:otherwise>
                    </xsl:choose>
                </span>
            </legend>
            <xsl:if test="field">
                <ul>
                    <xsl:apply-templates select="field">
                        <xsl:with-param name="enabled-status-bool" select="$enabled-status-bool"/>
                        <xsl:with-param name="context-node" select="$context-node"/>
                        <xsl:with-param name="command-name" select="$formatted-content"/>
                    </xsl:apply-templates>
                </ul>
            </xsl:if>
            <span class="arrow">&#xbb;</span>
        </fieldset>
    </xsl:template>

    <xsl:template match="@abbrev20">
        <xsl:param name="context-node"/>
        <xsl:variable name="abbrev20">
            <xsl:call-template name="findAbbreviated20Command">
                <xsl:with-param name="abbrev" select="."/>
                <xsl:with-param name="context-node" select="$context-node"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:comment>
            <xsl:value-of select="concat('abbrev20=',$abbrev20)"/>
        </xsl:comment>
    </xsl:template>

    <xsl:template name="findAbbreviated20Command">
        <xsl:param name="abbrev"/>
        <xsl:param name="context-node"/>
        <xsl:choose>
            <xsl:when test="@params">
                <xsl:variable name="sequenced-params" select="concat('(', @params, ')')"/>
                <xsl:variable name="evaluated-params">
                    <xsl:analyze-string select="$sequenced-params" regex="\{{([^\}}]+)\}}">
                        <xsl:matching-substring>
                            '<xsl:value-of select="saxon:evaluate(concat('$p1',regex-group(1)), $context-node)"/>'
                        </xsl:matching-substring>
                        <xsl:non-matching-substring>
                            <xsl:value-of select="."/>
                        </xsl:non-matching-substring>
                    </xsl:analyze-string>
                </xsl:variable>
                <xsl:value-of select="text:format($abbrev, saxon:evaluate(normalize-space($evaluated-params)))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="text:format($abbrev)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="@abbrev40">
        <xsl:param name="context-node"/>
        <xsl:variable name="abbrev40">
            <xsl:call-template name="findAbbreviated40Command">
                <xsl:with-param name="abbrev" select="."/>
                <xsl:with-param name="context-node" select="$context-node"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:comment>
            <xsl:value-of select="concat('abbrev40=',$abbrev40)"/>
        </xsl:comment>
    </xsl:template>

    <xsl:template name="findAbbreviated40Command">
        <xsl:param name="abbrev"/>
        <xsl:param name="context-node"/>
        <xsl:choose>
            <xsl:when test="@params">
                <xsl:variable name="sequenced-params" select="concat('(', @params, ')')"/>
                <xsl:variable name="evaluated-params">
                    <xsl:analyze-string select="$sequenced-params" regex="\{{([^\}}]+)\}}">
                        <xsl:matching-substring>
                            '<xsl:value-of select="saxon:evaluate(concat('$p1',regex-group(1)), $context-node)"/>'
                        </xsl:matching-substring>
                        <xsl:non-matching-substring>
                            <xsl:value-of select="."/>
                        </xsl:non-matching-substring>
                    </xsl:analyze-string>
                </xsl:variable>
                <xsl:value-of select="text:format($abbrev, saxon:evaluate(normalize-space($evaluated-params)))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="text:format($abbrev)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="command[not(@fixed) and not(@usePrefix)]">
        <xsl:param name="context-node"/>
        <xsl:variable name="visible-status-bool"
                      select="(not(fn:empty(@visible)) and (saxon:evaluate(concat('$p1[', @visible, ']'), $context-node)) or not(@visible))"
                      as="xs:boolean"/>
        <xsl:if test="$visible-status-bool">
            <xsl:call-template name="command-button">
                <xsl:with-param name="context-node" select="$context-node"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template name="unit-items">
        <xsl:param name="items" tunnel="yes" required="yes" as="node()*"/>
        <xsl:param name="formCommands" select="'formCommands.xml'" required="no"/>
        <xsl:param name="formId" select="/message/@formId" required="no"/>
        <xsl:variable name="indexPrefix" select="'index-'"/>
        <xsl:variable name="form" as="node()*">
            <xsl:apply-templates select="(document($formCommands)/form-list[form[@id = $formId]])[1]" mode="formMerge">
                <xsl:with-param name="formId" select="$formId"/>
                <xsl:with-param name="mode" select="''"/>
            </xsl:apply-templates>
        </xsl:variable>
        <xsl:variable name="command"
                      select="$form/command[@fixed = 'legend']"/>
        <xsl:variable name="label" select="text:format($command/field/@pattern)"/>
        <xsl:for-each select="$items">
            <div class="pad">
                <xsl:variable name="counter" select="position()" as="xs:integer"/>
                <span class="inline">
                    <xsl:value-of select="$items[$counter]/@id"/>
                </span>
                <ul>
                    <li>
                        <xsl:variable name="name" select="concat($indexPrefix, $items[$counter]/@id)"/>
                        <xsl:variable name="inputId"
                                      select="concat($command/@pattern, '.', $command/field/@pattern,'.',position())"/>
                        <label for="{$inputId}">
                            <span class="label">
                                <xsl:value-of select="$label"/>
                            </span>
                        </label>
                        <input type="text"
                               class="field labeled"
                               name="{$name}"
                               id="{$inputId}"
                               value="" size="12">
                        </input>
                    </li>
                </ul>
            </div>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="field">
        <xsl:param name="enabled-status-bool" as="xs:boolean"/>
        <xsl:param name="context-node"/>
        <xsl:param name="command-name"/>
        <xsl:variable name="inputName">
            <xsl:choose>
                <xsl:when test="@name">
                    <xsl:value-of select="@name"/>
                </xsl:when>
                <xsl:when test="position() = 1">inputValue</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('inputValue', position())"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="inputId" select="concat(parent::command/@pattern, '.', @pattern)"/>
        <xsl:variable name="label" select="text:format(@pattern)"/>
        <xsl:variable name="fieldType" select="if(@type) then @type else 'text'"/>
        <xsl:variable name="accesskey">
            <xsl:choose>
                <xsl:when test="position() = 1">
                    <xsl:call-template name="find-accesskey">
                        <xsl:with-param name="command-name" select="$command-name"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <li>
            <label for="{$inputId}">
                <span class="label">
                    <xsl:value-of select="$label"/>
                </span>
            </label>
            <input name="{$inputName}" id="{$inputId}" maxlength="15" size="12" class="field" type="{$fieldType}"
                   accesskey="{lower-case($accesskey)}">
                <xsl:if test="@value">
                    <xsl:message select="concat('@value: ', @value)"/>
                    <xsl:attribute name="value">
                        <xsl:variable name="sequenced-params" select="concat('(', @value, ')')"/>
                        <xsl:message select="concat('sequenced-params: ', $sequenced-params)"/>
                        <xsl:variable name="evaluated-params">
                            <xsl:analyze-string select="$sequenced-params" regex="\{{([^\}}]+)\}}">
                                <xsl:matching-substring>
                                    '<xsl:value-of
                                        select="saxon:evaluate(concat('$p1',regex-group(1)), $context-node)"/>'
                                </xsl:matching-substring>
                                <xsl:non-matching-substring>
                                    <xsl:value-of select="."/>
                                </xsl:non-matching-substring>
                            </xsl:analyze-string>
                        </xsl:variable>
                        <xsl:value-of select="saxon:evaluate(normalize-space($evaluated-params))"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="not($enabled-status-bool)">
                    <xsl:attribute name="disabled" select="'disabled'"/>
                </xsl:if>
            </input>
        </li>
    </xsl:template>

    <xsl:template match="text()[. ne '']">
        <xsl:param name="context-node"/>
        <xsl:analyze-string select="." regex="\{{([^\}}]+)\}}">
            <xsl:matching-substring>
                <xsl:value-of select="saxon:evaluate(concat('$p1',regex-group(1)), $context-node)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

    <xsl:template name="pagination-controls">
        <xsl:param name="pagination-title"/>
        <xsl:param name="context-node" select="."/>
        <xsl:param name="formCommands" select="'formCommands.xml'" required="no"/>
        <xsl:param name="mode" select="''" required="no"/>

        <xsl:variable name="form" as="node()*">
            <xsl:apply-templates select="(document($formCommands)/form-list[form[@id = $formId][@mode = $mode]])[1]" mode="formMerge">
                <xsl:with-param name="formId" select="$formId"/>
                <xsl:with-param name="mode" select="$mode"/>
            </xsl:apply-templates>
        </xsl:variable>

        <span class="segmented">
            <xsl:variable name="back-command"
                          select="$form/command[@fixed = 'pagination'][1]"/>
            <xsl:variable name="enabled-status-back"
                          select="if(empty($back-command/@enabled) or (saxon:evaluate(concat('$p1[', $back-command/@enabled, ']'), $context-node))) then 'enabled' else 'disabled'"/>

            <a href="#" class="{concat('button', ' ', $enabled-status-back)}" id="{$back-command/@index}" accesskey=",">
                <xsl:choose>
                    <xsl:when test="$back-command/@abbrev-pattern">
                        <abbr title="{text:format($back-command/@pattern)}">
                            <xsl:value-of select="text:format($back-command/@abbrev-pattern)"
                                          disable-output-escaping="yes"/>
                        </abbr>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="text:format($back-command/@pattern)" disable-output-escaping="yes"/>
                    </xsl:otherwise>
                </xsl:choose>
            </a>

            <em>
                <xsl:value-of select="$pagination-title"/>
            </em>

            <xsl:variable name="forward-command"
                          select="$form/command[@fixed = 'pagination'][2]"/>
            <xsl:variable name="enabled-status-front"
                          select="if(empty($forward-command/@enabled) or (saxon:evaluate(concat('$p1[', $forward-command/@enabled, ']'), $context-node))) then 'enabled' else 'disabled'"/>

            <a href="#" class="{concat('button', ' ', $enabled-status-front)}" id="{$forward-command/@index}"
               accesskey=".">
                <xsl:choose>
                    <xsl:when test="$forward-command/@abbrev-pattern">
                        <abbr title="{text:format($forward-command/@pattern)}">
                            <xsl:value-of select="text:format($forward-command/@abbrev-pattern)"
                                          disable-output-escaping="yes"/>
                        </abbr>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="text:format($forward-command/@abbrev)" disable-output-escaping="yes"/>
                    </xsl:otherwise>
                </xsl:choose>
            </a>
        </span>
    </xsl:template>

    <xsl:template name="legend-controls">
        <xsl:param name="formCommands" select="'formCommands.xml'" required="no"/>
        <xsl:param name="formId" select="/message/@formId" required="no"/>
        <xsl:param name="index" required="yes"/>
        <xsl:param name="mode" required="no" select="'TWIN'"/>

        <xsl:variable name="form" as="node()*">
            <xsl:apply-templates select="(document($formCommands)/form-list[form[@id = $formId]])[1]" mode="formMerge">
                <xsl:with-param name="formId" select="$formId"/>
                <xsl:with-param name="mode" select="'TWIN'"/>
            </xsl:apply-templates>
        </xsl:variable>
        <span class="segmented">
            <xsl:variable name="command"
                          select="$form/command[@fixed = 'legend'][$index]"/>
            <xsl:variable name="legend-title"
                          select="text:format($command/@pattern)"/>
            <xsl:variable name="accesskey">
                <xsl:call-template name="find-accesskey">
                    <xsl:with-param name="command-name" select="$legend-title"/>
                </xsl:call-template>
            </xsl:variable>
            <a href="#" class="button enabled" id="{$command/@index}" accesskey="{lower-case($accesskey)}">
                <xsl:call-template name="anchor-content">
                    <xsl:with-param name="command" select="$legend-title"/>
                    <xsl:with-param name="accesskey" select="$accesskey"/>
                </xsl:call-template>
                <xsl:text> </xsl:text>
                <span class="legend-arrow">
                    <xsl:value-of select="text:format($command/@abbrev-pattern)" disable-output-escaping="yes"/>
                </span>
            </a>
        </span>
    </xsl:template>

    <xsl:template name="list-controls">
        <xsl:param name="formCommands" select="'formCommands.xml'" required="no"/>
        <xsl:param name="mode" select="''" required="no"/>
        <xsl:param name="context-node" select="."/>
        <xsl:variable name="form" as="node()*">
            <xsl:apply-templates select="(document($formCommands)/form-list[form[@id = $formId][@mode = $mode]])[1]" mode="formMerge">
                <xsl:with-param name="formId" select="$formId"/>
                <xsl:with-param name="mode" select="$mode"/>
            </xsl:apply-templates>
        </xsl:variable>
        <span class="segmented">
            <xsl:variable name="filter-command"
                          select="$form/command[@fixed = 'pagination'][3]"/>
            <xsl:variable name="filter-param">
                <xsl:apply-templates select="/message/che/joblist/@filterUserParameter"/>
            </xsl:variable>
            <xsl:variable name="command" select="text:format($filter-command/@pattern)"/>
            <xsl:variable name="filter-accesskey">
                <xsl:call-template name="find-accesskey">
                    <xsl:with-param name="command-name" select="$command"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="enabled-status-filter"
                          select="if(empty($filter-command/@enabled) or (saxon:evaluate(concat('$p1[', $filter-command/@enabled, ']'), $context-node))) then 'enabled' else 'disabled'"/>

            <a href="#" class="{concat('button' , ' ', $enabled-status-filter)}" id="{$filter-command/@index}"
               accesskey="{lower-case($filter-accesskey)}">
                <xsl:call-template name="anchor-content">
                    <xsl:with-param name="command" select="$command"/>
                    <xsl:with-param name="accesskey" select="$filter-accesskey"/>
                </xsl:call-template>
                <xsl:value-of select="concat(': ', /message/che/joblist/@filterType, $filter-param)"/>
            </a>

            <xsl:variable name="sort-command"
                          select="$form/command[@fixed = 'pagination'][4]"/>
            <xsl:variable name="sort-param">
                <xsl:apply-templates select="/message/che/joblist/@sortUserParameter"/>
            </xsl:variable>
            <xsl:variable name="sort-command-value" select="text:format($sort-command/@pattern)"/>
            <xsl:variable name="sort-accesskey">
                <xsl:call-template name="find-accesskey">
                    <xsl:with-param name="command-name" select="$sort-command-value"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="enabled-status-sort"
                          select="if(empty($sort-command/@enabled) or (saxon:evaluate(concat('$p1[', $sort-command/@enabled, ']'), $context-node))) then 'enabled' else 'disabled'"/>

            <a href="#" class="{concat('button', ' ', $enabled-status-sort)}" id="{$sort-command/@index}"
               accesskey="{lower-case($sort-accesskey)}">
                <xsl:call-template name="anchor-content">
                    <xsl:with-param name="command" select="$sort-command-value"/>
                    <xsl:with-param name="accesskey" select="$sort-accesskey"/>
                </xsl:call-template>
                <xsl:value-of
                        select="concat(': ', /message/che/joblist/@sortType, $sort-param)"/>
            </a>
        </span>
    </xsl:template>

    <xsl:template name="toggle-single-twin-options">
        <xsl:param name="formCommands" select="'formCommands.xml'" required="no"/>
        <xsl:param name="context-node" select="."/>
        <xsl:param name="mode" select="''" required="no"/>
        <xsl:variable name="form" as="node()*">
            <xsl:apply-templates select="(document($formCommands)/form-list[form[@id = $formId][@mode = $mode]])[1]" mode="formMerge">
                <xsl:with-param name="formId" select="$formId"/>
                <xsl:with-param name="mode" select="$mode"/>
            </xsl:apply-templates>
        </xsl:variable>
        <xsl:if test="exists($form/command[@fixed = 'pagination'][3])">
            <xsl:variable name="list-mode-command"
                          select="$form/command[@fixed = 'pagination'][3]"/>
            <xsl:variable name="enabled-status-toggle"
                          select="if(empty($list-mode-command/@enabled) or (saxon:evaluate(concat('$p1[', $list-mode-command/@enabled, ']'), $context-node))) then 'enabled' else 'disabled'"/>
            <xsl:variable name="command" select="text:format($list-mode-command/@pattern)"/>
            <xsl:variable name="accesskey">
                <xsl:call-template name="find-accesskey">
                    <xsl:with-param name="command-name" select="$command"/>
                </xsl:call-template>
            </xsl:variable>
            <span>&#160;</span>

            <span class="segmented">
                <a href="#" class="{concat('button', ' ', $enabled-status-toggle)}" id="{$list-mode-command/@index}"
                   accesskey="{lower-case($accesskey)}">
                    <xsl:call-template name="anchor-content">
                        <xsl:with-param name="command" select="$command"/>
                        <xsl:with-param name="accesskey" select="$accesskey"/>
                    </xsl:call-template>
                </a>
            </span>
        </xsl:if>
    </xsl:template>

    <xsl:template name="form-title-resource">
        <xsl:param name="formCommands" select="'formCommands.xml'" required="no"/>
        <xsl:param name="mode" select="''" required="no"/>
        <xsl:variable name="formId" select="/message/@formId"/>
        <xsl:variable name="form" as="node()*">
            <xsl:apply-templates select="(document($formCommands)/form-list[form[@id = $formId][@mode = $mode]])[1]" mode="formMerge">
                <xsl:with-param name="formId" select="$formId"/>
                <xsl:with-param name="mode" select="$mode"/>
            </xsl:apply-templates>
        </xsl:variable>
        <xsl:variable name="title">
            <xsl:value-of select="$form/@title"/>
        </xsl:variable>
        <xsl:value-of select="$title"/>
    </xsl:template>

    <xsl:template name="anchor-content">
        <xsl:param name="command"/>
        <xsl:param name="accesskey"/>
        <xsl:value-of select="substring-before($command,$accesskey)"/>
        <span class="accesskey">
            <xsl:value-of select="$accesskey"/>
        </span>
        <xsl:value-of select="substring-after($command,$accesskey)"/>
    </xsl:template>

    <xsl:template name="find-accesskey">
        <xsl:param name="command-name" required="yes"/>
        <xsl:if test="string-length($command-name) > 0">
            <xsl:variable name="candidate-accesskey" select="substring($command-name,1,1)"/>
            <xsl:variable name="is-valid">
                <xsl:call-template name="is-valid-accesskey">
                    <xsl:with-param name="accesskey" select="$candidate-accesskey"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:if test="$is-valid = 'false'">
                <xsl:call-template name="find-accesskey">
                    <xsl:with-param name="command-name" select="substring($command-name,2)"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="not($is-valid = 'false')">
                <xsl:value-of select="$candidate-accesskey"/>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <xsl:template name="is-valid-accesskey">
        <xsl:param name="accesskey" required="yes"/>
        <xsl:for-each select="tokenize($invalid-accesskeys,',')">
            <xsl:if test="lower-case($accesskey) = lower-case(.)">
                <xsl:value-of select="'false'"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <!--Unsupported accesskeys.-->
    <xsl:variable name="invalid-accesskeys" select="'D, '"/>

</xsl:stylesheet>

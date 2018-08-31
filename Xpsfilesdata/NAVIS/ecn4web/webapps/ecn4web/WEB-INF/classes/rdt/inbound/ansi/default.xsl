<?xml version='1.0' encoding='utf-8'?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<!--This is an adapter template for ansi-telnet used as a second level transformation for narrow-band devices.
The initial xhtml output is transformed to a groovy class-->
<xsl:stylesheet xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns="http://www.w3.org/1999/html"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="xs xhtml xsl"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xml:space="default"
                version="2.0">

    <xsl:output method="text" encoding="utf-8" omit-xml-declaration="yes" indent="yes"/>

    <!--TODO: clean template and add more documentation -->

    <xsl:param name="packageName">com.navis.ecn4web.shell</xsl:param>
    <xsl:param name="className" select="concat('ScreenRenderer', translate(string(current-time()), ':.-+', ''))"/>
    <xsl:param name="com.navis.ecn4web.terminal.rows" select="8"/>
    <xsl:param name="com.navis.ecn4web.terminal.columns" select="40"/>
    <xsl:param name="inputFieldSize">8</xsl:param>
    <xsl:param name="custom_abbrev">_CustomAbbrev</xsl:param>
    <xsl:param name="fake_command_index">99:</xsl:param>
    <xsl:param name="com.navis.ecn4web.terminal.color.theme" select="'COLORED'"/>

    <xsl:variable name="rows" select="$com.navis.ecn4web.terminal.rows"/>
    <xsl:variable name="columns" select="$com.navis.ecn4web.terminal.columns"/>
    <xsl:variable name="terminalTheme" select="lower-case($com.navis.ecn4web.terminal.color.theme)"/>

    <!--Select component types based on the terminal color theme-->
    <xsl:variable name="buttonType" select="if($terminalTheme = 'monochrome') then 'DecoratedButton' else 'Button'"/>
    <xsl:variable name="textBoxType" select="if($terminalTheme = 'monochrome') then 'DecoratedTextBox' else 'TextBox'"/>
    <xsl:variable name="passwordBoxType" select="if($terminalTheme = 'monochrome') then 'DecoratedPasswordBox' else 'PasswordBox'"/>
    <xsl:variable name="abbreviationLabelType"
                  select="if($terminalTheme = 'monochrome') then 'DecoratedAbbreviationLabel' else 'AbbreviationLabel'"/>
    <xsl:variable name="smartLabelType" select="if($terminalTheme = 'monochrome') then 'DecoratedSmartLabel' else 'SmartLabel'"/>

    <!--Entry point to adapter template-->
    <xsl:template match="/">
        <xsl:call-template name="imports"/>
        <xsl:call-template name="class"/>
    </xsl:template>

    <xsl:template name="class">
        <xsl:text>public class </xsl:text>
        <xsl:value-of select="$className"/>
        <xsl:text> implements RdtScreenRenderer {
        private IRdtShell _shell
        private Button _submitButton
        private Action formAction</xsl:text>
        <xsl:call-template name="newLine"/>
        <xsl:value-of disable-output-escaping="yes"
                      select="'def List&lt;SmartLabel&gt; commandLabelList = new ArrayList&lt;&gt;()'"/>
        <xsl:call-template name="newLine"/>
        <xsl:value-of disable-output-escaping="yes"
                      select="'def List&lt;SmartLabel&gt; paginationLabelList = new ArrayList&lt;&gt;()'"/>
        <xsl:call-template name="newLine"/>
        <xsl:value-of disable-output-escaping="yes"
                      select="concat('def Map&lt;String, ',$textBoxType,'&gt; inputFields = new HashMap&lt;&gt;()')"/>
        <xsl:call-template name="newLine"/>
        <xsl:value-of disable-output-escaping="yes"
                      select='"def Map&lt;String, String&gt; parameters = new HashMap&lt;&gt;()"'/>
        <xsl:call-template name="newLine"/>
        <xsl:value-of select="concat('private ' ,$textBoxType, ' action')"/>
        <xsl:call-template name="newLine"/>
        <xsl:call-template name="declare-input-fields"/>
        <xsl:call-template name="newLine"/>
        <xsl:text>private Window _window</xsl:text>
        <xsl:call-template name="newLine"/>
        <xsl:text>private usedRows = 0</xsl:text>
        <xsl:call-template name="newLine"/>
        <xsl:text>def </xsl:text>
        <xsl:value-of select="$className"/>
        <xsl:text>(IRdtShell shell) {</xsl:text>
        <xsl:call-template name="newLine"/>
        <xsl:text>this._shell = shell</xsl:text>
        <xsl:call-template name="newLine"/>
        <xsl:text>populateParameters()</xsl:text>
        <xsl:call-template name="newLine"/>
        <xsl:text>}</xsl:text>
        <xsl:call-template name="newLine"/>
        <xsl:call-template name="methodGetWindow"/>
        <xsl:call-template name="newLine"/>
        <!--Main template used to create all the components-->
        <xsl:call-template name="methodBuild"/>
        <xsl:call-template name="newLine"/>
        <xsl:call-template name="methodPopulateParameters"/>
        <xsl:call-template name="newLine"/>
        <xsl:call-template name="methodGetParameters"/>
        <xsl:call-template name="newLine"/>
        <xsl:call-template name="methodGetSubmitButton"/>
        <xsl:call-template name="newLine"/>
        <xsl:call-template name="methodGetAction"/>
        <xsl:call-template name="newLine"/>
        <xsl:call-template name="methodGetFormAction"/>
        <xsl:call-template name="newLine"/>
        <xsl:call-template name="methodGetInputFieldMap"/>
        <xsl:text>}</xsl:text>
        <xsl:call-template name="newLine"/>
    </xsl:template>

    <xsl:template name="methodGetInputFieldMap">
        @Override
        public Map&lt;String, String&gt; getInputFields() {
        return inputFields
        }
        public void setInputFields(Map&lt;String, String&gt; inputFields) {
        this.inputFields = inputFields
        }
    </xsl:template>

    <xsl:template name="methodGetAction">
        @Override TextBox getAction(){ return action }
        public void setAction(TextBox action) { this.action = action }
        <xsl:call-template name="newLine"/>
    </xsl:template>

    <xsl:template name="methodGetFormAction">
        @Override Action getFormAction(){ return formAction }
    </xsl:template>

    <xsl:template name="methodGetSubmitButton">
        @Override
        public Button getSubmitButton() {
        return _submitButton
        }
        public void setSubmitButton(Button button) {
        _submitButton = button
        }
    </xsl:template>

    <xsl:template name="methodGetWindow">
        <!--<xsl:call-template name="new-line"/>-->
        @Override
        public Window getWindow() {
        return _window
        }
        public void setWindow(Window window) {
        _window = window
        }
    </xsl:template>

    <xsl:template name="methodPopulateParameters">
        <xsl:call-template name="newLine"/>
        <xsl:text>void populateParameters() {</xsl:text>
        <xsl:call-template name="newLine"/>
        <xsl:apply-templates select="//xhtml:input[@type= 'hidden']"/>
        <xsl:text>}</xsl:text>
        <xsl:call-template name="newLine"/>
    </xsl:template>

    <xsl:template name="methodGetParameters">
        @Override
        public Map&lt;String, String&gt; getParameters() {
        return parameters;
        }
        public void setParameters(Map&lt;String, String&gt; parameters) {
        this.parameters = parameters;
        }
    </xsl:template>

    <xsl:template name="methodBuild">
        <xsl:call-template name="newLine"/>
        <xsl:text>@Override</xsl:text>
        <xsl:call-template name="newLine"/>
        <xsl:text>void build(Window inWindow) {</xsl:text>
        <xsl:call-template name="window"/>
        <xsl:text>}</xsl:text>
    </xsl:template>

    <xsl:template match="xhtml:title">
        <xsl:variable name="abbreviatedTitle">
            <xsl:value-of select="normalize-space(substring-before(.,'- ECN4Web'))"/>
        </xsl:variable>
        <xsl:value-of select="concat('[',if($abbreviatedTitle ne '') then $abbreviatedTitle else normalize-space(.),']')"/>
    </xsl:template>

    <!--Copy all the hidden fields -->
    <xsl:template match="xhtml:input[@type='hidden']">
        <xsl:choose>
            <xsl:when test="@name = 'maxPageItems'">
                <xsl:variable name="calculatedValue">
                    <xsl:call-template name="calculateMaxPageItems"/>
                </xsl:variable>
                <xsl:value-of select="concat('parameters.put(&quot;',@name,'&quot;,&quot;',$calculatedValue,'&quot;)')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat('parameters.put(&quot;',@name,'&quot;,&quot;',@value,'&quot;)')"/>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:call-template name="newLine"/>
    </xsl:template>

    <xsl:template name="calculateMaxPageItems">
        <xsl:choose>
            <xsl:when test="$columns lt 40">
                <xsl:variable name="jobs" select="floor(($rows - 3) div 2)"/>
                <xsl:value-of select="$jobs"/>
            </xsl:when>
            <xsl:when test="$columns &gt;= 40">
                <xsl:variable name="jobs" select="($rows - 3)"/>
                <xsl:value-of select="if ($jobs gt 6) then 6 else $jobs"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="xhtml:input[@type='text' or @type ='password']" mode="definition">
        <xsl:param name="count"/>
        <xsl:variable name="type" select="if (@type = 'text') then $textBoxType else $passwordBoxType"/>
        <xsl:call-template name="newLine"/>
        <xsl:value-of select="concat(@name , '= new ',$type,'(&quot;&quot;,', $inputFieldSize,')')"/>
        <xsl:call-template name="newLine"/>
        <xsl:value-of select="concat('inputFields.put(&quot;',@name,'&quot;,',@name,')')"/>
        <xsl:choose>
            <xsl:when test="$columns = 20 and (($count = 2 and position() > 1) or ($count = 3 and position() > 2))">
                <xsl:call-template name="newLine"/>
                <xsl:text>panel2.addComponent(</xsl:text>
                <xsl:value-of select="@name"/>
                <xsl:text>)</xsl:text>
                <xsl:call-template name="newLine"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="newLine"/>
                <xsl:text>panel1.addComponent(</xsl:text>
                <xsl:value-of select="@name"/>
                <xsl:text>)</xsl:text>
                <xsl:call-template name="newLine"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="xhtml:input[@type='text' or @type ='password']" mode="declaration">
        <xsl:variable name="type" select="if (@type = 'text') then $textBoxType else $passwordBoxType"/>
        <xsl:value-of select="concat('private ',$type,' ', @name)"/>
        <xsl:call-template name="newLine"/>
        <xsl:value-of select="concat($type,' get',@name,'(){',' return ',@name,' }')"/>
        <xsl:call-template name="newLine"/>
    </xsl:template>

    <xsl:template match="xhtml:input[@type='text' or @type ='password']" mode="addToMap">
        <xsl:variable name="commandText">
            <xsl:value-of select="concat(@name, '.getText()')"/>
        </xsl:variable>
        <xsl:call-template name="newLine"/>
        <xsl:value-of select="concat('if (!', $commandText, '.isEmpty()) {')"/>
        <xsl:call-template name="newLine"/>
        <xsl:value-of select="concat('parameters.put(&quot;', @name , '&quot;,', @name, '.getText())')"/>
        <xsl:text>}</xsl:text>
        <xsl:call-template name="newLine"/>
    </xsl:template>

    <xsl:template name="command-fields">
        <xsl:text>
        def commandFields = new Panel(new Border.Invisible(), Panel.Orientation.VERTICAL)
        def panel1 = new Panel(new Border.Invisible(), Panel.Orientation.HORISONTAL)
        action = new </xsl:text><xsl:value-of select="$textBoxType"/><xsl:text>("", 2)
        inputFields.put("action", action)
        panel1.addComponent(action)
        commandFields.addComponent(panel1)</xsl:text>
        <xsl:call-template name="newLine"/>
        <xsl:call-template name="generate-input-fields"/>
        <xsl:call-template name="submit-button"/>
        <xsl:call-template name="newLine"/>
        <xsl:text>usedRows+= commandFields.getPreferredSize().rows</xsl:text>
        <xsl:call-template name="newLine"/>
        <xsl:text>_window.addComponent(commandFields)</xsl:text>
    </xsl:template>

    <xsl:template name="submit-button">
        <xsl:variable name="input-field-count">
            <xsl:call-template name="count-max-input-fields"/>
        </xsl:variable>
        <xsl:text>
        formAction = new Action() {
            @Override
            void doAction() {
                if (!action.getText().isEmpty())
                    parameters.put("action", action.getText())
        </xsl:text>
        <xsl:call-template name="newLine"/>
        <xsl:call-template name="add-input-fields-to-map"/>
        <xsl:call-template name="newLine"/>
        <xsl:text>
                _shell.submit(parameters)
            }
        }
        _submitButton = new </xsl:text><xsl:value-of select="$buttonType"/><xsl:text>("GO", formAction)
        </xsl:text>
        <xsl:variable name="title">
            <xsl:apply-templates select="//xhtml:title"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$columns = 20 and $input-field-count > 1">
                <xsl:text>panel2.addComponent(_submitButton)</xsl:text>
                <xsl:call-template name="newLine"/>
                <xsl:text>panel1.addComponent(new </xsl:text><xsl:value-of select="$abbreviationLabelType"/><xsl:text>(</xsl:text>
                <xsl:value-of select="concat('&quot;',$title,'&quot;,')"/>
                <xsl:value-of select="concat('&quot;',$title,'&quot;')"/>
                <xsl:text>,</xsl:text><xsl:value-of select="$columns"/><xsl:text>,</xsl:text><xsl:value-of select="$columns"/><xsl:text>-panel2.getPreferredSize().columns,  Terminal.Color.WHITE))</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>panel1.addComponent(_submitButton)</xsl:text>
                <xsl:call-template name="newLine"/>
                <xsl:text>panel1.addComponent(new </xsl:text><xsl:value-of select="$abbreviationLabelType"/><xsl:text>(</xsl:text>
                <xsl:value-of select="concat('&quot;',$title,'&quot;,')"/>
                <xsl:value-of select="concat('&quot;',$title,'&quot;')"/>
                <xsl:text>,</xsl:text><xsl:value-of select="$columns"/><xsl:text>,</xsl:text><xsl:value-of select="$columns"/><xsl:text>-panel1.getPreferredSize().columns,  Terminal.Color.WHITE))</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="window">
        <xsl:text>
        _window = inWindow;
        _window.removeAllComponents()
        _window.setBorder(new Border.Invisible())
        _window.setSoloWindow(true)
        _window.setWindowSizeOverride(new TerminalSize(</xsl:text>
        <xsl:value-of select="$columns"/>
        <xsl:text>,</xsl:text>
        <xsl:value-of select="$rows"/>
        <xsl:text>))</xsl:text>
        <xsl:apply-templates select="//xhtml:fieldset[@class='command-legend']" mode="prefix"/>
        <!--command line where user can input values and submit the form-->
        <xsl:call-template name="command-fields"/>
        <!--Messages, could be user message, error message, info message or/and instruction-->
        <xsl:call-template name="messages"/>
        <!--Pagination form commands-->
        <xsl:apply-templates select="//xhtml:fieldset[@class='pagination-no-border' or @class='pagination']"
                             mode="pagination"/>
        <!--Tabular data. Job list, Dispatch etc -->
        <xsl:apply-templates select="//xhtml:table"/>
        <!--Reroute complete to command-->
        <xsl:apply-templates select="//xhtml:fieldset[@class='command-legend']" mode="addToWindow"/>
        <!--Command labels, list of available commands in a given form-->
        <xsl:call-template name="command-labels"/>
        <xsl:text>
        _shell.guiScreen.setTheme(new RdtTheme())
        </xsl:text>
    </xsl:template>

    <!--This template is used to create "complete to" command in reroute page.
         The reroute form has unique design thus the template below is used to generate (copy) the commands.-->
    <xsl:template match="xhtml:fieldset[@class='command-legend']" mode="prefix">
        <xsl:call-template name="newLine"/>
        <xsl:text>def prefixCommand = new Panel(new Border.Invisible(), Panel.Orientation.VERTICAL)</xsl:text>
        <xsl:call-template name="newLine"/>
        <xsl:variable name="reroute">
            <xsl:value-of select="concat(descendant::xhtml:a/@id,':',substring(descendant::xhtml:a/.,1,11))"/>
            <xsl:apply-templates select="descendant::xhtml:label"/>
        </xsl:variable>
        <xsl:variable name="extra-content">
            <xsl:choose>
                <xsl:when test="//xhtml:div[@class='button enabled message-fragment message' or @class='button enabled message-fragment cheMessage']">
                    <xsl:value-of select="'3'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'2'"/>
                </xsl:otherwise>
            </xsl:choose>

        </xsl:variable>
        <xsl:text>prefixCommand.addComponent(new </xsl:text><xsl:value-of select="$smartLabelType"/><xsl:text>(</xsl:text>
        <xsl:value-of select="concat('&quot;',normalize-space($reroute),'&quot;',',')"/>
        <xsl:value-of select="concat('&quot;',$reroute,'&quot;')"/>
        <xsl:text>,</xsl:text><xsl:value-of select="$columns"/><xsl:text>, Terminal.Color.GREEN,1,</xsl:text><xsl:value-of select="$extra-content"/><xsl:text>))</xsl:text>
        <xsl:call-template name="newLine"/>
        <xsl:apply-templates select="xhtml:div['pad']"/>
    </xsl:template>

    <xsl:template match="xhtml:div['pad']">
        <xsl:variable name="line" select="concat('line',descendant::xhtml:span[@class='inline'])"/>
        <xsl:text>def </xsl:text>
        <xsl:value-of select="$line"/>
        <xsl:text> = new Panel(new Border.Invisible(), Panel.Orientation.HORISONTAL)</xsl:text>
        <xsl:call-template name="newLine"/>
        <xsl:value-of select="$line"/>
        <xsl:text>.addComponent(new Label("</xsl:text>
        <xsl:value-of select="'-'"/>
        <xsl:apply-templates select="descendant::xhtml:span[@class='inline']"/>
        <xsl:text>", Terminal.Color.CYAN))</xsl:text>
        <xsl:call-template name="newLine"/>
        <xsl:value-of
                select="concat('def ', substring-after(descendant::xhtml:input/@name,'index-') , '= new ',$textBoxType,'(&quot;&quot;,', $inputFieldSize,')')"/>
        <xsl:call-template name="newLine"/>
        <xsl:value-of select="$line"/>
        <xsl:text>.addComponent(</xsl:text>
        <xsl:value-of select="substring-after(descendant::xhtml:input/@name,'index-')"/>
        <xsl:text>)</xsl:text>
        <xsl:call-template name="newLine"/>
        <xsl:text>prefixCommand.addComponent(</xsl:text>
        <xsl:value-of select="$line"/>
        <xsl:text>)</xsl:text>
        <xsl:call-template name="newLine"/>
    </xsl:template>
    <!--Add the reroute command to the window. The reroute panel is created first to allow the map to get the input fields but
     added to the window next to the panel commandFields-->
    <xsl:template match="xhtml:fieldset[@class='command-legend']" mode="addToWindow">
        <xsl:call-template name="newLine"/>
        <xsl:text>usedRows+= prefixCommand.getPreferredSize().rows;</xsl:text>
        <xsl:call-template name="newLine"/>
        <xsl:text>_window.addComponent(prefixCommand)</xsl:text>
    </xsl:template>

    <xsl:template match="xhtml:fieldset[@class='command-legend']" mode="prefixInputField">
        <xsl:apply-templates select="xhtml:div['pad']" mode="prefixInputField"/>
    </xsl:template>

    <xsl:template match="xhtml:div['pad']" mode="prefixInputField">
        <xsl:value-of
                select="concat('parameters.put(&quot;', descendant::xhtml:input/@name, '&quot;,', substring-after(descendant::xhtml:input/@name,'index-'), '.getText())')"/>
        <xsl:call-template name="newLine"/>
    </xsl:template>

    <xsl:template match="xhtml:span[@class='inline']">
        <xsl:value-of select="concat( ., ':')"/>
    </xsl:template>

    <xsl:template name="messages">
        <xsl:call-template name="newLine"/>
        <xsl:apply-templates
                select="//xhtml:div[@class='button enabled message-fragment message' or @class='button enabled message-fragment cheMessage' or @class='message-fragment workZone']"/>
        <!--Information message like "wait for next job"-->
        <xsl:apply-templates select="//xhtml:div[@class='info-message']"/>
        <xsl:apply-templates select="//xhtml:div[@class='data']"/>
    </xsl:template>

    <xsl:template match="xhtml:div[@class='info-message']">
        <xsl:variable name="infoMessage">
            <xsl:call-template name="escapeQuote"/>
        </xsl:variable>
        <xsl:call-template name="newLine"/>
        <xsl:text>def infoMessagePanel= new Panel(new Border.Invisible(), Panel.Orientation.VERTICAL)</xsl:text>
        <xsl:call-template name="newLine"/>
        <xsl:choose>
            <xsl:when test="string-length($infoMessage) &lt; $columns">
                <xsl:text>infoMessagePanel.addComponent(new Label("</xsl:text>
                <xsl:value-of select="$infoMessage"/>
                <xsl:text>",  Terminal.Color.CYAN))</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>infoMessagePanel.addComponent(new </xsl:text><xsl:value-of select="$abbreviationLabelType"/><xsl:text>(</xsl:text>
                <xsl:value-of select="concat('&quot;',substring($infoMessage,1,$columns - 1),'~&quot;',',')"/>
                <xsl:value-of select="concat('&quot;',$infoMessage,'&quot;')"/>
                <xsl:text>,</xsl:text><xsl:value-of select="$columns"/><xsl:text>,  Terminal.Color.CYAN))</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="newLine"/>
        <xsl:text>usedRows+= infoMessagePanel.getPreferredSize().rows</xsl:text>
        <xsl:call-template name="newLine"/>
        <xsl:text>_window.addComponent(infoMessagePanel)</xsl:text>
        <xsl:call-template name="newLine"/>
    </xsl:template>

    <xsl:template match="xhtml:div[@class='data']">
        <xsl:call-template name="newLine"/>
        <xsl:text>def missionStatementPanel= new Panel(new Border.Invisible(), Panel.Orientation.VERTICAL)</xsl:text>
        <xsl:call-template name="newLine"/>
        <xsl:choose>
            <xsl:when test="$columns = 20">
                <xsl:apply-templates select="descendant::xhtml:div[@class='line-item']" mode="wrap"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="descendant::xhtml:div[@class='line-item']"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="newLine"/>
        <xsl:text>usedRows+= missionStatementPanel.getPreferredSize().rows</xsl:text>
        <xsl:call-template name="newLine"/>
        <xsl:text>_window.addComponent(missionStatementPanel)</xsl:text>
        <xsl:call-template name="newLine"/>
    </xsl:template>

    <xsl:template match="xhtml:br">
        <!--Ignore tag-->
    </xsl:template>

    <xsl:template match="xhtml:div[@class='line-item']" mode="wrap">
        <xsl:variable name="missionStatement">
            <xsl:apply-templates select="node()" mode="fullLine"/>
        </xsl:variable>
        <xsl:variable name="line">
            <xsl:call-template name="addNewLine">
                <xsl:with-param name="text" select="$missionStatement"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:text>missionStatementPanel.addComponent(new Label("</xsl:text>
        <xsl:call-template name="escapeQuote">
            <xsl:with-param name="text" select="$line"/>
        </xsl:call-template>
        <xsl:text>", Terminal.Color.CYAN))</xsl:text>
        <xsl:call-template name="newLine"/>
    </xsl:template>

    <xsl:template match="xhtml:div[@class='line-item']">
        <xsl:apply-templates select="node()"/>
    </xsl:template>

    <xsl:template match="xhtml:div[@class='line-item'][xhtml:br]">
        <xsl:apply-templates select="node()"/>
    </xsl:template>

    <xsl:template match="node()" mode="fullLine">
        <xsl:variable name="line">
            <xsl:call-template name="escapeQuote"/>
        </xsl:variable>
        <xsl:value-of select="concat($line, ' ')"/>
    </xsl:template>

    <xsl:template match="node()">
        <xsl:call-template name="newLine"/>
        <xsl:text>missionStatementPanel.addComponent(new Label("</xsl:text>
        <xsl:call-template name="escapeQuote"/>
        <xsl:text>", Terminal.Color.CYAN))</xsl:text>
        <xsl:call-template name="newLine"/>
    </xsl:template>

    <xsl:template
            match="xhtml:div[@class='button enabled message-fragment message' or @class='button enabled message-fragment cheMessage']">
        <xsl:call-template name="newLine"/>
        <xsl:variable name="cheMessage">
            <xsl:call-template name="escapeQuote"/>
        </xsl:variable>
        <xsl:text>def cheMessagePanel= new Panel(new Border.Invisible(), Panel.Orientation.VERTICAL)</xsl:text>
        <xsl:call-template name="newLine"/>
        <xsl:choose>
            <xsl:when test="string-length($cheMessage) &lt; $columns">
                <xsl:text>cheMessagePanel.addComponent(new Label("</xsl:text>
                <xsl:value-of select="$cheMessage"/>
                <xsl:text>", Terminal.Color.YELLOW))</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>cheMessagePanel.addComponent(new </xsl:text><xsl:value-of select="$abbreviationLabelType"/><xsl:text>(</xsl:text>
                <xsl:value-of select="concat('&quot;',substring($cheMessage,1,$columns - 1),'~&quot;',',')"/>
                <xsl:value-of select="concat('&quot;',$cheMessage,'&quot;')"/>
                <xsl:text>,</xsl:text><xsl:value-of select="$columns"/><xsl:text>, Terminal.Color.YELLOW))</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="newLine"/>
        <xsl:text>usedRows+= cheMessagePanel.getPreferredSize().rows</xsl:text>
        <xsl:call-template name="newLine"/>
        <xsl:text>_window.addComponent(cheMessagePanel)</xsl:text>
        <xsl:call-template name="newLine"/>
    </xsl:template>

    <xsl:template
            match="xhtml:div[@class='message-fragment workZone']">
        <xsl:call-template name="newLine"/>
        <xsl:variable name="cheMessage">
            <xsl:call-template name="escapeQuote"/>
        </xsl:variable>
        <xsl:text>def cheWorkZoneMessagePanel= new Panel(new Border.Invisible(), Panel.Orientation.VERTICAL)</xsl:text>
        <xsl:call-template name="newLine"/>
        <xsl:choose>
            <xsl:when test="string-length($cheMessage) &lt; $columns">
                <xsl:text>cheWorkZoneMessagePanel.addComponent(new Label("</xsl:text>
                <xsl:value-of select="$cheMessage"/>
                <xsl:text>", Terminal.Color.YELLOW))</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>cheWorkZoneMessagePanel.addComponent(new </xsl:text><xsl:value-of select="$abbreviationLabelType"/><xsl:text>(</xsl:text>
                <xsl:value-of select="concat('&quot;',substring($cheMessage,1,$columns - 1),'~&quot;',',')"/>
                <xsl:value-of select="concat('&quot;',$cheMessage,'&quot;')"/>
                <xsl:text>,</xsl:text><xsl:value-of select="$columns"/><xsl:text>, Terminal.Color.YELLOW))</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="newLine"/>
        <xsl:text>usedRows+= cheWorkZoneMessagePanel.getPreferredSize().rows</xsl:text>
        <xsl:call-template name="newLine"/>
        <xsl:text>_window.addComponent(cheWorkZoneMessagePanel)</xsl:text>
        <xsl:call-template name="newLine"/>
    </xsl:template>

    <xsl:template match="xhtml:table[@class='data' or @class='data small-footer']">
        <xsl:call-template name="newLine"/>
        <xsl:text>def table = new Panel(new Border.Invisible(), Panel.Orientation.VERTICAL)</xsl:text>
        <xsl:call-template name="newLine"/>
        <xsl:choose>
            <xsl:when test="$columns &gt;= 40 and //xhtml:tr[contains(@class , 'button')]">
                <xsl:apply-templates select="descendant::xhtml:tr"/>
            </xsl:when>
            <xsl:when test="$columns &gt;= 40 and not(//xhtml:tr[contains(@class , 'button')])">
                <xsl:text>def data = new Table(2)</xsl:text>
                <xsl:apply-templates select="descendant::xhtml:tr"/>
                <xsl:call-template name="newLine"/>
                <xsl:text>table.addComponent(data)</xsl:text>
            </xsl:when>
            <xsl:when test="$columns = 20 and //xhtml:tr[contains(@class , 'button')]">
                <xsl:apply-templates select="descendant::xhtml:tr"/>
            </xsl:when>
            <xsl:when test="$columns = 20 and not(//xhtml:tr[contains(@class , 'button')])">
                <xsl:call-template name="newLine"/>
                <xsl:variable name="table">
                    <xsl:call-template name="escapeQuote">
                        <xsl:with-param name="text">
                            <xsl:call-template name="addNewLine">
                                <xsl:with-param name="text">
                                    <xsl:apply-templates select="descendant::xhtml:tr"/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:text>table.addComponent(new Label("</xsl:text>
                <xsl:value-of select="$table"/>
                <xsl:text>", Terminal.Color.WHITE))</xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:call-template name="newLine"/>
        <xsl:text>def availableRows = </xsl:text><xsl:value-of select="$rows"/><xsl:text> - usedRows
            if (table.getPreferredSize().rows >= availableRows) {
               table.setPreferredSize(new TerminalSize(table.getPreferredSize().columns, --availableRows))
             }
            usedRows+= table.getPreferredSize().rows;
        </xsl:text>
        <xsl:call-template name="newLine"/>
        <xsl:text>_window.addComponent(table)</xsl:text>
    </xsl:template>
    <!--copy table rows, remove rows which contain label names but no value associated to them (again this is done to save some space).-->
    <xsl:template match="xhtml:tr">
        <xsl:call-template name="newLine"/>
        <xsl:choose>
            <!--Skip che range information for telnet because of screen size limitation-->
            <xsl:when test="contains(@class,'table-footer')"/>
            <xsl:when test="$columns &gt;= 40">
                <xsl:variable name="row-data">
                    <xsl:apply-templates select="descendant::xhtml:td[. != '']" mode="tableRow"/>
                </xsl:variable>
                <xsl:if test="string-length($row-data)">
                    <xsl:text>data.addRow(</xsl:text>
                    <xsl:for-each select="tokenize($row-data,',')">
                        <xsl:text>new Label("</xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:text>")</xsl:text>
                        <xsl:if test="position() != last()">
                            <xsl:text>,</xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:text>)</xsl:text>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="row-content">
                    <xsl:apply-templates select="descendant::xhtml:td[. != '']"/>
                </xsl:variable>
                <xsl:if test="$row-content">
                    <xsl:value-of select="concat(replace($row-content,'~',' '), ' ')"/>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--copy table rows, remove rows which contain label names but no value associated to them (again this is done to save some space).-->
    <xsl:template match="xhtml:tr[contains(@class,'button')]">
        <xsl:call-template name="newLine"/>
        <xsl:variable name="row-content">
            <xsl:apply-templates select="descendant::xhtml:td[. != '']"/>
        </xsl:variable>
        <xsl:variable name="sanitized-row">
            <xsl:value-of select="replace($row-content,'~',' ')"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="string-length(normalize-space($sanitized-row)) &lt;= $columns">
                <xsl:text>table.addComponent(new Label("</xsl:text>
                <xsl:value-of select="$sanitized-row"/>
                <xsl:text>", Terminal.Color.CYAN))</xsl:text>
            </xsl:when>
            <xsl:when test="string-length($row-content) &gt; $columns and 20 = $columns">
                <xsl:variable name="row-content-extracted">
                    <xsl:value-of select="replace($row-content,'~&gt;~','&gt;')"/>
                </xsl:variable>
                <xsl:variable name="line">
                    <xsl:call-template name="rearrangeLine">
                        <xsl:with-param name="line" select="$row-content-extracted"/>
                        <xsl:with-param name="row-size" select="2" as="xs:integer"/>
                        <xsl:with-param name="column-size" select="$columns" as="xs:integer"/>
                        <xsl:with-param name="skipped" select="''"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="string-length($sanitized-row) ge string-length($line)">
                        <xsl:text>table.addComponent(new </xsl:text><xsl:value-of select="$abbreviationLabelType"/><xsl:text>(</xsl:text>
                        <xsl:value-of select="concat('&quot;',$line,'&quot;',',')"/>
                        <xsl:value-of select="concat('&quot;',$sanitized-row,'&quot;')"/>
                        <xsl:text>,</xsl:text><xsl:value-of select="$columns"/><xsl:text>, Terminal.Color.CYAN))</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>table.addComponent(new Label("</xsl:text>
                        <xsl:value-of select="translate($line,'&quot;','&quot;')"/>
                        <xsl:text>", Terminal.Color.CYAN))</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="string-length(normalize-space($sanitized-row)) gt $columns and 40 = $columns">
                <xsl:text>table.addComponent(new </xsl:text><xsl:value-of select="$abbreviationLabelType"/><xsl:text>(</xsl:text>
                <xsl:value-of select="concat('&quot;',$sanitized-row,'&quot;',',')"/>
                <xsl:value-of select="concat('&quot;',$sanitized-row,'&quot;')"/>
                <xsl:text>,</xsl:text><xsl:value-of select="$columns"/><xsl:text>, Terminal.Color.CYAN))</xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:call-template name="newLine"/>
    </xsl:template>

    <xsl:template match="xhtml:td">
        <xsl:variable name="value">
            <xsl:call-template name="escapeQuote"/>
        </xsl:variable>
        <xsl:value-of select="translate(concat($value,'~'),'&#xbb;','&gt;')"/>
    </xsl:template>

    <xsl:template match="xhtml:td" mode="tableRow">
        <xsl:variable name="value">
            <xsl:call-template name="escapeQuote"/>
        </xsl:variable>
        <xsl:value-of select="translate(translate($value,'&#xbb;','&gt;'),' ','')"/>
        <xsl:if test="position() != last()">
            <xsl:value-of select="','"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="xhtml:td[@class='label']" mode="tableRow">
        <xsl:apply-templates select="."/>
    </xsl:template>

    <xsl:template match="xhtml:td[@class='label']">
        <xsl:if test="following-sibling::xhtml:td[@class='value']/. != ''">
            <xsl:call-template name="escapeQuote">
                <xsl:with-param name="text">
                    <xsl:value-of select="translate(.,' ','-')"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template name="command-labels">

        <xsl:call-template name="newLine"/>
        <xsl:text>def commandLabels = new Panel(new Border.Invisible(), Panel.Orientation.HORISONTAL)</xsl:text>
        <xsl:variable name="main-commands">
            <xsl:apply-templates select="//xhtml:div[@class='commands']/descendant::xhtml:fieldset" mode='commandList'/>
        </xsl:variable>
        <xsl:variable name="footer-commands">
            <xsl:apply-templates select="//xhtml:div[@class='footer']/descendant::xhtml:a" mode='footerList'/>
        </xsl:variable>
        <xsl:variable name="clear-command">
            <xsl:apply-templates select="//xhtml:div[@class='button enabled message-fragment message' or
                                        @class='button enabled message-fragment cheMessage']" mode="clearCommandList"/>
        </xsl:variable>
        <xsl:variable name="commandList">
            <xsl:value-of select="concat($main-commands, $footer-commands, $clear-command)"/>
        </xsl:variable>
        <xsl:apply-templates select="//xhtml:div[@class='commands']/descendant::xhtml:fieldset" mode='command'>
            <xsl:with-param name="commandList" select="$commandList"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="//xhtml:div[@class='footer']/descendant::xhtml:a" mode='footer'>
            <xsl:with-param name="commandList" select="$commandList"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="//xhtml:div[@class='button enabled message-fragment message' or
                                               @class='button enabled message-fragment cheMessage']" mode="clearCommand">
            <xsl:with-param name="commandList" select="$commandList"/>
        </xsl:apply-templates>
        <xsl:call-template name="addCommandLabels"/>
        <!--Adjust rows by adding new line to after each component if there is extra space remaining to help readability-->
        <xsl:if test="$columns &gt; 20">
            <xsl:call-template name="adjustComponentNewLine"/>
        </xsl:if>
        _window.addComponent(commandLabels)
    </xsl:template>

    <xsl:template name="addCommandLabels">
        <xsl:call-template name="newLine"/>
        <xsl:text>
            for (SmartLabel inSmartLabel : commandLabelList) {
                usedRows += inSmartLabel.calculatePreferredSize().rows;
                commandLabels.addComponent(inSmartLabel);
            }
        </xsl:text>
        <xsl:call-template name="newLine"/>
    </xsl:template>

    <xsl:template name="adjustComponentNewLine">
        <xsl:call-template name="newLine"/>
        <xsl:text>
            if (usedRows + _window.getComponentCount() &lt;= </xsl:text><xsl:value-of select="number($rows)"/><xsl:text>) {
                  for (SmartLabel inSmartLabel : commandLabelList) {
                    inSmartLabel.adjustRow(_window.getComponentCount());
                  }
                  for (SmartLabel inSmartLabel : paginationLabelList) {
                    inSmartLabel.adjustRow(1);
                  }
                  def List&lt;Component&gt; windowComponent = new ArrayList&lt;&gt;();
                  for (int i = 0; i &lt; _window.getComponentCount(); i++) {
                    windowComponent.add(_window.getComponentAt(i));
                  }
                  _window.removeAllComponents();
                  for (Component inComponent : windowComponent) {
                    _window.addComponent(inComponent);
                    _window.addComponent(new EmptySpace(1, 1));
                  }
            } else if (usedRows &lt; </xsl:text><xsl:value-of select="number($rows)"/><xsl:text>) {
                 for (SmartLabel inSmartLabel : commandLabelList) {
                    inSmartLabel.adjustRow(1);
                 }
            }
        </xsl:text>
        <xsl:call-template name="newLine"/>
    </xsl:template>

    <!--copy pagination button-->
    <xsl:template match="xhtml:a | xhtml:em" mode="paginationCommand">
        <xsl:param name="content" required="yes"/>
        <xsl:variable name="command-name">
            <xsl:apply-templates select="." mode="command"/>
        </xsl:variable>
        <xsl:text>paginationLabelList.add(new </xsl:text><xsl:value-of select="$smartLabelType"/><xsl:text>(</xsl:text>
        <xsl:value-of select="concat('&quot;',normalize-space(translate(translate($command-name,'&#xbb;','&gt;'),'&#xab;','&lt;')),'&quot;',',')"/>
        <xsl:value-of select="concat('&quot;',$content,'&quot;')"/>
        <xsl:text>,</xsl:text><xsl:value-of select="$columns"/><xsl:text>, Terminal.Color.GREEN,1,usedRows + 1))</xsl:text>
        <xsl:call-template name="newLine"/>
    </xsl:template>

    <!--Add 'Clear message' command to the list of commands if there is an error message, the command is used to clear the error message-->
    <xsl:template match="xhtml:div[@class='button enabled message-fragment message' or @class='button enabled message-fragment cheMessage']"
                  mode="clearCommandList">
        <xsl:if test="@id != ''">
            <xsl:value-of select="concat(@id,':Clear ')"/>
        </xsl:if>
    </xsl:template>
    <!-- Creating a label for command 'Clear message' if there is any error message to clear-->
    <xsl:template match="xhtml:div[@class='button enabled message-fragment message' or @class='button enabled message-fragment cheMessage']"
                  mode="clearCommand">
        <xsl:param name="commandList"/>
        <xsl:if test="@id != ''">
            <xsl:call-template name="newLine"/>
            <xsl:text>commandLabelList.add(new </xsl:text><xsl:value-of select="$smartLabelType"/><xsl:text>(&quot;</xsl:text>
            <xsl:value-of select="concat(@id,':Clear')"/>
            <xsl:value-of select="concat('&quot;,&quot;',$commandList,'&quot;')"/>
            <xsl:text>,</xsl:text><xsl:value-of select="$columns"/><xsl:text>, Terminal.Color.GREEN,</xsl:text><xsl:value-of
                select="number($rows)"/><xsl:text> - usedRows,</xsl:text><xsl:value-of select="number($rows)"/><xsl:text>))</xsl:text>
            <xsl:call-template name="newLine"/>
        </xsl:if>
    </xsl:template>

    <!--copy enabled button-->
    <xsl:template match="xhtml:a" mode="command">
        <xsl:choose>
            <xsl:when test="comment()">
                <xsl:apply-templates select="comment()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="command-name">
                    <xsl:call-template name="escapeQuote"/>
                </xsl:variable>
                <xsl:value-of select="concat(@id,':',$command-name,' ')"/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template match="comment()">
        <xsl:variable name="comment" select="." as="xs:string"/>
        <xsl:if test="$columns = 20 and contains($comment, 'abbrev20')">
            <xsl:value-of select="concat(parent::xhtml:a/@id, ':', substring-after($comment, '='), $custom_abbrev)"/>
        </xsl:if>
        <xsl:if test="$columns &gt;= 40 and contains($comment, 'abbrev40')">
            <xsl:value-of select="concat(parent::xhtml:a/@id, ':', substring-after($comment, '='), $custom_abbrev)"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="xhtml:em" mode="command">
        <xsl:param name="list"/>
        <xsl:choose>
            <xsl:when test="not($list)">
                <xsl:variable name="command">
                    <xsl:call-template name="jobCount"/>
                </xsl:variable>
                <xsl:value-of select="substring-before($command,$custom_abbrev)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="jobCount"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="jobCount">
        <xsl:variable name="elValue" select="."/>

        <xsl:analyze-string select="$elValue"
                            regex="\s*(\d+\-\d+)\s*[a-z]*\s*(\d+)\s*.*">

            <xsl:matching-substring>
                <xsl:value-of select="concat($fake_command_index,'[',regex-group(1),'/',regex-group(2),']',$custom_abbrev,' ')"/>
            </xsl:matching-substring>

            <xsl:non-matching-substring>
                <xsl:value-of select="concat($fake_command_index,'[',$elValue,']',$custom_abbrev,' ')"/>
            </xsl:non-matching-substring>

        </xsl:analyze-string>
    </xsl:template>
    <xsl:template match="xhtml:a" mode="footer">
        <xsl:param name="commandList"/>
        <xsl:call-template name="newLine"/>
        <xsl:text>commandLabelList.add(new </xsl:text><xsl:value-of select="$smartLabelType"/><xsl:text>(&quot;</xsl:text>
        <xsl:value-of select="concat(@id,':',.)"/>
        <xsl:value-of select="concat('&quot;,&quot;',$commandList,'&quot;')"/>
        <xsl:text>,</xsl:text><xsl:value-of select="$columns"/><xsl:text>, Terminal.Color.GREEN,</xsl:text><xsl:value-of
            select="number($rows)"/><xsl:text> - usedRows,</xsl:text><xsl:value-of select="number($rows)"/><xsl:text>))</xsl:text>
        <xsl:call-template name="newLine"/>
    </xsl:template>

    <xsl:template match="xhtml:a" mode="footerList">
        <!--<xsl:variable name="command" select="if (position() = last()) then  concat(@id,':',.) else concat(@id,':',.,' ')"/>-->
        <xsl:value-of select="concat(@id,':',.,' ')"/>
    </xsl:template>
    <!--A template to generate pagination buttons.-->
    <xsl:template match="xhtml:fieldset[@class='pagination-no-border' or @class='pagination']" mode="pagination">
        <xsl:call-template name="newLine"/>
        <xsl:text>def pagination = new Panel(new Border.Invisible(), Panel.Orientation.HORISONTAL)</xsl:text>
        <xsl:call-template name="newLine"/>
        <xsl:variable name="pagination-content">
            <xsl:apply-templates
                    select="descendant::xhtml:span/descendant::xhtml:a | descendant::xhtml:span/descendant::xhtml:em" mode="command">
                <xsl:with-param name="list" select="'true'"/>
            </xsl:apply-templates>
        </xsl:variable>
        <xsl:variable name="content">
            <xsl:value-of select="translate(translate($pagination-content,'&#xbb;','&gt;'),'&#xab;','&lt;')"/>
        </xsl:variable>
        <xsl:apply-templates
                select="descendant::xhtml:span/descendant::xhtml:a | descendant::xhtml:span/descendant::xhtml:em" mode="paginationCommand">
            <xsl:with-param name="content" select="$content"/>
        </xsl:apply-templates>
        <xsl:call-template name="newLine"/>
        <xsl:text>
            for (SmartLabel inSmartLabel : paginationLabelList) {
              pagination.addComponent(inSmartLabel);
            }
            usedRows+= pagination.getPreferredSize().rows;</xsl:text>
        <xsl:call-template name="newLine"/>
        <xsl:text>_window.addComponent(pagination)</xsl:text>
    </xsl:template>

    <xsl:template match="xhtml:fieldset" mode="commandList">
        <xsl:variable name="command-name">
            <xsl:apply-templates select="descendant::xhtml:a" mode="command"/>
        </xsl:variable>
        <xsl:variable name="label-values">
            <xsl:apply-templates select="descendant::xhtml:label"/>
        </xsl:variable>
        <xsl:value-of
                select="if(contains($command-name, $custom_abbrev)) then concat(normalize-space($command-name), ' ')
                else concat(normalize-space($command-name), $label-values,' ')"/>
    </xsl:template>

    <xsl:template match="xhtml:fieldset" mode="command">
        <xsl:param name="commandList"/>
        <xsl:variable name="command-name">
            <xsl:apply-templates select="descendant::xhtml:a" mode="command"/>
        </xsl:variable>
        <xsl:variable name="label-values">
            <xsl:apply-templates select="descendant::xhtml:label"/>
        </xsl:variable>

        <xsl:call-template name="newLine"/>
        <xsl:text>commandLabelList.add(new </xsl:text><xsl:value-of select="$smartLabelType"/><xsl:text>(&quot;</xsl:text>
        <xsl:value-of
                select="if (contains($command-name, $custom_abbrev)) then normalize-space($command-name)
                else concat(normalize-space($command-name), $label-values)"/>
        <xsl:value-of select="concat('&quot;,&quot;',$commandList,'&quot;')"/>
        <xsl:text>,</xsl:text><xsl:value-of select="$columns"/><xsl:text>, Terminal.Color.GREEN,</xsl:text><xsl:value-of
            select="number($rows)"/><xsl:text> - usedRows,</xsl:text><xsl:value-of select="number($rows)"/><xsl:text>))</xsl:text>
        <xsl:call-template name="newLine"/>

    </xsl:template>

    <xsl:template match="xhtml:fieldset" mode="input">
        <xsl:variable name="count">
            <xsl:value-of select="count(descendant::xhtml:input)"/>
        </xsl:variable>
        <xsl:if test="$columns = 20 and $count > 1">
            def panel2 = new Panel(new Border.Invisible(), Panel.Orientation.HORISONTAL)
            commandFields.addComponent(panel2)
        </xsl:if>
        <xsl:apply-templates select="descendant::xhtml:input" mode="definition">
            <xsl:with-param name="count" select="$count"/>
        </xsl:apply-templates>
        <xsl:call-template name="newLine"/>
    </xsl:template>

    <xsl:template match="xhtml:label">
        <xsl:value-of select="concat('[',.,']')"/>
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

    <xsl:template name="declare-input-fields">
        <xsl:variable name="commands" select="//xhtml:div[@class = 'commands']"/>
        <xsl:for-each select="$commands/descendant::xhtml:ul">
            <xsl:sort select="count(xhtml:li)" order="descending"/>
            <xsl:if test="position() = 1">
                <xsl:apply-templates select="ancestor::xhtml:fieldset/descendant::xhtml:input" mode="declaration"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <!--A template to find the command with the most number of input fields and use that command to add the input fields value to a map for submission.-->
    <xsl:template name="add-input-fields-to-map">
        <xsl:variable name="commands" select="//xhtml:div[@class = 'commands']"/>
        <xsl:for-each select="$commands/descendant::xhtml:ul">
            <xsl:sort select="count(xhtml:li)" order="descending"/>
            <xsl:if test="position() = 1">
                <xsl:apply-templates select="ancestor::xhtml:fieldset/descendant::xhtml:input" mode="addToMap"/>
            </xsl:if>
        </xsl:for-each>
        <!--Matched only on form reroute. Form reroute uses separate input fields to reroute the unit to a different location(i.e command "complete to")-->
        <xsl:apply-templates select="//xhtml:fieldset[@class='command-legend']" mode="prefixInputField"/>
    </xsl:template>

    <!--A template to count the maximum number of input fields in a given form.-->
    <xsl:template name="count-max-input-fields">
        <xsl:variable name="commands" select="//xhtml:div[@class = 'commands']"/>
        <xsl:choose>
            <xsl:when test="$commands/descendant::xhtml:ul">
                <xsl:for-each select="$commands/descendant::xhtml:ul">
                    <xsl:sort select="count(xhtml:li)" order="descending"/>
                    <xsl:if test="position() = 1">
                        <xsl:value-of select="count(ancestor::xhtml:fieldset/descendant::xhtml:input)"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="0"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="imports">
        <xsl:text>package </xsl:text>
        <xsl:value-of select="$packageName"/>
        <xsl:call-template name="newLine"/>
        <xsl:text>
        import com.googlecode.lanterna.gui.Action
        import com.googlecode.lanterna.gui.Border
        import com.googlecode.lanterna.gui.Window
        import com.navis.ecn4web.shell.DecoratedAbbreviationLabel
        import com.navis.ecn4web.shell.AbbreviationLabel
        import com.navis.ecn4web.shell.DecoratedSmartLabel
        import com.navis.ecn4web.shell.SmartLabel
        import com.navis.ecn4web.shell.IRdtShell
        import com.navis.ecn4web.shell.RdtTheme
        import com.googlecode.lanterna.gui.component.*
        import com.googlecode.lanterna.terminal.Terminal
        import com.googlecode.lanterna.terminal.TerminalSize
        import com.googlecode.lanterna.gui.Component
        </xsl:text>
        <xsl:call-template name="doubleNewLine"/>
    </xsl:template>

    <!--Utility templates-->
    <xsl:template name="newLine">
        <xsl:text>&#10;</xsl:text>
    </xsl:template>

    <xsl:template name="doubleNewLine">
        <xsl:text>&#10;&#10;</xsl:text>
    </xsl:template>

    <xsl:template name="addNewLine">
        <xsl:param name="text" select="."/>
        <xsl:if test="string-length($text) > $columns">
            <xsl:variable name="sub">
                <xsl:value-of select="substring($text, 0, $columns)"/>
            </xsl:variable>
            <xsl:variable name="sub-with-whitespace">
                <xsl:choose>
                    <xsl:when test="contains($sub,' ')">
                        <xsl:value-of select="$sub"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat($sub,' ')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="sub-before-whitespace">
                <xsl:call-template name="substring-before-last">
                    <xsl:with-param name="list" select="$sub-with-whitespace"/>
                    <xsl:with-param name="delimiter" select="' '"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:value-of select="concat($sub-before-whitespace, '\n')"/>
            <xsl:call-template name="newLine"/>
            <xsl:call-template name="addNewLine">
                <xsl:with-param name="text" select=
                        "substring-after($text, concat($sub-before-whitespace,' '))"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="string-length($text) &lt; $columns">
            <xsl:value-of select="$text"/>
        </xsl:if>
    </xsl:template>

    <xsl:template name="rearrangeLine">
        <xsl:param name="line"/>
        <xsl:param name="row-size" as="xs:integer"/>
        <xsl:param name="column-size" as="xs:integer"/>
        <xsl:param name="skipped"/>
        <xsl:variable name="initial-sub">
            <xsl:value-of select="concat(substring-before($line,'~'),'~')"/>
        </xsl:variable>
        <xsl:variable name="sub"
                      select="if(string-length($initial-sub) gt $columns) then concat(substring($initial-sub, 0, $columns - 3),'~') else $initial-sub"/>
        <xsl:if test="$row-size gt 0 and $column-size gt 0 and concat($skipped, $line)">
            <xsl:choose>
                <xsl:when test="string-length($sub) &lt;= $column-size">
                    <xsl:value-of select="concat(substring-before($sub,'~'),' ')"/>
                    <xsl:variable name="remaining-column-size" select="$column-size - string-length($sub)"/>
                    <xsl:if test="((not(normalize-space($line)) and $skipped) or
                                    (normalize-space($line) and $remaining-column-size &lt;= 0))
                                    and  $row-size gt 0">
                        <xsl:value-of select="if ($row-size - 1 gt 0) then '\n ' else ''"/>
                        <xsl:call-template name="rearrangeLine">
                            <xsl:with-param name="line" select="concat($skipped, $line)"/>
                            <xsl:with-param name="row-size" select="$row-size - 1"/>
                            <xsl:with-param name="column-size" select="$columns"/>
                            <xsl:with-param name="skipped" select="''"/>
                        </xsl:call-template>
                    </xsl:if>
                    <xsl:if test="normalize-space($line) and $remaining-column-size &gt; 0">
                        <xsl:call-template name="rearrangeLine">
                            <xsl:with-param name="line" select="substring-after($line, $initial-sub)"/>
                            <xsl:with-param name="row-size" select="$row-size"/>
                            <xsl:with-param name="column-size" select="$remaining-column-size"/>
                            <xsl:with-param name="skipped" select="$skipped"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="rearrangeLine">
                        <xsl:with-param name="line" select="substring-after($line, $initial-sub)"/>
                        <xsl:with-param name="row-size" select="$row-size"/>
                        <xsl:with-param name="column-size" select="$column-size"/>
                        <xsl:with-param name="skipped" select="concat($skipped, $sub)"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

    <xsl:template name="escapeQuote">
        <xsl:param name="text" select="."/>

        <xsl:if test="string-length($text) > 0">
            <xsl:value-of select=
                                  "normalize-space(substring-before(concat($text, '&quot;'), '&quot;'))"/>
            <xsl:if test="contains($text, '&quot;')">
                <xsl:text>\"</xsl:text>
                <xsl:call-template name="escapeQuote">
                    <xsl:with-param name="text" select=
                            "substring-after($text, '&quot;')"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <!--Template to determine Substring before last occurrence
        of a specific delimiter -->
    <xsl:template name="substring-before-last">
        <!--passed template parameter -->
        <xsl:param name="list"/>
        <xsl:param name="delimiter"/>
        <xsl:choose>
            <xsl:when test="contains($list, $delimiter)">
                <!-- get everything in front of the first delimiter -->
                <xsl:value-of select="substring-before($list,$delimiter)"/>
                <xsl:choose>
                    <xsl:when test="contains(substring-after($list,$delimiter),$delimiter)">
                        <xsl:value-of select="$delimiter"/>
                    </xsl:when>
                </xsl:choose>
                <xsl:call-template name="substring-before-last">
                    <!-- store anything left in another variable -->
                    <xsl:with-param name="list" select="substring-after($list,$delimiter)"/>
                    <xsl:with-param name="delimiter" select="$delimiter"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
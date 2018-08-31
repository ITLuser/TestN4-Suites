<?xml version='1.0' encoding="utf-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
                xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
                version='2.0'>
    <xsl:import href="title.xsl"/>
    <xsl:import href="ie_support.xsl"/>
    <xsl:import href="css_theme.xsl"/>

    <xsl:output method="xhtml" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
                doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" indent="yes" omit-xml-declaration="yes" encoding="UTF-8"/>
    <xsl:param name="cheId"/>
    <xsl:param name="contextPath"/>
    <xsl:param name="formId"/>
    <xsl:param name="pollInterval" select="'0'"/>
    <xsl:param name="pollTimeout" select="'0'"/>
    <xsl:param name="pollRetries" select="'0'"/>
    <xsl:param name="timestamp"/>
    <xsl:param name="ecn4web.version"/>
    <xsl:param name="xslt.device.prefix"/>

    <xsl:param name="com.navis.ecn4web.beep" as="xs:boolean" select="false()"/>
    <xsl:variable name="pushedMessage" as="xs:boolean" select="/message/@ack='N'"/>
    <xsl:param name="com.navis.ecn4web.beepFilePath" select="concat($contextPath,'/audio/chord.mp3')"/>

    <xsl:template name="header">
        <xsl:param name="pageTitle" required="yes"/>
        <xsl:param name="mode" required="no"/>
        <link rel="stylesheet" href="{$contextPath}/css/{$xslt.device.prefix}/reset.css" type="text/css"/>
        <link rel="stylesheet" href="{$contextPath}/css/{$xslt.device.prefix}/xsl_styles.css" type="text/css"/>
        <link rel="stylesheet" href="{$contextPath}/css/{$xslt.device.prefix}/widgets.css" type="text/css"/>
        <xsl:call-template name="css-theme"/>
        <xsl:call-template name="ie-css"/>
        <script type="text/javascript">
            window.cheId = '<xsl:value-of select="$cheId"/>';
            window.contextPath = '<xsl:value-of select="$contextPath"/>';
            window.pollInterval = <xsl:value-of select="$pollInterval"/>;
            window.pollTimeout = <xsl:value-of select="$pollTimeout"/>;
            window.pollRetries = <xsl:value-of select="$pollRetries"/>;
            window.timestamp = '<xsl:value-of select="$timestamp"/>';
            window.formId = '<xsl:value-of select="$formId"/>';
            window.POLL_URL = '<xsl:value-of disable-output-escaping='yes'
                                             select="concat($contextPath, '/servlet/Poll')"/>';
            window.beep = <xsl:value-of select="$com.navis.ecn4web.beep and $pushedMessage"/>;
            window.beepFilePath = '<xsl:value-of select="$com.navis.ecn4web.beepFilePath"/>';
        </script>
        <meta name="viewport" content="width = 400"/>
        <title>
            <xsl:call-template name="title">
                <xsl:with-param name="pageTitle" select="$pageTitle"/>
                <xsl:with-param name="mode" select="$mode"/>
            </xsl:call-template>
        </title>
        <xsl:comment>
            <xsl:value-of select="concat('msid:', /message/@MSID)"/>
        </xsl:comment>
    </xsl:template>

</xsl:stylesheet>

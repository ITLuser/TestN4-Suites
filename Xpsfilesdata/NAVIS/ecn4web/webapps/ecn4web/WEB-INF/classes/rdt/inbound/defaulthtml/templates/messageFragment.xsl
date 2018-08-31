<?xml version='1.0' encoding="utf-8"?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
                xmlns:text="http://www.navis.com/ecn4web/functions"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="text" version='2.0'>
    <xsl:import href="formCommands.xsl"/>
    <xsl:param name="userMessage" select="/message/che/displayMsg[@msgID != '0']" required="no"/>
    <xsl:param name="debugInfo"/>
    <xsl:output method="xhtml" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
                doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" indent="yes" omit-xml-declaration="yes" encoding="UTF-8"/>

    <xsl:template name="message-fragment">
        <xsl:param name="formCommands" select="'formCommands.xml'" tunnel="yes"/>
        <xsl:param name="mode" select="''" tunnel="yes"/>
        <xsl:param name="formId" select="/message/@formId" required="no"/>
        <xsl:variable name="messageId" select="/message/che/displayMsg/@msgID"/>
        <xsl:variable name="messageClass">
            <xsl:choose>
                <xsl:when
                        test="$messageId='12' or $messageId='512' or $messageId='513' or $messageId='514' or $messageId='517' or $messageId='521' or
                        $messageId='517' or $messageId='563' or $messageId='564' or $messageId='569' or $messageId='581' or $messageId='585'
                        or $messageId='601' or $messageId='606' or $messageId='608'">
                    <xsl:value-of select="'cheMessage'"/>
                </xsl:when>
                <xsl:otherwise>message</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="form" as="node()*">
            <xsl:apply-templates select="(document($formCommands)/form-list[form[@id = $formId][@mode = $mode]])[1]" mode="formMerge">
                <xsl:with-param name="formId" select="$formId"/>
                <xsl:with-param name="mode" select="$mode"/>
            </xsl:apply-templates>
        </xsl:variable>
        <xsl:variable name="message-command-index"
                      select="$form/command[@fixed = 'message']/@index"/>
        <xsl:call-template name="page-header"/>
        <xsl:if test="$userMessage != ''">
            <div class="{concat('button enabled message-fragment ', $messageClass)}" id="{$message-command-index}">
                <xsl:choose>
                    <xsl:when test="$messageClass = 'cheMessage'">
                        <!--xsl:value-of select="replace($userMessage,'\(([0-9]+)\)','')"/-->
                        <xsl:value-of select="$userMessage"/>
                        <xsl:if test="$debugInfo != ''">
                            <xsl:comment>
                                <xsl:value-of select="$debugInfo"/>
                            </xsl:comment>
                        </xsl:if>
                        <div class="close-button-area">
                            <div class="close-button"/>
                        </div>
                    </xsl:when>
                    <xsl:otherwise>
                        <div class="exclamation-button"/>
                        <xsl:value-of select="$userMessage"/>
                        <xsl:if test="$debugInfo != ''">
                            <xsl:comment>
                                <xsl:value-of select="$debugInfo"/>
                            </xsl:comment>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </xsl:if>
        <div id="alert"/>
    </xsl:template>

    <xsl:template name="page-header">
        <div class="page-header">
            <div class="header-info">
                <xsl:value-of select="concat(text:format('field.CHE_ID'),': ', /message/che/@CHID)"/>
            </div>
            <div class="header-info">
                <xsl:value-of select="concat(text:format('field.User_ID'),': ', message/che/@userID)"/>
            </div>
            <div class="header-info">
                <xsl:value-of select="concat(text:format('field.Time'),': ')"/>
                <span id="clock"/>
            </div>
        </div>
    </xsl:template>

</xsl:stylesheet>


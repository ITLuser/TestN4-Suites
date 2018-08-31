<?xml version='1.0' encoding='utf-8'?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:text="http://www.navis.com/ecn4web/functions"
                version="2.0"
                exclude-result-prefixes="xs text">
    <xsl:import href="templates/common.xsl"/>
    <xsl:import href="templates/pagination.xsl"/>
    <xsl:import href="templates/attributes/attribute-dictionary-joblist.xsl"/>
    <xsl:output method="xhtml" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
                doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" indent="yes" omit-xml-declaration="yes"
                encoding="UTF-8"/>

    <xsl:variable name="maxPerPage" select="count(/message/che/joblist/job)" as="xs:integer"/>
    <xsl:variable name="totalCount" select="/message/che/joblist/@totalCnt" as="xs:integer"/>
    <xsl:variable name="items" select="/message/che/joblist/job"/>
    <xsl:variable name="item-name" select="'Job'"/>
    <xsl:variable name="formCommands" select="'../formCommands.xml'"/>
    <xsl:variable name="mode" select="''"/>
    <xsl:variable name="cssSytle" select="if ($totalCount != 0) then 'pagination' else 'pagination-no-border'"/>
    <xsl:variable name="tableStyle" select="if (/message/che/@range != '') then 'data small-footer' else 'data'"/>
    <xsl:variable name="cheRange" select="/message/che/@range"/>
    <xsl:variable name="formattedCheRange" select="replace($cheRange, '>>', '&#xbb;')"/>

    <!-- noinspection XsltTemplateInvocation -->
    <xsl:template match='/'>
        <html>
            <head>
                <xsl:call-template name="header">
                    <xsl:with-param name="pageTitle" select="text:format('title.Job_List')"/>
                </xsl:call-template>
            </head>
            <body>
                <form id="xmlrdtForm" name="xmlrdtForm" action='{$contextPath}/servlet/xmlrdt' method='post'
                      accept-charset="UTF-8">
                    <xsl:call-template name="message-fragment"/>
                    <fieldset class="{$cssSytle}">
                        <legend>
                            <span class="header">
                                <!-- noinspection XsltTemplateInvocation -->
                                <xsl:call-template name="pagination-controls">
                                    <xsl:with-param name="pagination-title">
                                        <xsl:call-template name="paginationTitle">
                                            <xsl:with-param name="items" select="$items"/>
                                            <xsl:with-param name="item-name" select="$item-name"/>
                                        </xsl:call-template>
                                    </xsl:with-param>
                                </xsl:call-template>
                                <span>&#160;</span>
                                <xsl:call-template name="list-controls"/>
                            </span>
                        </legend>
                        <xsl:if test="$totalCount != 0">
                            <table class="{$tableStyle}">
                                <tbody>
                                    <xsl:apply-templates select="$items"/>
                                    <xsl:if test="$cheRange != ''">
                                        <tr class="table-footer">
                                            <td colspan="3" class="footer">
                                                <xsl:value-of select="text:format('label.Range')"/>
                                            </td>
                                            <td colspan="10" class="footer">
                                                <xsl:value-of
                                                        select="if (string-length($cheRange) lt 30) then $formattedCheRange else concat(substring($formattedCheRange, 1, 28), ' ...')"/>
                                            </td>
                                        </tr>
                                    </xsl:if>
                                </tbody>
                            </table>
                        </xsl:if>
                        <!--input name="inputValue" id="inputValue" type="hidden" value=""/-->
                    </fieldset>

                    <xsl:call-template name="command-menu"/>
                    <xsl:call-template name="pagination-fields">
                        <xsl:with-param name="items" select="$items"/>
                    </xsl:call-template>

                    <xsl:call-template name="hidden-fields"/>
                </form>
                <xsl:call-template name="footer"/>
            </body>

        </html>
    </xsl:template>

</xsl:stylesheet>
